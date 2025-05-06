local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local maxDistance = 50
local checkInterval = 0.2

local activeESPs = {}

local function createESP(part, levelNumber)
    if activeESPs[part] then return end
    
    local BillboardGui = Instance.new("BillboardGui")
    local TextLabel = Instance.new("TextLabel")
    
    BillboardGui.Name = "LevelESP"
    BillboardGui.Parent = part
    BillboardGui.Adornee = part
    BillboardGui.Size = UDim2.new(0, 100, 0, 100)
    BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Enabled = false
    
    TextLabel.Parent = BillboardGui
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = "↑ LVL "..levelNumber.." ↑"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    TextLabel.TextScaled = true
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    activeESPs[part] = BillboardGui
end

local function updateESPVisibility()
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local playerPosition = character.HumanoidRootPart.Position
    
    for part, esp in pairs(activeESPs) do
        if part and part.Parent then
            local distance = (playerPosition - part.Position).Magnitude
            esp.Enabled = distance <= maxDistance
            
            local transparency = math.clamp((distance / maxDistance) - 0.5, 0, 0.8)
            esp.TextLabel.TextTransparency = transparency
            esp.TextLabel.TextStrokeTransparency = transparency
        else

            esp:Destroy()
            activeESPs[part] = nil
        end
    end
end

local function scanWorkspace()

    if not workspace:FindFirstChild("level_glasses") then
        warn("No se encontró level_glasses en el workspace")
        return
    end
    

    for _, folder in ipairs(workspace.level_glasses:GetChildren()) do
        if folder:IsA("Folder") then

            local glassesModel = folder:FindFirstChild("glasses")
            if glassesModel then

                for _, obj in ipairs(glassesModel:GetChildren()) do
                    if obj:IsA("BasePart") and obj.Name:lower():find("^lvl") and not obj.Name:lower():find("killglass") then

                        local levelNumber = obj.Name:match("%d+") or "?"
                        createESP(obj, levelNumber)
                    end
                end
            end
        end
    end
end


player.CharacterAdded:Connect(function(newChar)
    character = newChar

    repeat task.wait() until newChar:FindFirstChild("HumanoidRootPart")
end)

scanWorkspace()

while true do
    updateESPVisibility()
    task.wait(checkInterval)
end
