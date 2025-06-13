local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Skeleton = {}

local connection
local drawings = {}

-- Bone structure mapping (based on rig hierarchy)
local bones = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" },
}

-- Draw skeleton for one character
local function createSkeletonLines(char)
    local lines = {}
    for _ = 1, #bones do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Color = Color3.new(1, 1, 1) -- white
        line.Transparency = 1
        line.Visible = true
        table.insert(lines, line)
    end
    return lines
end

local function removeAllDrawings()
    for _, lines in pairs(drawings) do
        for _, line in ipairs(lines) do
            line:Remove()
        end
    end
    drawings = {}
end

function Skeleton.Enable()
    if connection then return end

    connection = RunService.RenderStepped:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == Players.LocalPlayer then continue end
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then continue end
            if not character:FindFirstChild("Head") then continue end
            if not character:FindFirstChildOfClass("Humanoid") then continue end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid.Health <= 0 then
                if drawings[player] then
                    for _, line in ipairs(drawings[player]) do
                        line.Visible = false
                    end
                end
                continue
            end

            local camera = workspace.CurrentCamera
            drawings[player] = drawings[player] or createSkeletonLines(character)

            for i, bone in ipairs(bones) do
                local part0 = character:FindFirstChild(bone[1])
                local part1 = character:FindFirstChild(bone[2])
                local line = drawings[player][i]

                if part0 and part1 then
                    local pos0, onScreen0 = camera:WorldToViewportPoint(part0.Position)
                    local pos1, onScreen1 = camera:WorldToViewportPoint(part1.Position)

                    if onScreen0 and onScreen1 then
                        line.From = Vector2.new(pos0.X, pos0.Y)
                        line.To = Vector2.new(pos1.X, pos1.Y)
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        end

        -- Cleanup for players that left
        for player, lines in pairs(drawings) do
            if not Players:FindFirstChild(player.Name) then
                for _, line in ipairs(lines) do
                    line:Remove()
                end
                drawings[player] = nil
            end
        end
    end)
end

function Skeleton.Disable()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    removeAllDrawings()
end

return Skeleton
