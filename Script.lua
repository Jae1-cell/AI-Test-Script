-- ============================================
-- COMPATIBLE NPC MODIFIER - FIXED FOR ALL ROBLOX VERSIONS
-- ============================================

-- Wait for game to load (compatible method)
repeat wait() until game:IsLoaded()
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

-- ========== PERSISTENT GUI ==========
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
    
    -- Function to update all heads
    local function updateAllHeads()
        for npc, _ in pairs(processedNPCs) do
            if npc and npc.Parent then
                local head = npc:FindFirstChild("Head")
                if head then
                    local mesh = head:FindFirstChildOfClass("SpecialMesh")
                    if mesh then
                        mesh.Scale = Vector3.new(CONFIG.HeadScale, CONFIG.HeadScale, CONFIG.HeadScale)
                    end
                end
            end
        end
        print("Updated all heads to scale: " .. CONFIG.HeadScale)
    end
    
    -- Scale Control Buttons
    local function createScaleButton(text, position, scaleChange, isAbsolute)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(0.4, 0, 0, 40)
        btn.Position = position
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            if isAbsolute then
                CONFIG.HeadScale = scaleChange
            else
                CONFIG.HeadScale = math.clamp(CONFIG.HeadScale + scaleChange, 0.5, 20)
            end
            scaleDisplay.Text = "HEAD SCALE: " .. string.format("%.1f", CONFIG.HeadScale)
            updateAllHeads()
        end)
        
        return btn
    end
    
    -- Create scale buttons
    createScaleButton("INCREASE", UDim2.new(0.05, 0, 0.35, 0), 1, false)
    createScaleButton("DECREASE", UDim2.new(0.55, 0, 0.35, 0), -1, false)
    createScaleButton("HUGE (10)", UDim2.new(0.05, 0, 0.45, 0), 10, true)
    createScaleButton("NORMAL (1)", UDim2.new(0.55, 0, 0.45, 0), 1, true)
    
    -- Transparency Control
    local transLabel = Instance.new("TextLabel")
    transLabel.Text = "TRANSPARENCY: " .. CONFIG.Transparency
    transLabel.Size = UDim2.new(0.9, 0, 0, 30)
    transLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
    transLabel.BackgroundTransparency = 1
    transLabel.TextColor3 = Color3.new(1, 1, 1)
    transLabel.Font = Enum.Font.Code
    transLabel.TextSize = 16
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
    end)
    
    -- ESP Toggle
    local espBtn = Instance.new("TextButton")
    espBtn.Text = "ESP: ON"
    espBtn.Size = UDim2.new(0.9, 0, 0, 40)
    espBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
    espBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    espBtn.TextColor3 = Color3.new(1, 1, 1)
    espBtn.Parent = frame
    
    espBtn.MouseButton1Click:Connect(function()
        CONFIG.ESPEnabled = not CONFIG.ESPEnabled
        espBtn.Text = "ESP: " .. (CONFIG.ESPEnabled and "ON" or "OFF")
        espBtn.BackgroundColor3 = CONFIG.ESPEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        
        for npc, _ in pairs(processedNPCs) do
            if npc and npc.Parent then
                if CONFIG.ESPEnabled then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "NPC_ESP"
                    highlight.FillColor = CONFIG.ESPColor
                    highlight.FillTransparency = 0.8
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.Parent = npc
                    ESPBoxes[npc] = highlight
                else
                    if ESPBoxes[npc] then
                        ESPBoxes[npc]:Destroy()
                        ESPBoxes[npc] = nil
                    end
                end
            end
        end
    end)
    
    -- Rescan Button
    local rescanBtn = Instance.new("TextButton")
    rescanBtn.Text = "RESCAN NPCs"
    rescanBtn.Size = UDim2.new(0.9, 0, 0, 40)
    rescanBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
    rescanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    rescanBtn.TextColor3 = Color3.new(1, 1, 1)
    rescanBtn.Parent = frame
    
    rescanBtn.MouseButton1Click:Connect(function()
        -- Clear old
        for npc, _ in pairs(processedNPCs) do
            if ESPBoxes[npc] then
                ESPBoxes[npc]:Destroy()
            end
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
                    -- Process the NPC
                    local mesh = head:FindFirstChildOfClass("SpecialMesh")
                    if not mesh then
                        mesh = Instance.new("SpecialMesh")
                        mesh.MeshType = Enum.MeshType.Head
                        mesh.Parent = head
                    end
                    mesh.Scale = Vector3.new(CONFIG.HeadScale, CONFIG.HeadScale, CONFIG.HeadScale)
                    head.Transparency = CONFIG.Transparency
                    head.Material = Enum.Material.Neon
                    head.Color = CONFIG.ESPColor
                    
                    -- Add light
                    local light = Instance.new("PointLight")
                    light.Brightness = 2
                    light.Range = 20
                    light.Color = CONFIG.ESPColor
                    light.Parent = head
                    
                    -- ESP
                    if CONFIG.ESPEnabled then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "NPC_ESP"
                        highlight.FillColor = CONFIG.ESPColor
                        highlight.FillTransparency = 0.8
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                        highlight.Parent = descendant
                        ESPBoxes[descendant] = highlight
                    end
                    
                    processedNPCs[descendant] = true
                    found = found + 1
                end
            end
        end
        
        counterLabel.Text = "NPCs: " .. found
        print("Found " .. found .. " NPCs")
    end)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "CLOSE"
    closeBtn.Size = UDim2.new(0.4, 0, 0, 35)
    closeBtn.Position = UDim2.new(0.05, 0, 0.92, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ========== SPAWN DETECTION ==========
local function setupSpawnDetection()
    -- Watch for new models
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") then
            wait(0.5)  -- Wait for model to load
            
            local isPlayer = game.Players:GetPlayerFromCharacter(descendant)
            local head = descendant:FindFirstChild("Head")
            
            if not isPlayer and head and not processedNPCs[descendant] then
                -- Process the new NPC
                local mesh = head:FindFirstChildOfClass("SpecialMesh")
                if not mesh then
                    mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = Enum.MeshType.Head
                    mesh.Parent = head
                end
                mesh.Scale = Vector3.new(CONFIG.HeadScale, CONFIG.HeadScale, CONFIG.HeadScale)
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
                    game:GetService("Debris"):AddItem(sound, 2)
                end
                
                -- ESP
                if CONFIG.ESPEnabled then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "NPC_ESP"
                    highlight.FillColor = CONFIG.ESPColor
                    highlight.FillTransparency = 0.8
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.Parent = descendant
                    ESPBoxes[descendant] = highlight
                end
                
                processedNPCs[descendant] = true
                
                -- Update counter
                local gui = game:GetService("CoreGui"):FindFirstChild("NPCControllerGUI")
                if gui and gui:FindFirstChild("Frame") then
                    local counter = gui.Frame:FindFirstChild("NPCCounter")
                    if counter then
                        local count = 0
                        for _ in pairs(processedNPCs) do count = count + 1 end
                        counter.Text = "NPCs: " .. count
                    end
                end
                
                print("New NPC detected: " .. descendant.Name)
            end
        end
    end)
end

-- ========== MAIN INITIALIZATION ==========
print("🔧 Setting up...")

-- Create GUI
createPersistentGUI()

-- Setup spawn detection
setupSpawnDetection()

-- Initial scan after delay
wait(2)

-- Scan for existing NPCs
local found = 0
for _, descendant in pairs(workspace:GetDescendants()) do
    if descendant:IsA("Model") then
        local isPlayer = game.Players:GetPlayerFromCharacter(descendant)
        local head = descendant:FindFirstChild("Head")
        
        if not isPlayer and head and not processedNPCs[descendant] then
            -- Process the NPC
            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if not mesh then
                mesh = Instance.new("SpecialMesh")
                mesh.MeshType = Enum.MeshType.Head
                mesh.Parent = head
            end
            mesh.Scale = Vector3.new(CONFIG.HeadScale, CONFIG.HeadScale, CONFIG.HeadScale)
            head.Transparency = CONFIG.Transparency
            head.Material = Enum.Material.Neon
            head.Color = CONFIG.ESPColor
            
            -- Add light
            local light = Instance.new("PointLight")
            light.Brightness = 2
            light.Range = 20
            light.Color = CONFIG.ESPColor
            light.Parent = head
            
            -- ESP
            if CONFIG.ESPEnabled then
                local highlight = Instance.new("Highlight")
                highlight.Name = "NPC_ESP"
                highlight.FillColor = CONFIG.ESPColor
                highlight.FillTransparency = 0.8
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.Parent = descendant
                ESPBoxes[descendant] = highlight
            end
            
            processedNPCs[descendant] = true
            found = found + 1
        end
    end
end

-- Update counter
local gui = game:GetService("CoreGui"):FindFirstChild("NPCControllerGUI")
if gui and gui:FindFirstChild("Frame") then
    local counter = gui.Frame:FindFirstChild("NPCCounter")
    if counter then
        counter.Text = "NPCs: " .. found
    end
end

print("✅ SYSTEM ACTIVE!")
print("Found " .. found .. " NPCs")
print("HeadScale: " .. CONFIG.HeadScale)
