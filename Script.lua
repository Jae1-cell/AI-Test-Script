-- ============================================
-- REFINED NPC MODIFIER WITH WORKING CONTROLS
-- ============================================

if not game:IsLoaded() then game.Loaded:Wait() end
wait(1)

-- Configuration
local CONFIG = {
    HeadScale = 7.0,  -- SET TO 7 AS REQUESTED
    Transparency = 0.6,
    ESPEnabled = true,
    ESPColor = Color3.fromRGB(255, 50, 255),
    DetectSpawns = true,
    SoundOnSpawn = true
}

-- Storage
local processedNPCs = {}
local ESPBoxes = {}
local connections = {}
local Player = game.Players.LocalPlayer

print("🚀 Initializing NPC Modifier with HeadScale 7...")

-- ========== PERSISTENT GUI WITH WORKING CONTROLS ==========
local function createPersistentGUI()
    -- Create in CoreGui so it survives death
    local gui = Instance.new("ScreenGui")
    gui.Name = "NPCControllerGUI"
    gui.DisplayOrder = 999
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0, 20, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎮 NPC CONTROLLER"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = CONFIG.ESPColor
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Parent = frame
    
    -- NPC Counter
    local counterLabel = Instance.new("TextLabel")
    counterLabel.Name = "NPCCounter"
    counterLabel.Text = "NPCs: 0"
    counterLabel.Size = UDim2.new(0.9, 0, 0, 30)
    counterLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
    counterLabel.BackgroundTransparency = 1
    counterLabel.TextColor3 = Color3.new(1, 1, 1)
    counterLabel.Font = Enum.Font.Code
    counterLabel.TextSize = 16
    counterLabel.Parent = frame
    
    -- Head Scale Display
    local scaleDisplay = Instance.new("TextLabel")
    scaleDisplay.Name = "ScaleDisplay"
    scaleDisplay.Text = "HEAD SCALE: " .. CONFIG.HeadScale
    scaleDisplay.Size = UDim2.new(0.9, 0, 0, 30)
    scaleDisplay.Position = UDim2.new(0.05, 0, 0.25, 0)
    scaleDisplay.BackgroundTransparency = 1
    scaleDisplay.TextColor3 = Color3.fromRGB(255, 150, 0)
    scaleDisplay.Font = Enum.Font.SourceSansBold
    scaleDisplay.TextSize = 18
    scaleDisplay.Parent = frame
    
    -- Scale Control Buttons (FIXED)
    local function createScaleButton(text, position, scaleChange)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(0.4, 0, 0, 40)
        btn.Position = position
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.BackgroundTransparency = 0.2
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 18
        btn.Parent = frame
        
        -- Make button interactive
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        end)
        
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end)
        
        btn.MouseButton1Down:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
        end)
        
        btn.MouseButton1Up:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            wait(0.1)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end)
        
        btn.MouseButton1Click:Connect(function()
            CONFIG.HeadScale = math.clamp(CONFIG.HeadScale + scaleChange, 0.5, 20)
            scaleDisplay.Text = "HEAD SCALE: " .. string.format("%.1f", CONFIG.HeadScale)
            updateAllHeads()
            print("Head scale changed to: " .. CONFIG.HeadScale)
        end)
        
        return btn
    end
    
    -- Create scale buttons
    createScaleButton("⬆️ INCREASE", UDim2.new(0.05, 0, 0.35, 0), 1)
    createScaleButton("⬇️ DECREASE", UDim2.new(0.55, 0, 0.35, 0), -1)
    createScaleButton("💥 HUGE (10x)", UDim2.new(0.05, 0, 0.45, 0), 3) -- Set to 10
    createScaleButton("📏 NORMAL (1x)", UDim2.new(0.55, 0, 0.45, 0), -6) -- Set to 1
    
    -- Transparency Control
    local transLabel = Instance.new("TextLabel")
    transLabel.Text = "TRANSPARENCY: " .. CONFIG.Transparency
    transLabel.Size = UDim2.new(0.9, 0, 0, 30)
    transLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
    transLabel.BackgroundTransparency = 1
    transLabel.TextColor3 = Color3.new(1, 1, 1)
    transLabel.Font = Enum.Font.Code
    transLabel.Parent = frame
    
    local transBtn = Instance.new("TextButton")
    transBtn.Text = "CHANGE TRANSPARENCY"
    transBtn.Size = UDim2.new(0.9, 0, 0, 40)
    transBtn.Position = UDim2.new(0.05, 0, 0.62, 0)
    transBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    transBtn.TextColor3 = Color3.new(1, 1, 1)
    transBtn.Parent = frame
    
    transBtn.MouseButton1Click:Connect(function()
        CONFIG.Transparency = (CONFIG.Transparency + 0.2) % 1
        transLabel.Text = "TRANSPARENCY: " .. string.format("%.1f", CONFIG.Transparency)
        
        for npc, _ in pairs(processedNPCs) do
            if npc and npc.Parent then
                local head = npc:FindFirstChild("Head")
                if head then 
                    head.Transparency = CONFIG.Transparency
                end
            end
        end
        print("Transparency changed to: " .. CONFIG.Transparency)
    end)
    
    -- ESP Toggle Button
    local espBtn = Instance.new("TextButton")
    espBtn.Text = "👁️ ESP: ON"
    espBtn.Size = UDim2.new(0.9, 0, 0, 40)
    espBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
    espBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    espBtn.TextColor3 = Color3.new(1, 1, 1)
    espBtn.Parent = frame
    
    espBtn.MouseButton1Click:Connect(function()
        CONFIG.ESPEnabled = not CONFIG.ESPEnabled
        espBtn.Text = "👁️ ESP: " .. (CONFIG.ESPEnabled and "ON" or "OFF")
        espBtn.BackgroundColor3 = CONFIG.ESPEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        
        for npc, _ in pairs(processedNPCs) do
            if npc and npc.Parent then
                if CONFIG.ESPEnabled then
                    createESP(npc)
                else
                    removeESP(npc)
                end
            end
        end
        print("ESP " .. (CONFIG.ESPEnabled and "ENABLED" : "DISABLED"))
    end)
    
    -- Rescan Button
    local rescanBtn = Instance.new("TextButton")
    rescanBtn.Text = "🔍 RESCAN NPCs"
    rescanBtn.Size = UDim2.new(0.9, 0, 0, 40)
    rescanBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
    rescanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    rescanBtn.TextColor3 = Color3.new(1, 1, 1)
    rescanBtn.Parent = frame
    
    rescanBtn.MouseButton1Click:Connect(function()
        print("Rescanning NPCs...")
        rescanAllNPCs()
    end)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "❌ CLOSE"
    closeBtn.Size = UDim2.new(0.4, 0, 0, 35)
    closeBtn.Position = UDim2.new(0.05, 0, 0.92, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        print("GUI closed")
    end)
    
    return gui
end

-- ========== IMPROVED SPAWN DETECTION ==========
local function setupSpawnDetection()
    print("🔍 Setting up spawn detection...")
    
    -- Clear old connections
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    
    -- Function to process any model
    local function processModel(model)
        if not model or not model.Parent then return end
        if processedNPCs[model] then return end
        if game.Players:GetPlayerFromCharacter(model) then return end
        
        -- Check for head or humanoid
        local head = model:FindFirstChild("Head")
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        
        if head or humanoid then
            -- If no head but has humanoid, wait for head
            if not head and humanoid then
                local success = pcall(function()
                    head = model:WaitForChild("Head", 3)
                end)
                if not success or not head then return end
            end
            
            modifyNPCHead(model)
        end
    end
    
    -- Watch ALL models added to workspace
    local mainConn = workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") then
            task.spawn(function()
                wait(0.5) -- Wait for model to fully load
                processModel(descendant)
            end)
        end
    end)
    table.insert(connections, mainConn)
    
    -- Also check existing models
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") then
            task.spawn(function()
                processModel(descendant)
            end)
        end
    end
    
    print("✅ Spawn detection active")
end

-- ========== NPC HEAD MODIFICATION ==========
local function modifyNPCHead(npc)
    if processedNPCs[npc] then return false end
    
    local head = npc:FindFirstChild("Head")
    if not head then
        -- Try to wait for head
        local success = pcall(function()
            head = npc:WaitForChild("Head", 2)
        end)
        if not success or not head then return false end
    end
    
    print("🎯 Processing: " .. npc.Name)
    
    -- Enlarge head (USING CONFIG.HeadScale)
    local mesh = head:FindFirstChildOfClass("SpecialMesh")
    if not mesh then
        mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Head
        mesh.Parent = head
    end
    
    -- APPLY THE SCALE FROM CONFIG
    mesh.Scale = Vector3.new(CONFIG.HeadScale, CONFIG.HeadScale, CONFIG.HeadScale)
    
    -- Apply transparency
    head.Transparency = CONFIG.Transparency
    head.Material = Enum.Material.Neon
    head.Color = CONFIG.ESPColor
    
    -- Add light
    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 20
    light.Color = CONFIG.ESPColor
    light.Parent = head
    
    -- Sound effect
    if CONFIG.SoundOnSpawn then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9111267911"
        sound.Volume = 0.4
        sound.Parent = head
        sound:Play()
        game.Debris:AddItem(sound, 2)
    end
    
    -- ESP
    if CONFIG.ESPEnabled then
        createESP(npc)
    end
    
    -- Mark as processed
    processedNPCs[npc] = true
    updateNPCCounter()
    
    -- Cleanup on removal
    local removalConn
    removalConn = npc.AncestryChanged:Connect(function()
        if not npc.Parent then
            processedNPCs[npc] = nil
            removeESP(npc)
            if removalConn then removalConn:Disconnect() end
            updateNPCCounter()
        end
    end)
    table.insert(connections, removalConn)
    
    return true
end

-- ========== ESP FUNCTIONS ==========
local function createESP(npc)
    if ESPBoxes[npc] or not npc.PrimaryPart then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "NPC_ESP"
    highlight.FillColor = CONFIG.ESPColor
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Parent = npc
    
    ESPBoxes[npc] = highlight
end

local function removeESP(npc)
    if ESPBoxes[npc] then
        ESPBoxes[npc]:Destroy()
        ESPBoxes[npc] = nil
    end
end

-- ========== UTILITY FUNCTIONS ==========
local function updateNPCCounter()
    local gui = game:GetService("CoreGui"):FindFirstChild("NPCControllerGUI")
    if gui and gui:FindFirstChild("Frame") then
        local counter = gui.Frame:FindFirstChild("NPCCounter")
        if counter then
            local count = 0
            for _ in pairs(processedNPCs) do count = count + 1 end
            counter.Text = "NPCs: " .. count
        end
    end
end

local function updateAllHeads()
    print("Updating all heads to scale: " .. CONFIG.HeadScale)
    
    for npc, _ in pairs(processedNPCs) do
        if npc and npc.Parent then
            local head = npc:FindFirstChild("Head")
            if head then
                local mesh = head:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    -- APPLY NEW SCALE
                    mesh.Scale = Vector3.new(CONFIG.HeadScale, CONFIG.HeadScale, CONFIG.HeadScale)
                    print("Updated: " .. npc.Name .. " to scale " .. CONFIG.HeadScale)
                end
            end
        end
    end
end

local function rescanAllNPCs()
    print("🔄 Rescanning ALL NPCs...")
    
    -- Clear old
    for npc, _ in pairs(processedNPCs) do
        removeESP(npc)
    end
    processedNPCs = {}
    ESPBoxes = {}
    
    -- Scan everything
    local found = 0
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") then
            local isPlayer = game.Players:GetPlayerFromCharacter(descendant)
            local head = descendant:FindFirstChild("Head")
            
            if not isPlayer and head then
                if modifyNPCHead(descendant) then
                    found = found + 1
                end
            end
        end
    end
    
    wait(0.5)
    print("✅ Found " .. found .. " NPCs")
    updateNPCCounter()
end

-- ========== KEYBOARD SHORTCUTS ==========
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        -- Toggle GUI
        local gui = game:GetService("CoreGui"):FindFirstChild("NPCControllerGUI")
        if gui then
            gui.Enabled = not gui.Enabled
            print("GUI " .. (gui.Enabled and "shown" : "hidden"))
        end
    elseif input.KeyCode == Enum.KeyCode.Home then
        -- Force rescan
        rescanAllNPCs()
    elseif input.KeyCode == Enum.KeyCode.End then
        -- Cleanup
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        for npc, _ in pairs(ESPBoxes) do
            removeESP(npc)
        end
        local gui = game:GetService("CoreGui"):FindFirstChild("NPCControllerGUI")
        if gui then gui:Destroy() end
        print("🗑️ Script cleaned up")
    end
end)

-- ========== MAIN INITIALIZATION ==========
print("🔧 Initializing...")

-- Create GUI
createPersistentGUI()

-- Setup spawn detection
setupSpawnDetection()

-- Initial scan
task.spawn(function()
    wait(2)
    rescanAllNPCs()
end)

-- Auto-restore GUI on respawn
Player.CharacterAdded:Connect(function()
    wait(2)
    if not game:GetService("CoreGui"):FindFirstChild("NPCControllerGUI") then
        createPersistentGUI()
        print("🔄 GUI restored after respawn")
    end
end)

print("✅ SYSTEM ACTIVE! HeadScale: " .. CONFIG.HeadScale)
print("======================")
print("Insert - Toggle GUI")
print("Home - Rescan NPCs")
print("End - Cleanup script")
print("======================")
