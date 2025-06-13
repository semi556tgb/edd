-- chams.lua (White ESP using Vertex Mode)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Table to store ESP drawings
local ESP = {}

-- Settings
local ChamsColor = Color3.fromRGB(255, 255, 255) -- White
local Thickness = 1
local Transparency = 1

local function CreateLine()
    local line = Drawing.new("Line")
    line.Color = ChamsColor
    line.Thickness = Thickness
    line.Transparency = Transparency
    line.Visible = false
    return line
end

local function GetLegitParts(char)
    local parts = {}
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 and part.Name ~= "HumanoidRootPart" then
            table.insert(parts, part)
        end
    end
    return parts
end

local function AddCharacterESP(char)
    if ESP[char] then return end
    ESP[char] = {}

    local lines = {}

    local parts = GetLegitParts(char)
    for _, part in ipairs(parts) do
        local attachment0 = Instance.new("Attachment", part)
        local attachment1 = Instance.new("Attachment", part)
        attachment0.Position = Vector3.new(0.5, 0.5, 0.5)
        attachment1.Position = Vector3.new(-0.5, -0.5, -0.5)

        local line = CreateLine()
        table.insert(lines, {part, attachment0, attachment1, line})
    end

    ESP[char] = lines
end

local function RemoveCharacterESP(char)
    local lines = ESP[char]
    if lines then
        for _, data in pairs(lines) do
            if data[4] then
                data[4]:Remove()
            end
        end
        ESP[char] = nil
    end
end

-- Update ESP every frame
RunService.RenderStepped:Connect(function()
    for char, lines in pairs(ESP) do
        if char and char.Parent then
            for _, data in pairs(lines) do
                local part, att0, att1, line = unpack(data)
                local p0, onScreen0 = Camera:WorldToViewportPoint(part.Position + att0.Position)
                local p1, onScreen1 = Camera:WorldToViewportPoint(part.Position + att1.Position)

                if onScreen0 and onScreen1 then
                    line.From = Vector2.new(p0.X, p0.Y)
                    line.To = Vector2.new(p1.X, p1.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        else
            RemoveCharacterESP(char)
        end
    end
end)

-- Setup existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        AddCharacterESP(player.Character)
    end
end

-- New players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        AddCharacterESP(char)
    end)
end)

-- CharacterAdded for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            AddCharacterESP(char)
        end)
    end
end
