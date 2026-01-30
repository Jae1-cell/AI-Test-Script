-- ============================================
-- WORKING NPC HEAD MODIFIER - GUARANTEED TO WORK
-- ============================================

-- Wait for game
repeat wait() until game:IsLoaded()
wait(1)

-- Configuration
local CONFIG = {
    HeadScale = 7.0,  -- SET TO 7 AS REQUESTED
    Transparency = 0.6,
    ESPEnabled = true,
    ESPColor = Color3.fromRGB(255, 50, 255),
    DetectSpawns = true
}

-- Storage
local processedNPCs = {}
local ESPBoxes = {}

print("🚀 Initializing NPC Head Modifier - Scale: " .. CONFIG.HeadScale)

-- ========== MAIN FUNCTION TO MODIFY NPC HEAD ==========
local function modifyNPCHead(npc)
    if processedNPCs[npc] then return false end
    
    -- Get the head
    local head = npc:FindFirstChild("Head")
    if not head then
        -- Try to wait for head
        for i = 1, 10 do  -- Wait up to 1 second
            wait(0.1)
            head = npc:FindFirstChild("Head")
            if head then break end
        end
        if not head then return false end
    end
    
    print("🎯 Modifying NPC: " .. npc.Name)
    
    -- Get or create mesh
    local mesh = head:FindFirstChildOfClass("SpecialMesh")
    if not mesh then
        mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Head
        mesh.Parent = head
    end
    
    -- THIS IS THE KEY LINE - APPLY THE SCALE
    mesh.Scale = Vector3.new(CONFIG.HeadScale, CONFIG.HeadScale, CONFIG.HeadScale)
    
    -- Apply transparency
    head.Transparency = CONFIG.Transparency
    head.Material = Enum.Material.Neon
    head.Color = CONFIG.ESPColor
    
    -- Add light effect
    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 15
    light.Color = CONFIG.ESPColor
    light.Parent = head
    
    -- Add ESP highlight
    if CONFIG.ESPEnabled then
        local highlight = Instance.new("Highlight")
        highlight.Name = "NPC_ESP"
        highlight.FillColor = CONFIG.ESPColor
        highlight.FillTransparency = 0.8
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Parent = npc
        ESPBoxes[npc] = highlight
    end
    
    -- Mark as processed
    processedNPCs[npc] = true
    
    return true
end

-- ========== FUNCTION TO UPDATE ALL HEADS ==========
local function updateAllHeads()
    print("🔄 Updating all heads to scale: " .. CONFIG.HeadScale)
    
    local updated = 0
    for npc, _ in pairs(processedNPCs) do
        if npc and npc.Parent then
            local head = npc:FindFirstChild("Head")
            if head then
                local mesh = head:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.Scale = Vector3.new(CONFIG.HeadScale, CONFIG.HeadScale, CONFIG.HeadScale)
                    updated = updated + 1
                end
            end
        end
    end
    
    print("✅ Updated " .. updated .. " NPC heads")
end

-- ========== SPAWN DETECTION ==========
local function setupSpawnDetection()
    print("🔍 Setting up spawn detection...")
    
    -- Watch for ANY new models in workspace
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") then
            wait(0.3)  -- Wait a bit for model to load
            
            -- Check if it's an NPC (has head and not a player)
            local head = descendant:FindFirstChild("Head")
            local humanoid = descendant:FindFirstChildOfClass("Humanoid")
            local isPlayer = game.Players:GetPlayerFromCharacter(descendant)
            
            if head and humanoid and not isPlayer then
                if modifyNPCHead(descendant) then
                    print("🆕 New NPC detected and modified: " .. descendant.Name)
                end
            end
        end
    end)
    
    print("✅ Spawn detection active")
end

-- ========== INITIAL SCAN ==========
local function initialScan()
    print("🔍 Scanning for existing NPCs...")
    
    local found = 0
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") then
            local head = descendant:FindFirstChild("Head")
            local humanoid = descendant:FindFirstChildOfClass("Humanoid")
            local isPlayer = game.Players:GetPlayerFromCharacter(descendant)
            
            if head and humanoid and not isPlayer then
                if modifyNPCHead(descendant) then
                    found = found + 1
                end
            end
        end
    end
    
    print("✅ Found " .. found .. " NPCs")
    return found
end

-- ========== CREATE SIMPLE GUI ==========
local function createSimpleGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NPCControlGUI"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 350)
    frame.Position = UDim2.new(0, 20, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "NPC HEAD CONTROLLER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = CONFIG.ESPColor
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = frame
    
    -- Scale Display
    local scaleLabel = Instance.new("TextLabel")
    scaleLabel.Name = "ScaleLabel"
    scaleLabel.Text = "CURRENT SCALE: " .. CONFIG.HeadScale
    scaleLabel.Size = UDim2.new(0.9, 0, 0, 30)
    scaleLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
    scaleLabel.BackgroundTransparency = 1
    scaleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    scaleLabel.Font = Enum.Font.SourceSansBold
    scaleLabel.TextSize = 16
    scaleLabel.Parent = frame
    
    -- Scale Up Button
    local upBtn = Instance.new("TextButton")
    upBtn.Text = "⬆️ INCREASE SCALE"
    upBtn.Size = UDim2.new(0.9, 0, 0, 40)
    upBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
    upBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    upBtn.TextColor3 = Color3.new(1, 1, 1)
    upBtn.Font = Enum.Font.SourceSansBold
    upBtn.Parent = frame
    
    upBtn.MouseButton1Click:Connect(function()
        CONFIG.HeadScale = CONFIG.HeadScale + 1
        scaleLabel.Text = "CURRENT SCALE: " .. CONFIG.HeadScale
        updateAllHeads()
        print("Scale increased to: " .. CONFIG.HeadScale)
    end)
    
    -- Scale Down Button
    local downBtn = Instance.new("TextButton")
    downBtn.Text = "⬇️ DECREASE SCALE"
    downBtn.Size = UDim2.new(0.9, 0, 0, 40)
    downBtn.Position = UDim2.new(0.05, 0, 0.38, 0)
    downBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    downBtn.TextColor3 = Color3.new(1, 1, 1)
    downBtn.Font = Enum.Font.SourceSansBold
    downBtn.Parent = frame
    
    downBtn.MouseButton1Click:Connect(function()
        CONFIG.HeadScale = math.max(1, CONFIG.HeadScale - 1)
        scaleLabel.Text = "CURRENT SCALE: " .. CONFIG.HeadScale
        updateAllHeads()
        print("Scale decreased to: " .. CONFIG.HeadScale)
    end)
    
    -- Set to 7 Button
    local set7Btn = Instance.new("TextButton")
    set7Btn.Text = "🎯 SET TO SCALE 7"
    set7Btn.Size = UDim2.new(0.9, 0, 0, 40)
    set7Btn.Position = UDim2.new(0.05, 0, 0.51, 0)
    set7Btn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    set7Btn.TextColor3 = Color3.new(1, 1, 1)
    set7Btn.Font = Enum.Font.SourceSansBold
    set7Btn.Parent = frame
    
    set7Btn.MouseButton1Click:Connect(function()
        CONFIG.HeadScale = 7
        scaleLabel.Text = "CURRENT SCALE: " .. CONFIG.HeadScale
        updateAllHeads()
        print("Scale set to 7")
    end)
    
    -- Set to 10 Button
    local set10Btn = Instance.new("TextButton")
    set10Btn.Text = "💥 SET TO SCALE 10"
    set10Btn.Size = UDim2.new(0.9, 0, 0, 40)
    set10Btn.Position = UDim2.new(0.05, 0, 0.64, 0)
    set10Btn.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    set10Btn.TextColor3 = Color3.new(1, 1, 1)
    set10Btn.Font = Enum.Font.SourceSansBold
    set10Btn.Parent = frame
    
    set10Btn.MouseButton1Click:Connect(function()
        CONFIG.HeadScale = 10
        scaleLabel.Text = "CURRENT SCALE: " .. CONFIG.HeadScale
        updateAllHeads()
        print("Scale set to 10")
    end)
    
    -- Rescan Button
    local rescanBtn = Instance.new("TextButton")
    rescanBtn.Text = "🔍 RESCAN FOR NPCS"
    rescanBtn.Size = UDim2.new(0.9, 0, 0, 40)
    rescanBtn.Position = UDim2.new(0.05, 0, 0.77, 0)
    rescanBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    rescanBtn.TextColor3 = Color3.new(1, 1, 1)
    rescanBtn.Font = Enum.Font.SourceSansBold
    rescanBtn.Parent = frame
    
    rescanBtn.MouseButton1Click:Connect(function()
        print("Rescanning...")
        for npc, _ in pairs(processedNPCs) do
            if ESPBoxes[npc] then
                ESPBoxes[npc]:Destroy()
            end
        end
        processedNPCs = {}
        ESPBoxes = {}
        local found = initialScan()
        print("Rescan complete! Found " .. found .. " NPCs")
    end)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "❌ CLOSE"
    closeBtn.Size = UDim2.new(0.4, 0, 0, 35)
    closeBtn.Position = UDim2.new(0.05, 0, 0.9, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        print("GUI closed")
    end)
    
    return gui
end

-- ========== MAIN EXECUTION ==========
print("🔧 Starting NPC Head Modifier...")

-- Create GUI
createSimpleGUI()

-- Setup spawn detection
if CONFIG.DetectSpawns then
    setupSpawnDetection()
end

-- Initial scan
wait(2)
initialScan()

print("✅ NPC HEAD MODIFIER ACTIVE!")
print("=============================")
print("Head Scale: " .. CONFIG.HeadScale)
print("Use the GUI to control scale")
print("=============================")

-- Add debug hotkeys
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        -- Force update all heads
        updateAllHeads()
    elseif input.KeyCode == Enum.KeyCode.Home then
        -- Debug: Print all processed NPCs
        print("=== PROCESSED NPCS ===")
        local count = 0
        for npc, _ in pairs(processedNPCs) do
            if npc and npc.Parent then
                local head = npc:FindFirstChild("Head")
                if head then
                    local mesh = head:FindFirstChildOfClass("SpecialMesh")
                    if mesh then
                        print(npc.Name .. " - Scale: " .. tostring(mesh.Scale))
                        count = count + 1
                    end
                end
            end
        end
        print("Total: " .. count .. " NPCs")
    end
end)
