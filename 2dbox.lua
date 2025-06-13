-- 2dbox.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local boxes = {}  -- player -> {Line1, Line2, Line3, Line4}

-- Create thin white box lines
local function createBoxLines()
    local t = {}
    for i = 1, 4 do
        local ln = Drawing.new("Line")
        ln.Color = Color3.new(1,1,1)
        ln.Thickness = 1
        ln.Transparency = 1
        ln.Visible = false
        t[i] = ln
    end
    return t
end

-- Draw rectangle with given corners
local function drawBox(lines, topV, bottomV, boxWidth)
    local halfW = boxWidth / 2
    local tl = Vector2.new(topV.X - halfW, topV.Y)
    local tr = Vector2.new(topV.X + halfW, topV.Y)
    local bl = Vector2.new(bottomV.X - halfW, bottomV.Y)
    local br = Vector2.new(bottomV.X + halfW, bottomV.Y)

    lines[1].From, lines[1].To = tl, tr
    lines[2].From, lines[2].To = tr, br
    lines[3].From, lines[3].To = br, bl
    lines[4].From, lines[4].To = bl, tl

    for i = 1, 4 do
        lines[i].Visible = true
    end
end

-- Return Y of lowest foot part (supports R6, R15 rigs)
local function getLowestFootY(char)
    local parts = {}
    if char:FindFirstChild("LeftFoot") then
        parts = {char.LeftFoot, char.RightFoot}
    elseif char:FindFirstChild("Left Leg") then
        parts = {char["Left Leg"], char["Right Leg"]}
    else
        return nil
    end

    local lowest
    for _, part in ipairs(parts) do
        if part and part:IsA("BasePart") then
            local y = part.Position.Y
            lowest = (not lowest or y < lowest) and y or lowest
        end
    end
    return lowest
end

-- Module with On/Off functionality
local Module = {}
local conn

function Module.Enable()
    if conn then return end
    conn = RunService.RenderStepped:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                local head = char:FindFirstChild("Head")
                local lowestY = getLowestFootY(char)
                if head and lowestY then
                    local top3, topOn = Camera:WorldToViewportPoint(head.Position)
                    local bot3, botOn = Camera:WorldToViewportPoint(Vector3.new(head.Position.X, lowestY, head.Position.Z))
                    if topOn and botOn then
                        local topV = Vector2.new(top3.X, top3.Y)
                        local botV = Vector2.new(bot3.X, bot3.Y)
                        local height = (botV - topV).Magnitude
                        local width = height / 2

                        if not boxes[plr] then
                            boxes[plr] = createBoxLines()
                        end
                        drawBox(boxes[plr], topV, botV, width)
                    else
                        if boxes[plr] then
                            for _, ln in ipairs(boxes[plr]) do ln.Visible = false end
                        end
                    end
                end
            elseif boxes[plr] then
                for _, ln in ipairs(boxes[plr]) do ln.Visible = false end
            end
        end
    end)
end

function Module.Disable()
    if conn then conn:Disconnect(); conn = nil end
    for _, lines in pairs(boxes) do
        for _, ln in ipairs(lines) do
            ln.Visible = false
            ln:Remove()
        end
    end
    boxes = {}
end

return Module
