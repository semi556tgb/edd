-- radar.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local DrawingNew = Drawing.new

local radar = {}
radar.Config = {
    Position = Vector2.new(200, 200),
    Radius = 100,
    Scale = 1,
    RadarBack = Color3.fromRGB(10, 10, 10),
    RadarBorder = Color3.fromRGB(75, 75, 75),
    LocalPlayerDot = Color3.fromRGB(255, 255, 255),
    PlayerDot = Color3.fromRGB(60, 170, 255),
    Team = Color3.fromRGB(0, 255, 0),
    Enemy = Color3.fromRGB(255, 0, 0),
    Health_Color = true,
    Team_Check = true
}

local dots = {}
local enabled = false

-- Utility: NewCircle
local function NewCircle(transparency, color, radius, filled, thickness)
    local c = DrawingNew("Circle")
    c.Transparency = transparency
    c.Color = color
    c.Visible = false
    c.Thickness = thickness
    c.Position = Vector2.new(0, 0)
    c.Radius = radius
    c.NumSides = math.clamp(radius * 55 / 100, 10, 75)
    c.Filled = filled
    return c
end

-- Setup Radar Background & Border
local RadarBackground = NewCircle(0.9, radar.Config.RadarBack, radar.Config.Radius, true, 1)
local RadarBorder = NewCircle(0.75, radar.Config.RadarBorder, radar.Config.Radius, false, 3)
RadarBackground.Visible = false
RadarBorder.Visible = false

-- Calculate relative position
local function GetRelative(pos)
    local char = LocalPlayer.Character
    if char and char.PrimaryPart then
        local pmpart = char.PrimaryPart
        local camerapos = Vector3.new(Camera.CFrame.Position.X, pmpart.Position.Y, Camera.CFrame.Position.Z)
        local newcf = CFrame.new(pmpart.Position, camerapos)
        local r = newcf:PointToObjectSpace(pos)
        return r.X, r.Z
    else
        return 0, 0
    end
end

-- Create dot for player
local function PlaceDot(plr)
    local dot = NewCircle(1, radar.Config.PlayerDot, 3, true, 1)
    dots[plr] = dot

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not enabled then
            dot.Visible = false
            conn:Disconnect()
            return
        end

        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and char.PrimaryPart and hum and hum.Health > 0 then
            local relx, rely = GetRelative(char.PrimaryPart.Position)
            local newpos = radar.Config.Position - Vector2.new(relx * radar.Config.Scale, rely * radar.Config.Scale)

            if (newpos - radar.Config.Position).Magnitude < radar.Config.Radius - 2 then
                dot.Radius = 3
                dot.Position = newpos
                dot.Visible = true
            else
                local dist = (radar.Config.Position - newpos).Magnitude
                local calc = (radar.Config.Position - newpos).Unit * (dist - radar.Config.Radius)
                local inside = Vector2.new(newpos.X + calc.X, newpos.Y + calc.Y)
                dot.Radius = 2
                dot.Position = inside
                dot.Visible = true
            end

            dot.Color = radar.Config.PlayerDot
            if radar.Config.Team_Check then
                if plr.TeamColor == LocalPlayer.TeamColor then
                    dot.Color = radar.Config.Team
                else
                    dot.Color = radar.Config.Enemy
                end
            end

            if radar.Config.Health_Color then
                local hpRatio = hum.Health / hum.MaxHealth
                dot.Color = Color3.fromHSV(hpRatio * 0.33, 1, 1) -- Green to Red scale
            end
        else
            dot.Visible = false
        end
    end)
end

local LocalPlayerDot = DrawingNew("Triangle")
LocalPlayerDot.Visible = false

local function UpdateLocalDot()
    LocalPlayerDot.PointA = radar.Config.Position + Vector2.new(0, -6)
    LocalPlayerDot.PointB = radar.Config.Position + Vector2.new(-3, 6)
    LocalPlayerDot.PointC = radar.Config.Position + Vector2.new(3, 6)
    LocalPlayerDot.Color = radar.Config.LocalPlayerDot
    LocalPlayerDot.Visible = enabled
end

-- Add dots for existing players
local function SetupPlayers()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            PlaceDot(plr)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if enabled then
        PlaceDot(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if dots[plr] then
        dots[plr]:Remove()
        dots[plr] = nil
    end
end)

local dragging = false
local offset = Vector2.new(0, 0)
local GuiService = game:GetService("GuiService")
local inset = GuiService:GetGuiInset()

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and (Vector2.new(Mouse.X, Mouse.Y + inset.Y) - radar.Config.Position).Magnitude < radar.Config.Radius then
        offset = radar.Config.Position - Vector2.new(Mouse.X, Mouse.Y)
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local conn
local function RunLoop()
    conn = RunService.RenderStepped:Connect(function()
        if dragging then
            radar.Config.Position = Vector2.new(Mouse.X, Mouse.Y) + offset
        end
        RadarBackground.Position = radar.Config.Position
        RadarBackground.Radius = radar.Config.Radius
        RadarBackground.Color = radar.Config.RadarBack
        RadarBorder.Position = radar.Config.Position
        RadarBorder.Radius = radar.Config.Radius
        RadarBorder.Color = radar.Config.RadarBorder
        UpdateLocalDot()
    end)
end

function radar.Enable()
    if enabled then return end
    enabled = true
    RadarBackground.Visible = true
    RadarBorder.Visible = true
    LocalPlayerDot.Visible = true
    SetupPlayers()
    RunLoop()
end

function radar.Disable()
    if not enabled then return end
    enabled = false
    RadarBackground.Visible = false
    RadarBorder.Visible = false
    LocalPlayerDot.Visible = false
    if conn then conn:Disconnect() end
    for plr, dot in pairs(dots) do
        dot:Remove()
    end
    dots = {}
end

return radar
