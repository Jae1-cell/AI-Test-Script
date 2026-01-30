-- ============================================
-- NPC HEAD MODIFIER - CHECKS INSIDE FOLDERS
-- ============================================

repeat wait() until game:IsLoaded()
wait(2)

local HeadScale = 7.0
local Transparency = 0.6
local ESPColor = Color3.fromRGB(255, 50, 255)
local processedNPCs = {}

print("🎯 NPC Head Modifier Starting...")
print("Scale: " .. HeadScale)
print("Checking folders in workspace...")

-- Function to search through ALL folders and subfolders
local function searchInFolders(parent)
    local found = 0
    
    for _, item in pairs(parent:GetChildren()) do
        if item:IsA("Folder") or item:IsA("Model") then
            -- Check items in this folder/model
            for _, child in pairs(item:GetChildren()) do
                if child:IsA("Model") then
                    -- Check if this model is an NPC
                    local head = child:FindFirstChild("Head")
                    local humanoid = child:FindFirstChildOfClass("Humanoid")
                    local isPlayer = game.Players:GetPlayerFromCharacter(child)
                    
                    if head and humanoid and not isPlayer and not processedNPCs[child] then
                        -- MODIFY THE HEAD
                        local mesh = head:FindFirstChildOfClass("SpecialMesh")
                        if not mesh then
                            mesh = Instance.new("SpecialMesh")
                            mesh.MeshType = Enum.MeshType.Head
                            mesh.Parent = head
                            print("✅ Created mesh for: " .. child.Name)
                        end
                        
                        -- APPLY SCALE
                        mesh.Scale = Vector3.new(HeadScale, HeadScale, HeadScale)
                        head.Transparency = Transparency
                        head.Material = Enum.Material.Neon
                        head.Color = ESPColor
                        
                        -- Add ESP
                        local highlight = Instance.new("Highlight")
                        highlight.FillColor = ESPColor
                        highlight.FillTransparency = 0.8
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                        highlight.Parent = child
                        
                        processedNPCs[child] = true
                        found = found + 1
                        print("🎯 Modified: " .. child.Name .. " in " .. item.Name)
                    end
                end
            end
            
            -- Recursively search subfolders
            found = found + searchInFolders(item)
        end
    end
    
    return found
end

-- Watch for new items in folders
local function setupFolderWatcher()
    local function watchFolder(folder)
        folder.ChildAdded:Connect(function(child)
            wait(0.5)  -- Wait for child to load
            
            if child:IsA("Model") then
                local head = child:FindFirstChild("Head")
                local humanoid = child:FindFirstChildOfClass("Humanoid")
                local isPlayer = game.Players:GetPlayerFromCharacter(child)
                
                if head and humanoid and not isPlayer and not processedNPCs[child] then
                    -- Modify the new NPC
                    local mesh = head:FindFirstChildOfClass("SpecialMesh")
                    if not mesh then
                        mesh = Instance.new("SpecialMesh")
                        mesh.MeshType = Enum.MeshType.Head
                        mesh.Parent = head
                    end
                    
                    mesh.Scale = Vector3.new(HeadScale, HeadScale, HeadScale)
                    head.Transparency = Transparency
                    
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = ESPColor
                    highlight.Parent = child
                    
                    processedNPCs[child] = true
                    print("🆕 New NPC detected: " .. child.Name .. " in " .. folder.Name)
                end
            elseif child:IsA("Folder") then
                -- Watch this new folder too
                watchFolder(child)
                searchInFolders(child)
            end
        end)
    end
    
    -- Watch all existing folders
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Folder") then
            watchFolder(item)
        end
    end
    
    -- Watch for new folders
    workspace.ChildAdded:Connect(function(child)
        if child:IsA("Folder") then
            wait(0.5)
            watchFolder(child)
            searchInFolders(child)
        end
    end)
end

-- Initial scan of ALL folders
print("\n🔍 Scanning ALL folders in workspace...")
local totalFound = searchInFolders(workspace)
print("✅ Found " .. totalFound .. " NPCs in folders")

-- Setup folder watcher
setupFolderWatcher()

-- Create control GUI
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "NPCControl"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0, 20, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Title
local title = Instance.new("TextLabel", frame)
title.Text = "NPC HEAD CONTROLLER"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = ESPColor
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Scale Display
local scaleLabel = Instance.new("TextLabel", frame)
scaleLabel.Text = "SCALE: " .. HeadScale
scaleLabel.Size = UDim2.new(0.9, 0, 0, 30)
scaleLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
scaleLabel.BackgroundTransparency = 1
scaleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
scaleLabel.Font = Enum.Font.SourceSansBold
scaleLabel.TextSize = 16

-- Increase Button
local upBtn = Instance.new("TextButton", frame)
upBtn.Text = "⬆️ INCREASE"
upBtn.Size = UDim2.new(0.4, 0, 0, 40)
upBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
upBtn.TextColor3 = Color3.new(1, 1, 1)

upBtn.MouseButton1Click:Connect(function()
    HeadScale = HeadScale + 1
    scaleLabel.Text = "SCALE: " .. HeadScale
    updateAllNPCs()
end)

-- Decrease Button
local downBtn = Instance.new("TextButton", frame)
downBtn.Text = "⬇️ DECREASE"
downBtn.Size = UDim2.new(0.4, 0, 0, 40)
downBtn.Position = UDim2.new(0.55, 0, 0.35, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
downBtn.TextColor3 = Color3.new(1, 1, 1)

downBtn.MouseButton1Click:Connect(function()
    HeadScale = math.max(1, HeadScale - 1)
    scaleLabel.Text = "SCALE: " .. HeadScale
    updateAllNPCs()
end)

-- Set to 7 Button
local set7Btn = Instance.new("TextButton", frame)
set7Btn.Text = "🎯 SET TO 7"
set7Btn.Size = UDim2.new(0.9, 0, 0, 40)
set7Btn.Position = UDim2.new(0.05, 0, 0.5, 0)
set7Btn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
set7Btn.TextColor3 = Color3.new(1, 1, 1)

set7Btn.MouseButton1Click:Connect(function()
    HeadScale = 7
    scaleLabel.Text = "SCALE: " .. HeadScale
    updateAllNPCs()
end)

-- Rescan Button
local rescanBtn = Instance.new("TextButton", frame)
rescanBtn.Text = "🔍 RESCAN FOLDERS"
rescanBtn.Size = UDim2.new(0.9, 0, 0, 40)
rescanBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
rescanBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
rescanBtn.TextColor3 = Color3.new(1, 1, 1)

rescanBtn.MouseButton1Click:Connect(function()
    print("\n🔄 Rescanning ALL folders...")
    processedNPCs = {}
    local found = searchInFolders(workspace)
    print("✅ Found " .. found .. " NPCs")
end)

-- Function to update all NPCs
function updateAllNPCs()
    print("🔄 Updating " .. #processedNPCs .. " NPCs to scale: " .. HeadScale)
    
    local updated = 0
    for npc, _ in pairs(processedNPCs) do
        if npc and npc.Parent then
            local head = npc:FindFirstChild("Head")
            if head then
                local mesh = head:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.Scale = Vector3.new(HeadScale, HeadScale, HeadScale)
                    updated = updated + 1
                end
            end
        end
    end
    
    print("✅ Updated " .. updated .. " NPC heads")
end

print("\n✅ SYSTEM ACTIVE!")
print("Scale: " .. HeadScale)
print("NPCs modified: " .. totalFound)
