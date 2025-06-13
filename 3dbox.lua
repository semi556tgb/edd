-- 3dbox.lua

local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")

local Camera = workspace.CurrentCamera
local Lines = {}
local Quads = {}

local function HasCharacter(Player)
    return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
end

local function DrawQuad(PosA, PosB, PosC, PosD)
    local A, aV = Camera:WorldToViewportPoint(PosA)
    local B, bV = Camera:WorldToViewportPoint(PosB)
    local C, cV = Camera:WorldToViewportPoint(PosC)
    local D, dV = Camera:WorldToViewportPoint(PosD)

    if not (aV or bV or cV or dV) then return end

    local Quad = Drawing.new("Quad")
    Quad.Thickness = 0.5
    Quad.Color = Color3.fromRGB(255, 255, 255)
    Quad.Transparency = 0.25
    Quad.ZIndex = 1
    Quad.Filled = true
    Quad.Visible = true
    Quad.PointA = Vector2.new(A.X, A.Y)
    Quad.PointB = Vector2.new(B.X, B.Y)
    Quad.PointC = Vector2.new(C.X, C.Y)
    Quad.PointD = Vector2.new(D.X, D.Y)
    table.insert(Quads, Quad)
end

local function DrawLine(From, To)
    local A, aV = Camera:WorldToViewportPoint(From)
    local B, bV = Camera:WorldToViewportPoint(To)
    if not (aV or bV) then return end

    local Line = Drawing.new("Line")
    Line.Thickness = 1
    Line.Color = Color3.fromRGB(255, 255, 255)
    Line.Transparency = 1
    Line.ZIndex = 1
    Line.From = Vector2.new(A.X, A.Y)
    Line.To = Vector2.new(B.X, B.Y)
    Line.Visible = true
    table.insert(Lines, Line)
end

local function GetCorners(Part)
    local CF, S, Corners = Part.CFrame, Part.Size / 2, {}
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                table.insert(Corners, (CF * CFrame.new(S * Vector3.new(x, y, z))).Position)
            end
        end
    end
    return Corners
end

local function DrawEsp(Player)
    local HRP = Player.Character.HumanoidRootPart
    local Verts = GetCorners({
        CFrame = HRP.CFrame * CFrame.new(0, -0.5, 0),
        Size = Vector3.new(3, 5, 3)
    })

    -- Bottom
    DrawLine(Verts[1], Verts[2])
    DrawLine(Verts[2], Verts[6])
    DrawLine(Verts[6], Verts[5])
    DrawLine(Verts[5], Verts[1])
    DrawQuad(Verts[1], Verts[2], Verts[6], Verts[5])

    -- Sides
    DrawLine(Verts[1], Verts[3])
    DrawLine(Verts[2], Verts[4])
    DrawLine(Verts[6], Verts[8])
    DrawLine(Verts[5], Verts[7])
    DrawQuad(Verts[2], Verts[4], Verts[8], Verts[6])
    DrawQuad(Verts[1], Verts[2], Verts[4], Verts[3])
    DrawQuad(Verts[1], Verts[5], Verts[7], Verts[3])
    DrawQuad(Verts[5], Verts[7], Verts[8], Verts[6])

    -- Top
    DrawLine(Verts[3], Verts[4])
    DrawLine(Verts[4], Verts[8])
    DrawLine(Verts[8], Verts[7])
    DrawLine(Verts[7], Verts[3])
    DrawQuad(Verts[3], Verts[4], Verts[8], Verts[7])
end

local function ClearDrawings()
    for _, v in ipairs(Lines) do v:Remove() end
    for _, v in ipairs(Quads) do v:Remove() end
    Lines = {}
    Quads = {}
end

local Enabled = false

local function Enable()
    if Enabled then return end
    Enabled = true
    RunService.RenderStepped:Connect(function()
        if not Enabled then return end
        ClearDrawings()
        for _, player in ipairs(PlayersService:GetPlayers()) do
            if player ~= PlayersService.LocalPlayer and HasCharacter(player) then
                DrawEsp(player)
            end
        end
    end)
end

local function Disable()
    Enabled = false
    ClearDrawings()
end

return {
    Enable = Enable,
    Disable = Disable
}
