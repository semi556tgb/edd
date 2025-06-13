-- 2dbox.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local boxEspLines = {}

local function createBoxLines()
    local t = {}
    for i = 1,4 do
        local ln = Drawing.new("Line")
        ln.Color = Color3.new(1,1,1)
        ln.Thickness = 2
        ln.Visible = false
        t[i] = ln
    end
    return t
end

local function updateBox(lines, top, bottom, width)
    local left = top - Vector2.new(width/2, 0)
    local right = top + Vector2.new(width/2, 0)
    local bottomLeft = bottom - Vector2.new(width/2, 0)
    local bottomRight = bottom + Vector2.new(width/2, 0)

    -- Top edge
    lines[1].From, lines[1].To = left, right
    -- Right
    lines[2].From, lines[2].To = right, bottomRight
    -- Bottom
    lines[3].From, lines[3].To = bottomRight, bottomLeft
    -- Left
    lines[4].From, lines[4].To = bottomLeft, left

    for _, ln in ipairs(lines) do ln.Visible = true end
end

local conn
local Module = {}

function Module.Enable()
    conn = RunService.RenderStepped:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
                local root = plr.Character.HumanoidRootPart
                local head = plr.Character.Head
                local top2, onTop = Camera:WorldToViewportPoint(head.Position)
                local bot2, onBot = Camera:WorldToViewportPoint(root.Position)
                if onTop and onBot then
                    local topV = Vector2.new(top2.X, top2.Y)
                    local botV = Vector2.new(bot2.X, bot2.Y)
                    local h = (botV - topV).Y
                    local w = h/2

                    boxEspLines[plr] = boxEspLines[plr] or createBoxLines()
                    updateBox(boxEspLines[plr], topV, botV, w)
                elseif boxEspLines[plr] then
                    for _, ln in ipairs(boxEspLines[plr]) do ln.Visible = false end
                end
            elseif boxEspLines[plr] then
                for _, ln in ipairs(boxEspLines[plr]) do ln.Visible = false end
            end
        end
    end)
end

function Module.Disable()
    if conn then conn:Disconnect() end
    for _, lines in pairs(boxEspLines) do
        for _, ln in ipairs(lines) do
            ln.Visible = false
            ln:Remove()
        end
    end
    table.clear(boxEspLines)
end

return Module
