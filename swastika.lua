-- swastika.lua
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local espBoxes = {}

local function createSwastikaBox()
    local lines = {}
    for i = 1, 8 do
        local ln = Drawing.new("Line")
        ln.Color = Color3.new(1, 1, 1)
        ln.Thickness = 1
        ln.Visible = false
        lines[i] = ln
    end
    return lines
end

local function updateSwastikaLines(lines, center, size)
    local foot = size * 0.5
    local pts = {
        {Vector2.new(0, 0), Vector2.new(size, 0)},
        {Vector2.new(size, 0), Vector2.new(size, foot)},
        {Vector2.new(0, 0), Vector2.new(0, size)},
        {Vector2.new(0, size), Vector2.new(-foot, size)},
        {Vector2.new(0, 0), Vector2.new(-size, 0)},
        {Vector2.new(-size, 0), Vector2.new(-size, -foot)},
        {Vector2.new(0, 0), Vector2.new(0, -size)},
        {Vector2.new(0, -size), Vector2.new(foot, -size)},
    }
    for i, seg in ipairs(pts) do
        lines[i].From = center + seg[1]
        lines[i].To = center + seg[2]
        lines[i].Visible = true
    end
end

local function getLowestFootY(char)
    local parts = {}
    if char:FindFirstChild("LeftFoot") then
        parts = { char.LeftFoot, char.RightFoot }
    elseif char:FindFirstChild("Left Leg") then
        parts = { char["Left Leg"], char["Right Leg"] }
    else
        return nil
    end
    local y
    for _, part in pairs(parts) do
        if part and part:IsA("BasePart") then
            y = (not y or part.Position.Y < y) and part.Position.Y or y
        end
    end
    return y
end

local conn
local Module = {}

function Module.Enable()
    conn = RunService.RenderStepped:Connect(function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                local head = char:FindFirstChild("Head")
                local lowest = getLowestFootY(char)
                if head and lowest then
                    local top2D, onScreenTop = Camera:WorldToViewportPoint(head.Position)
                    local bottom2D, onScreenBot = Camera:WorldToViewportPoint(Vector3.new(head.Position.X, lowest, head.Position.Z))
                    if onScreenTop and onScreenBot then
                        local center = (Vector2.new(top2D.X, top2D.Y) + Vector2.new(bottom2D.X, bottom2D.Y)) / 2
                        local height = (Vector2.new(top2D.X, top2D.Y) - Vector2.new(bottom2D.X, bottom2D.Y)).Magnitude / 2
                        espBoxes[plr] = espBoxes[plr] or createSwastikaBox()
                        updateSwastikaLines(espBoxes[plr], center, height)
                    else
                        if espBoxes[plr] then
                            for _, l in ipairs(espBoxes[plr]) do
                                l.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end)
end

function Module.Disable()
    if conn then conn:Disconnect() conn = nil end
    for _, lines in pairs(espBoxes) do
        for _, ln in ipairs(lines) do
            ln.Visible = false
            ln:Remove()
        end
    end
    espBoxes = {}
end

return Module
