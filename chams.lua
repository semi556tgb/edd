-- chams.lua
-- DendroESP Chams Module

local DendroESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LordNahida/DendroESP/main/Source.lua"))()

local Chams = {}
local Players = game:GetService("Players")

function Chams.Enable()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            DendroESP:AddCharacter(player.Character, "Vertex")
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            DendroESP:AddCharacter(char, "Vertex")
        end)
    end)
end

function Chams.Disable()
    -- No built-in disable, but to stop further additions you can just not call Enable again.
    -- Alternatively, recreate a toggle that clears ESP visuals if the lib supports it in future.
end

return Chams
