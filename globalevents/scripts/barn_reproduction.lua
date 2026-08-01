-- data/globalevents/scripts/barn_reproduction.lua
local BarnSystem = BarnSystem or {}

function onThink()
    if BarnSystem.processReproduction then
        BarnSystem:processReproduction()
    end
    return true
end