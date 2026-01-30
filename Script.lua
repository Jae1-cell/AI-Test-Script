-- ============================================
-- ENHANCED NPC HEAD MODIFIER WITH ESP
-- Based on your working script
-- ============================================

local service = setmetatable({}, {
    __index = function(self, key)
        local s = game:GetService(key)
        self[key] = s
        return s
    end
})

local function getChar()
    local player = game.Players.LocalPlayer
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild("HumanoidRootPart")
end

-- ESP System
local ESPBoxes = {}
local processedNPCs = {}

local function createESP(npc, color)
    if ESPBoxes[npc] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "NPC_ESP"
    highlight.FillColor = color or Color3.fromRGB(255, 50, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Parent = npc
    
    ESPBoxes[npc] = highlight
    return highlight
end

local function removeESP(npc)
    if ESPBoxes[npc] then
        ESPBoxes[npc]:Destroy()
        ESPBoxes[npc] = nil
    end
end

local function toggleESP(enabled, color)
    for npc, _ in pairs(processedNPCs) do
        if npc and npc.Parent then
            if enabled then
                createESP(npc, color)
            else
                removeESP(npc)
            end
        end
    end
end

-- Load library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wally2", true))()

-- ========== MAIN NPC HEAD MODIFIER ==========
local WS = service.Workspace
local Npc_folder = WS:WaitForChild('NPCs')

local _GlobalEnv = (getgenv and getgenv()) or _G
_GlobalEnv.AutoModifyNPCs = true
_GlobalEnv.HeadScaleValue = 7.0
_GlobalEnv.ESPEnabled = true
_GlobalEnv.NPCHighlightColor = Color3.fromRGB(255, 50, 255)

-- Function to modify NPC head with multiple methods
local function modifyNPCHead(npc)
    if not npc or not npc.Parent then return false end
    
    local head = npc:FindFirstChild("Head")
    if not head then return false end
    
    -- Apply scale
    if head:IsA("MeshPart") then
        head.Size = Vector3.new(_GlobalEnv.HeadScaleValue, _GlobalEnv.HeadScaleValue, _GlobalEnv.HeadScaleValue)
        head.Transparency = 0.5
        head.CanCollide = false
        
        -- Also try to scale any existing meshes
        for _, child in pairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") then
                child.Scale = Vector3.new(_GlobalEnv.HeadScaleValue/3, _GlobalEnv.HeadScaleValue/3, _GlobalEnv.HeadScaleValue/3)
            end
        end
        
        -- Add neon effect
        head.Material = Enum.Material.Neon
        head.Color = _GlobalEnv.NPCHighlightColor
        
        -- Add point light for glow effect
        local light = head:FindFirstChildOfClass("PointLight")
        if not light then
            light = Instance.new("PointLight")
            light.Brightness = 2
            light.Range = 15
            light.Color = _GlobalEnv.NPCHighlightColor
            light.Parent = head
        end
        
        processedNPCs[npc] = true
        
        -- Add ESP if enabled
        if _GlobalEnv.ESPEnabled then
            createESP(npc, _GlobalEnv.NPCHighlightColor)
        end
        
        return true
    end
    
    return false
end

-- Function to update all NPC heads
local function updateAllNPCs()
    for _, npc in pairs(Npc_folder:GetChildren()) do
        if npc:IsA("Model") then
            modifyNPCHead(npc)
        end
    end
end

-- Function to scan for new NPCs automatically
local function setupAutoDetect()
    Npc_folder.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            wait(0.5) -- Wait for model to fully load
            if _GlobalEnv.AutoModifyNPCs then
                modifyNPCHead(child)
                print("🆕 New NPC detected and modified: " .. child.Name)
            end
        end
    end)
    
    -- Also modify existing NPCs
    for _, npc in pairs(Npc_folder:GetChildren()) do
        if npc:IsA("Model") then
            modifyNPCHead(npc)
        end
    end
end

-- ========== CREATE GUI WINDOWS ==========
local mainWindow = library:CreateWindow("🎮 NPC Controller")

-- Head Scale Control
mainWindow:Section("Head Settings")

mainWindow:Box('Head Scale', {
    flag = "HeadSizeInput";
    type = 'number';
    placeholder = tostring(_GlobalEnv.HeadScaleValue);
}, function(newValue)
    local num = tonumber(newValue)
    if num and num >= 1 and num <= 50 then
        _GlobalEnv.HeadScaleValue = num
        updateAllNPCs()
        print("Head scale set to: " .. num)
    end
end)

-- Preset buttons
mainWindow:Button("🎯 Set Scale to 7", function()
    _GlobalEnv.HeadScaleValue = 7
    updateAllNPCs()
    print("Scale set to 7")
end)

mainWindow:Button("💥 Set Scale to 20", function()
    _GlobalEnv.HeadScaleValue = 20
    updateAllNPCs()
    print("Scale set to 20 - HUGE HEADS!")
end)

mainWindow:Button("📏 Reset Scale to 3", function()
    _GlobalEnv.HeadScaleValue = 3
    updateAllNPCs()
    print("Scale reset to 3")
end)

-- ESP Controls
mainWindow:Section("ESP Settings")

mainWindow:Toggle('Enable ESP', {
    flag = "ESPToggle";
    default = _GlobalEnv.ESPEnabled;
}, function(state)
    _GlobalEnv.ESPEnabled = state
    toggleESP(state, _GlobalEnv.NPCHighlightColor)
    print("ESP: " .. (state and "ENABLED" or "DISABLED"))
end)

-- Auto-modify toggle
mainWindow:Toggle('Auto-Modify New NPCs', {
    flag = "AutoModify";
    default = _GlobalEnv.AutoModifyNPCs;
}, function(state)
    _GlobalEnv.AutoModifyNPCs = state
    print("Auto-Modify: " .. (state and "ENABLED" or "DISABLED"))
end)

-- Color Picker for ESP
mainWindow:ColorPicker('ESP Color', {
    flag = "ESPColor";
    color = _GlobalEnv.NPCHighlightColor;
}, function(newColor)
    _GlobalEnv.NPCHighlightColor = newColor
    if _GlobalEnv.ESPEnabled then
        toggleESP(true, newColor)
    end
    print("ESP color updated")
end)

-- Action Buttons
mainWindow:Section("Actions")

mainWindow:Button("🔍 Modify All NPCs Now", function()
    updateAllNPCs()
    print("All NPCs modified!")
end)

mainWindow:Button("🎨 Make Heads Glow", function()
    for _, npc in pairs(Npc_folder:GetChildren()) do
        if npc:IsA("Model") then
            local head = npc:FindFirstChild("Head")
            if head and head:IsA("MeshPart") then
                -- Add/update light
                local light = head:FindFirstChildOfClass("PointLight")
                if not light then
                    light = Instance.new("PointLight")
                    light.Brightness = 3
                    light.Range = 20
                    light.Parent = head
                end
                light.Color = Color3.fromRGB(0, 255, 255)
                light.Brightness = 3
                
                -- Make head neon
                head.Material = Enum.Material.Neon
                head.Color = Color3.fromRGB(0, 255, 255)
            end
        end
    end
    print("Added glow effect to all heads!")
end)

mainWindow:Button("👻 Make Heads Transparent", function()
    for _, npc in pairs(Npc_folder:GetChildren()) do
        if npc:IsA("Model") then
            local head = npc:FindFirstChild("Head")
            if head and head:IsA("MeshPart") then
                head.Transparency = 0.8
                head.Material = Enum.Material.Glass
            end
        end
    end
    print("Made all heads transparent!")
end)

mainWindow:Button("🗑️ Remove ESP Only", function()
    for npc, _ in pairs(ESPBoxes) do
        removeESP(npc)
    end
    print("ESP removed from all NPCs")
end)

-- ========== SETUP AUTO DETECTION ==========
setupAutoDetect()

-- ========== KEYBOARD SHORTCUTS ==========
service.UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        -- Toggle ESP
        _GlobalEnv.ESPEnabled = not _GlobalEnv.ESPEnabled
        toggleESP(_GlobalEnv.ESPEnabled, _GlobalEnv.NPCHighlightColor)
        print("ESP toggled: " .. tostring(_GlobalEnv.ESPEnabled))
    elseif input.KeyCode == Enum.KeyCode.Home then
        -- Increase head size
        _GlobalEnv.HeadScaleValue = math.min(50, _GlobalEnv.HeadScaleValue + 1)
        updateAllNPCs()
        print("Head scale increased to: " .. _GlobalEnv.HeadScaleValue)
    elseif input.KeyCode == Enum.KeyCode.End then
        -- Decrease head size
        _GlobalEnv.HeadScaleValue = math.max(1, _GlobalEnv.HeadScaleValue - 1)
        updateAllNPCs()
        print("Head scale decreased to: " .. _GlobalEnv.HeadScaleValue)
    end
end)

-- ========== INITIAL MESSAGE ==========
print("=======================================")
print("🎮 NPC HEAD MODIFIER ACTIVATED!")
print("=======================================")
print("Head Scale: " .. _GlobalEnv.HeadScaleValue)
print("ESP: " .. tostring(_GlobalEnv.ESPEnabled))
print("Auto-Modify: " .. tostring(_GlobalEnv.AutoModifyNPCs))
print("=======================================")
print("Shortcuts:")
print("Insert - Toggle ESP")
print("Home - Increase Head Size")
print("End - Decrease Head Size")
print("=======================================")

-- Initial modification of all NPCs
task.spawn(function()
    wait(2)
    updateAllNPCs()
    print("✅ Initial NPC modification complete!")
end)
