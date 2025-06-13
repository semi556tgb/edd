-- 2dbox.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local boxEspLines = {}

-- Helper to make 4 box lines
local function createBox()
    local lines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 1
        line.Transparency = 1
        line.Visible = false
        lines[i] = line
    end
    return lines
end

-- Draw ESP Box
local function drawBox(lines, topLeft, topRight, bottomRight, bottomLeft)
    lines[1].From = topLeft
    lines[1].To = topRight

    lines[2].From = topRight
    lines[2].To = bottomRight

    lines[3].From = bottomRight
    lines[3].To = bottomLeft

    lines[4].From = bottomLeft
    lines[4].To = topLeft

    for _, line in ipairs(lines) do
        line.Visible = true
    end
end

-- Main drawing connection
local conn
local Module = {}

function Module.Enable()
    conn = RunService.RenderStepped:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")

                if not humanoid or not hrp then continue end

                local height = humanoid.HipHeight + (humanoid.RigType == Enum.HumanoidRigType.R15 and 2.5 or 2)
                local width = humanoid.RigType == Enum.HumanoidRigType.R15 and 2 or 2.5

                local pos = hrp.Position
                local topPos = pos + Vector3.new(0, height, 0)
                local bottomPos = pos - Vector3.new(0, 2.5, 0)

                local topVec, onTop = Camera:WorldToViewportPoint(topPos)
                local bottomVec, onBottom = Camera:WorldToViewportPoint(bottomPos)

                if onTop and onBottom then
                    local boxHeight = math.abs(topVec.Y - bottomVec.Y)
                    local boxWidth = boxHeight / 2

                    local topLeft = Vector2.new(topVec.X - boxWidth / 2, topVec.Y)
                    local topRight = Vector2.new(topVec.X + boxWidth / 2, topVec.Y)
                    local bottomLeft = Vector2.new(bottomVec.X - boxWidth / 2, bottomVec.Y)
                    local bottomRight = Vector2.new(bottomVec.X + boxWidth / 2, bottomVec.Y)

                    boxEspLines[player] = boxEspLines[player] or createBox()
                    drawBox(boxEspLines[player], topLeft, topRight, bottomRight, bottomLeft)
                elseif boxEspLines[player] then
                    for _, l in ipairs(boxEspLines[player]) do l.Visible = false end
                end
            elseif boxEspLines[player] then
                for _, l in ipairs(boxEspLines[player]) do l.Visible = false end
            end
        end
    end)
end

function Module.Disable()
    if conn then conn:Disconnect() conn = nil end
    for _, lines in pairs(boxEspLines) do
        for _, l in ipairs(lines) do
            l.Visible = false
            l:Remove()
        end
    end
    table.clear(boxEspLines)
end

return Module
