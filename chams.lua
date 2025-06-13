-- chams.lua
local DendroESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LordNahida/DendroESP/main/Source.lua"))()

local Chams = {}
local Color = Color3.fromRGB(0, 255, 0) -- 💡 Change this to your desired color

function Chams.Enable()
    for _,v in pairs(game.Players:GetChildren()) do 
        if v.Character then 
            local mode = "Vertex" -- BoundingBox, Vertex, Shadow, Orthgonal, Highlight
            DendroESP:AddCharacter(v.Character, mode)
            -- Force color change if possible
            for _, obj in ipairs(v.Character:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Transparency < 1 then
                    obj.Color = Color
                end
            end
        end 
    end
end

function Chams.Disable()
    DendroESP:Clear()
end

return Chams
