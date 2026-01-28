-- ============================================
-- COMPLETE NPC HEAD MODIFIER + SPAWN DETECTION + ESP
-- ============================================

if not game:IsLoaded() then game.Loaded:Wait() end
wait(2)

-- Configuration
local CONFIG = {
    HeadScale = 6.0,              -- How much bigger the head is
    Transparency = 0.6,           -- Head transparency (0-1)
    ESPEnabled = true,            -- Enable ESP boxes
    ESPColor = Color3.fromRGB(255, 50, 255), -- ESP color
    ESPTransparency = 0.3,        -- ESP transparency
    DetectSpawns = true,          -- Auto-detect new NPC spawns
    SoundOnSpawn = true,          -- Play sound when new NPC spawns
    HighlightEffect = true,       -- Add highlight to NPCs
    PulseEffect = false           -- Make heads pulse
}

-- Storage
local processedNPCs = {}
local ESPBoxes = {}
local connections = {}

print("🚀 Initializing NPC Head Modifier...")

-- ========== ESP FUNCTIONS ==========
local function createESP(npc)
    if not CONFIG.ESPEnabled or not npc.PrimaryPart then return end
    
    local esp = Instance.new("BoxHandleAdornment")
    esp.Name = "NPC_ESP"
    esp.Adornee = npc
    esp.AlwaysOnTop = true
    esp.ZIndex = 10
    esp.Size = npc.PrimaryPart.Size + Vector3.new(0.5, 0.5, 0.5)
    esp.Color3 = CONFIG.ESPColor
    esp.Transparency = CONFIG.ESPTransparency
    esp.Parent = npc
    
    -- Add distance text
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NPC_Distance"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = npc
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = CONFIG.ESPColor
    label.TextStrokeTransparency = 0
    label.Text = npc.Name
    label.Font = Enum.Font.SciFi
    label.TextSize = 14
    label.Parent = billboard
    
    ESPBoxes[npc] = {esp, billboard}
    
    -- Update distance periodically
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            spawn(function()
                while npc and npc.Parent and ESPBoxes[npc] do
                    local npcHrp = npc:FindFirstChild("HumanoidRootPart")
                    if npcHrp then
                        local distance = (hrp.Position - npcHrp.Position).Magnitude
                        label.Text = string.format("%s\n[%d studs]", npc.Name, math.floor(distance))
                    end
                    wait(0.5)
                end
            end)
        end
    end
end

local function removeESP(npc)
    if ESPBoxes[npc] then
        for _, obj in ipairs(ESPBoxes[npc]) do
            if obj then obj:Destroy() end
        end
        ESPBoxes[npc] = nil
    end
end

-- ========== HEAD MODIFICATION FUNCTION ==========
local function modifyNPCHead(npc)
    if processedNPCs[npc] then return end
    
    local head = npc:FindFirstChild("Head")
    if not head then
        -- Wait for head to load
        local humanoid = npc:FindFirstChildOfClass("Humanoid")
        if humanoid then
            npc.ChildAdded:Connect(function(child)
                if child.Name == "Head" then
                    wait(0.1)
                    modifyNPCHead(npc)
                end
            end)
        end
        return
    end
    
    print("🎯 Processing NPC: " .. npc.Name)
    
    -- Enlarge head
    local mesh = head:FindFirstChildOfClass("SpecialMesh")
    if not mesh then
        mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Head
        mesh.Parent = head
    end
    mesh.Scale = Vector3.new(CONFIG.HeadScale, CONFIG.HeadScale, CONFIG.HeadScale)
    head.Size = head.Size * CONFIG.HeadScale
    
    -- Apply transparency
    head.Transparency = CONFIG.Transparency
    head.Material = Enum.Material.Neon
    head.Color = CONFIG.ESPColor
    
    -- Add glow
    local light = Instance.new("PointLight")
    light.Brightness = 1.5
    light.Range = 15
    light.Color = CONFIG.ESPColor
    light.Parent = head
    
    -- Add highlight
    if CONFIG.HighlightEffect then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = CONFIG.ESPColor
        highlight.FillTransparency = 0.8
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Parent = npc
    end
    
    -- Add sound effect
    if CONFIG.SoundOnSpawn then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9111267911" -- Woosh sound
        sound.Volume = 0.3
        sound.Parent = head
        sound:Play()
        game.Debris:AddItem(sound, 2)
    end
    
    -- Create ESP
    createESP(npc)
    
    -- Mark as processed
    processedNPCs[npc] = true
    
    -- Setup cleanup on NPC removal
    local conn = npc.AncestryChanged:Connect(function()
        if not npc.Parent then
            removeESP(npc)
            processedNPCs[npc] = nil
            conn:Disconnect()
        end
    end)
    table.insert(connections, conn)
end

-- ========== SPAWN DETECTION ==========
local function setupSpawnDetection()
    if not CONFIG.DetectSpawns then return end
    
    print("🔍 Setting up NPC spawn detection...")
    
    -- Monitor all existing folders
    for _, folder in pairs(workspace:GetChildren()) do
        if folder:IsA("Folder") then
            -- Process existing NPCs in folder
            for _, npc in pairs(folder:GetChildren()) do
                if npc:IsA("Model") and not game.Players:GetPlayerFromCharacter(npc) then
                    modifyNPCHead(npc)
                end
            end
            
            -- Watch for new NPCs added to folder
            local conn = folder.ChildAdded:Connect(function(child)
                wait(0.5) -- Wait for NPC to fully load
                if child:IsA("Model") and not game.Players:GetPlayerFromCharacter(child) then
                    print("🆕 New NPC detected: " .. child.Name)
                    modifyNPCHead(child)
                end
            end)
            table.insert(connections, conn)
        end
    end
    
    -- Also watch for new folders
    local folderConn = workspace.ChildAdded:Connect(function(child)
        if child:IsA("Folder") then
            wait(1)
            print("📁 New folder detected: " .. child.Name)
            
            -- Process existing NPCs in new folder
            for _, npc in pairs(child:GetChildren()) do
                if npc:IsA("Model") and not game.Players:GetPlayerFromCharacter(npc) then
                    modifyNPCHead(npc)
                end
            end
            
            -- Watch for new NPCs in new folder
            local conn = child.ChildAdded:Connect(function(newChild)
                wait(0.5)
                if newChild:IsA("Model") and not game.Players:GetPlayerFromCharacter(newChild) then
                    print("🆕 New NPC in " .. child.Name .. ": " .. newChild.Name)
                    modifyNPCHead(newChild)
                end
            end)
            table.insert(connections, conn)
        end
    end)
    table.insert(connections, folderConn)
end

-- ========== PULSE EFFECT ==========
local function setupPulseEffect()
    if not CONFIG.PulseEffect then return end
    
    spawn(function()
        while wait(0.1) do
            for npc, _ in pairs(processedNPCs) do
                if npc and npc.Parent then
                    local head = npc:FindFirstChild("Head")
                    if head then
                        local pulse = math.sin(tick() * 3) * 0.2 + 0.8
                        head.Transparency = 0.3 + (pulse * 0.4)
                        
                        local mesh = head:FindFirstChildOfClass("SpecialMesh")
                        if mesh then
                            local scalePulse = math.sin(tick() * 2) * 0.1
                            mesh.Scale = Vector3.new(
                                CONFIG.HeadScale + scalePulse,
                                CONFIG.HeadScale + scalePulse,
                                CONFIG.HeadScale + scalePulse
                            )
                        end
                    end
                end
            end
        end
    end)
end

-- ========== CONTROL FUNCTIONS ==========
local function toggleESP(enabled)
    CONFIG.ESPEnabled = enabled
    for npc, _ in pairs(processedNPCs) do
        if npc and npc.Parent then
            if enabled then
                createESP(npc)
            else
                removeESP(npc)
            end
        end
    end
    print("ESP " .. (enabled and "ENABLED" or "DISABLED"))
end

local function changeHeadScale(newScale)
    CONFIG.HeadScale = newScale
    for npc, _ in pairs(processedNPCs) do
        local head = npc and npc.Parent and npc:FindFirstChild("Head")
        if head then
            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                mesh.Scale = Vector3.new(newScale, newScale, newScale)
                head.Size = head.Size * (newScale / CONFIG.HeadScale)
            end
        end
    end
    print("Head scale changed to: " .. newScale)
end

-- ========== GUI CONTROLS ==========
local function createControlGUI()
    local player = game.Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "NPCControllerGUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 300)
    frame.Position = UDim2.new(0, 10, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "NPC Controller"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = CONFIG.ESPColor
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SciFi
    title.TextSize = 18
    title.Parent = frame
    
    -- Toggle ESP button
    local espBtn = Instance.new("TextButton")
    espBtn.Text = "Toggle ESP"
    espBtn.Size = UDim2.new(0.8, 0, 0, 35)
    espBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
    espBtn.BackgroundColor3 = CONFIG.ESPColor
    espBtn.TextColor3 = Color3.new(1, 1, 1)
    espBtn.Parent = frame
    espBtn.MouseButton1Click:Connect(function()
        CONFIG.ESPEnabled = not CONFIG.ESPEnabled
        toggleESP(CONFIG.ESPEnabled)
        espBtn.Text = "ESP: " .. (CONFIG.ESPEnabled and "ON" or "OFF")
    end)
    
    -- Scale controls
    local scaleLabel = Instance.new("TextLabel")
    scaleLabel.Text = "Head Scale: " .. CONFIG.HeadScale
    scaleLabel.Size = UDim2.new(0.8, 0, 0, 25)
    scaleLabel.Position = UDim2.new(0.1, 0, 0.4, 0)
    scaleLabel.BackgroundTransparency = 1
    scaleLabel.TextColor3 = Color3.new(1, 1, 1)
    scaleLabel.Parent = frame
    
    local function updateScale(value)
        local newScale = math.clamp(value, 0.5, 10)
        changeHeadScale(newScale)
        scaleLabel.Text = "Head Scale: " .. string.format("%.1f", newScale)
    end
    
    local scaleUp = Instance.new("TextButton")
    scaleUp.Text = "+"
    scaleUp.Size = UDim2.new(0.35, 0, 0, 30)
    scaleUp.Position = UDim2.new(0.1, 0, 0.5, 0)
    scaleUp.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    scaleUp.Parent = frame
    scaleUp.MouseButton1Click:Connect(function()
        updateScale(CONFIG.HeadScale + 0.5)
    end)
    
    local scaleDown = Instance.new("TextButton")
    scaleDown.Text = "-"
    scaleDown.Size = UDim2.new(0.35, 0, 0, 30)
    scaleDown.Position = UDim2.new(0.55, 0, 0.5, 0)
    scaleDown.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    scaleDown.Parent = frame
    scaleDown.MouseButton1Click:Connect(function()
        updateScale(CONFIG.HeadScale - 0.5)
    end)
    
    -- Transparency control
    local transLabel = Instance.new("TextLabel")
    transLabel.Text = "Transparency: " .. CONFIG.Transparency
    transLabel.Size = UDim2.new(0.8, 0, 0, 25)
    transLabel.Position = UDim2.new(0.1, 0, 0.65, 0)
    transLabel.BackgroundTransparency = 1
    transLabel.TextColor3 = Color3.new(1, 1, 1)
    transLabel.Parent = frame
    
    local transSlider = Instance.new("TextButton")
    transSlider.Text = "Change Transparency"
    transSlider.Size = UDim2.new(0.8, 0, 0, 35)
    transSlider.Position = UDim2.new(0.1, 0, 0.75, 0)
    transSlider.BackgroundColor3 = CONFIG.ESPColor
    transSlider.Parent = frame
    transSlider.MouseButton1Click:Connect(function()
        CONFIG.Transparency = (CONFIG.Transparency + 0.2) % 1
        for npc, _ in pairs(processedNPCs) do
            local head = npc and npc.Parent and npc:FindFirstChild("Head")
            if head then head.Transparency = CONFIG.Transparency end
        end
        transLabel.Text = "Transparency: " .. string.format("%.1f", CONFIG.Transparency)
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ========== MAIN INITIALIZATION ==========
print("🔧 Initializing...")

-- Setup spawn detection
setupSpawnDetection()

-- Setup pulse effect if enabled
setupPulseEffect()

-- Create control GUI
createControlGUI()

-- Initial scan of existing NPCs
for _, folder in pairs(workspace:GetChildren()) do
    if folder:IsA("Folder") then
        for _, npc in pairs(folder:GetChildren()) do
            if npc:IsA("Model") and not game.Players:GetPlayerFromCharacter(npc) then
                modifyNPCHead(npc)
            end
        end
    end
end

-- Cleanup on script stop
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        for npc, _ in pairs(ESPBoxes) do
            removeESP(npc)
        end
        print("🗑️ Cleaned up all connections and ESP")
    end
end)

print("✅ NPC Head Modifier + ESP + Spawn Detection ACTIVE!")
print("📊 NPCs Processed: " .. #processedNPCs)
print("🎮 Press 'P' to cleanup")
print("======================================")
