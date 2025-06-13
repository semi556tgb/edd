-- Radar Settings
local Radar = {
    Enabled = false,
    Position = Vector2.new(200, 200),
    Radius = 100,
    Scale = 1.25,
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    BorderColor = Color3.fromRGB(100, 100, 100),
    LocalPlayerColor = Color3.fromRGB(255, 255, 255),
    AllyColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    HealthBasedColor = true,
    TeamCheck = true
}

local function CreateCircle(radius, color, filled, thickness)
    local circle = Drawing.new("Circle")
    circle.Radius = radius
    circle.Color = color
    circle.Filled = filled
    circle.Thickness = thickness or 1
    circle.Visible = false
    circle.Transparency = 1
    return circle
end

local RadarBackground = CreateCircle(Radar.Radius, Radar.BackgroundColor, true, 1)
local RadarBorder = CreateCircle(Radar.Radius, Radar.BorderColor, false, 2)
local LocalTriangle = Drawing.new("Triangle")
LocalTriangle.Filled = true
LocalTriangle.Thickness = 1
LocalTriangle.Visible = false
LocalTriangle.Color = Radar.LocalPlayerColor

-- Player Dots Table
local RadarDots = {}

local function CreateRadarDot()
    local dot = Drawing.new("Circle")
    dot.Radius = 3
    dot.Filled = true
    dot.Thickness = 1
    dot.Visible = false
    return dot
end

-- Relative Position Calculation
local function GetRelative(pos)
    local char = Player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return 0, 0 end
    local hrp = char.HumanoidRootPart
    local camPos = Vector3.new(Camera.CFrame.Position.X, hrp.Position.Y, Camera.CFrame.Position.Z)
    local lookCFrame = CFrame.new(hrp.Position, camPos)
    local rel = lookCFrame:PointToObjectSpace(pos)
    return rel.X, rel.Z
end

-- Drawing Loop
RunService.RenderStepped:Connect(function()
    RadarBackground.Visible = Radar.Enabled
    RadarBorder.Visible = Radar.Enabled
    LocalTriangle.Visible = Radar.Enabled

    if not Radar.Enabled then
        for _, dot in pairs(RadarDots) do
            dot.Visible = false
        end
        return
    end

    RadarBackground.Position = Radar.Position
    RadarBorder.Position = Radar.Position
    RadarBackground.Color = Radar.BackgroundColor
    RadarBorder.Color = Radar.BorderColor
    RadarBackground.Radius = Radar.Radius
    RadarBorder.Radius = Radar.Radius

    -- Local Player Triangle
    LocalTriangle.Color = Radar.LocalPlayerColor
    LocalTriangle.PointA = Radar.Position + Vector2.new(0, -6)
    LocalTriangle.PointB = Radar.Position + Vector2.new(-3, 6)
    LocalTriangle.PointC = Radar.Position + Vector2.new(3, 6)

    -- Update Dots
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == Player then continue end
        local char = plr.Character
        if not (char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid")) then
            if RadarDots[plr] then RadarDots[plr].Visible = false end
            continue
        end

        if not RadarDots[plr] then
            RadarDots[plr] = CreateRadarDot()
        end

        local dot = RadarDots[plr]
        local hum = char:FindFirstChildOfClass("Humanoid")
        local x, z = GetRelative(char.HumanoidRootPart.Position)
        local relPos = Radar.Position - Vector2.new(x, z) * Radar.Scale

        local dist = (relPos - Radar.Position).Magnitude
        if dist <= Radar.Radius - 4 then
            dot.Position = relPos
            dot.Radius = 3
        else
            local direction = (relPos - Radar.Position).Unit
            dot.Position = Radar.Position + direction * (Radar.Radius - 4)
            dot.Radius = 2
        end

        dot.Visible = true

        if Radar.HealthBasedColor then
            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            dot.Color = Color3.new(1 - hpRatio, hpRatio, 0)
        elseif Radar.TeamCheck then
            dot.Color = (plr.TeamColor == Player.TeamColor) and Radar.AllyColor or Radar.EnemyColor
        else
            dot.Color = Radar.EnemyColor
        end
    end
end)

-- Linoria UI: Radar Integration
VisualsMain:AddToggle('EnableRadar', {
    Text = 'Enable Radar',
    Default = false,
    Callback = function(state)
        Radar.Enabled = state
    end
})

VisualsMain:AddSlider('RadarRadius', {
    Text = 'Radar Radius',
    Default = 100,
    Min = 50,
    Max = 250,
    Rounding = 0,
    Callback = function(value)
        Radar.Radius = value
    end
})

VisualsMain:AddSlider('RadarScale', {
    Text = 'Radar Scale',
    Default = 1.25,
    Min = 0.5,
    Max = 3,
    Rounding = 2,
    Callback = function(value)
        Radar.Scale = value
    end
})

VisualsMain:AddToggle('RadarHealthColor', {
    Text = 'Health-Based Dot Color',
    Default = true,
    Callback = function(state)
        Radar.HealthBasedColor = state
    end
})

VisualsMain:AddToggle('RadarTeamCheck', {
    Text = 'Team Check',
    Default = true,
    Callback = function(state)
        Radar.TeamCheck = state
    end
})
