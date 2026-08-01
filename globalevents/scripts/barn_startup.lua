-- data/globalevents/scripts/barn_startup.lua
local BarnSystem = BarnSystem or {}

function onStartup()
    if BarnSystem.loadCache then
        BarnSystem:loadCache()
    end
    return true
end