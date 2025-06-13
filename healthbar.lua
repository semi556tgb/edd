-- healthbar.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local HealthBar = {}
HealthBar.Enabled = false

local drawings = {}

local function createHealthBar()
    local barBack = Drawing.new("Square")
    barBack.Size = Vector2.new(50, 6)
    barBack.Color = Color3.fromRGB(0, 0, 0)
    barBack.Filled = true
    barBack.Transparency = 0.5
    barBack.Visible = false

    local barFill = Drawing.new("Square")
    barFill.Size = Vector2.new(48, 4)
    barFill.Color = Color3.fromRGB(0, 255, 0)
    barFill.Filled = true
    barFill.Transparency = 0.8
    barFill.Visible = false

    return barBack, barFill
end

local function updateHealthBar(player)
    local barBack, barFill = createHealthBar()
    drawings[player] = {barBack = barBack, barFill = barFill}

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not HealthBar.Enabled then
            barBack.Visible = false
            barFill.Visible = false
            conn:Disconnect()
            drawings[player] = nil
            return
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if humanoid and humanoid.Health > 0 and rootPart then
            local headPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            if onScreen then
                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)

                barBack.Position = Vector2.new(headPos.X - 25, headPos.Y - 50)
                barFill.Position = Vector2.new(headPos.X - 24, headPos.Y - 49)
                barFill.Size = Vector2.new(48 * healthPercent, 4)

                barBack.Visible = true
                barFill.Visible = true

                -- Color interpolation from red (low) to green (high)
                barFill.Color = Color3.new(1 - healthPercent, healthPercent, 0)
            else
                barBack.Visible = false
                barFill.Visible = false
            end
        else
            barBack.Visible = false
            barFill.Visible = false
        end
    end)
end

function HealthBar.Enable()
    if HealthBar.Enabled then return end
    HealthBar.Enabled = true

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            updateHealthBar(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            updateHealthBar(player)
        end
    end)
end

function HealthBar.Disable()
    HealthBar.Enabled = false
    for _, bars in pairs(drawings) do
        bars.barBack.Visible = false
        bars.barBack:Remove()
        bars.barFill.Visible = false
        bars.barFill:Remove()
    end
    drawings = {}
end

return HealthBar
