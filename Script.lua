-- ============================================
-- FIXED SPAWN DETECTION NPC MODIFIER
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

-- Track if we're already modifying an NPC to avoid duplicates
local modifyingNPCs = {}

-- IMPROVED: Function to modify NPC head with multiple methods
local function modifyNPCHead(npc)
    if not npc or not npc.Parent then return false end
    if modifyingNPCs[npc] then return false end -- Already modifying this NPC
    if processedNPCs[npc] then return true end -- Already processed
    
    modifyingNPCs[npc] = true
    
    -- Wait a bit for the NPC to fully load
    task.wait(0.3)
    
    local head = npc:FindFirstChild("Head")
    if not head then
        -- Try waiting for head to appear
        for i = 1, 10 do
            task.wait(0.1)
            head = npc:FindFirstChild("Head")
            if head then break end
        end
    end
    
    if not head then
        print("❌ No head found for NPC: " .. npc.Name)
        modifyingNPCs[npc] = nil
        return false
    end
    
    print("🎯 Modifying NPC: " .. npc.Name)
    
    -- Apply scale
    if head:IsA("MeshPart") or head:IsA("Part") then
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
        
        -- Clean up modifying flag
        modifyingNPCs[npc] = nil
        
        print("✅ Successfully modified: " .. npc.Name)
        return true
    end
    
    modifyingNPCs[npc] = nil
    print("❌ Head is not a MeshPart: " .. npc.Name)
    return false
end

-- Function to update all NPC heads
local function updateAllNPCs()
    print("🔄 Updating all NPCs...")
    local modified = 0
    
    for _, npc in pairs(Npc_folder:GetChildren()) do
        if npc:IsA("Model") then
            if modifyNPCHead(npc) then
                modified = modified + 1
            end
        end
    end
    
    print("✅ Updated " .. modified .. " NPCs")
end

-- FIXED: Function to scan for new NPCs automatically
local function setupAutoDetect()
    print("🔍 Setting up auto-detection...")
    
    -- Clear any old connections
    if _GlobalEnv.NPCConnections then
        for _, conn in pairs(_GlobalEnv.NPCConnections) do
            conn:Disconnect()
        end
    end
    
    _GlobalEnv.NPCConnections = {}
    
    -- Function to handle new NPCs
    local function handleNewNPC(child)
        if not child:IsA("Model") then return end
        
        task.wait(0.5) -- Wait for model to fully load
        
        if not _GlobalEnv.AutoModifyNPCs then
            print("⚠️ Auto-modify disabled, skipping: " .. child.Name)
            return
        end
        
        if processedNPCs[child] then
            print("⚠️ Already processed: " .. child.Name)
            return
        end
        
        print("🆕 New NPC detected: " .. child.Name)
        modifyNPCHead(child)
    end
    
    -- Watch the NPC folder for new additions
    local conn1 = Npc_folder.ChildAdded:Connect(handleNewNPC)
    table.insert(_GlobalEnv.NPCConnections, conn1)
    
    -- Also watch for descendants in case NPCs are added deeper
    local conn2 = Npc_folder.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") and descendant.Parent == Npc_folder then
            handleNewNPC(descendant)
        end
    end)
    table.insert(_GlobalEnv.NPCConnections, conn2)
    
    -- Modify existing NPCs
    print("🔍 Processing existing NPCs...")
    local existingModified = 0
    for _, npc in pairs(Npc_folder:GetChildren()) do
        if npc:IsA("Model") then
            if modifyNPCHead(npc) then
                existingModified = existingModified + 1
            end
        end
    end
    
    print("✅ Auto-detection setup complete!")
    print("📊 Existing NPCs modified: " .. existingModified)
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

-- Auto-modify toggle - FIXED
mainWindow:Toggle('Auto-Modify New NPCs', {
    flag = "AutoModify";
    default = _GlobalEnv.AutoModifyNPCs;
}, function(state)
    _GlobalEnv.AutoModifyNPCs = state
    if state then
        print("✅ Auto-modify ENABLED - Watching for new NPCs")
        -- When enabled, also check for any NPCs we might have missed
        task.spawn(function()
            task.wait(1)
            for _, npc in pairs(Npc_folder:GetChildren()) do
                if npc:IsA("Model") and not processedNPCs[npc] then
                    modifyNPCHead(npc)
                end
            end
        end)
    else
        print("⛔ Auto-modify DISABLED - Not watching for new NPCs")
    end
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

mainWindow:Button("🔄 Force Check for New NPCs", function()
    print("🔄 Force checking for unmodified NPCs...")
    local newlyFound = 0
    for _, npc in pairs(Npc_folder:GetChildren()) do
        if npc:IsA("Model") and not processedNPCs[npc] then
            if modifyNPCHead(npc) then
                newlyFound = newlyFound + 1
            end
        end
    end
    print("✅ Found " .. newlyFound .. " new NPCs")
end)

mainWindow:Button("🎨 Make Heads Glow", function()
    for _, npc in pairs(Npc_folder:GetChildren()) do
        if npc:IsA("Model") then
            local head = npc:FindFirstChild("Head")
            if head and (head:IsA("MeshPart") or head:IsA("Part")) then
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
            if head and (head:IsA("MeshPart") or head:IsA("Part")) then
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

mainWindow:Button("🔧 Reinitialize Auto-Detect", function()
    setupAutoDetect()
    print("Auto-detection reinitialized!")
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
    elseif input.KeyCode == Enum.KeyCode.PageUp then
        -- Force check for new NPCs
        local newlyFound = 0
        for _, npc in pairs(Npc_folder:GetChildren()) do
            if npc:IsA("Model") and not processedNPCs[npc] then
                if modifyNPCHead(npc) then
                    newlyFound = newlyFound + 1
                end
            end
        end
        print("Force check found " .. newlyFound .. " new NPCs")
    end
end)

-- ========== INITIAL MESSAGE ==========
print("=======================================")
print("🎮 FIXED NPC HEAD MODIFIER ACTIVATED!")
print("=======================================")
print("Head Scale: " .. _GlobalEnv.HeadScaleValue)
print("ESP: " .. tostring(_GlobalEnv.ESPEnabled))
print("Auto-Modify: " .. tostring(_GlobalEnv.AutoModifyNPCs))
print("=======================================")
print("Shortcuts:")
print("Insert - Toggle ESP")
print("Home - Increase Head Size")
print("End - Decrease Head Size")
print("PageUp - Force Check for New NPCs")
print("=======================================")

-- Initial modification of all NPCs
task.spawn(function()
    wait(3)
    updateAllNPCs()
    print("✅ Initial NPC modification complete!")
end)

-- Periodic check for missed NPCs
task.spawn(function()
    while true do
        task.wait(10) -- Check every 10 seconds
        if _GlobalEnv.AutoModifyNPCs then
            local newlyFound = 0
            for _, npc in pairs(Npc_folder:GetChildren()) do
                if npc:IsA("Model") and not processedNPCs[npc] then
                    if modifyNPCHead(npc) then
                        newlyFound = newlyFound + 1
                    end
                end
            end
            if newlyFound > 0 then
                print("🔄 Periodic check found " .. newlyFound .. " new NPCs")
            end
        end
    end
end)
