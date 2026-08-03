local HUNGER_STORAGE = 50000
local THIRST_STORAGE = 50001
local FATIGUE_STORAGE = 50002
local OXYGEN_STORAGE = 50009
local TEMPERATURE_STORAGE = 50010

local HUNGER_FULL_TIME = 50003
local THIRST_FULL_TIME = 50004

local PROTECTION_MINUTES = 10 

function onPrepareDeath(player, killer)
    local currentTime = os.time()
    local protectionSeconds = PROTECTION_MINUTES * 60

    -- Força os valores máximos
    player:setStorageValue(HUNGER_STORAGE, 100)
    player:setStorageValue(THIRST_STORAGE, 100)
    player:setStorageValue(FATIGUE_STORAGE, 100)
    player:setStorageValue(OXYGEN_STORAGE, 100)
    player:setStorageValue(TEMPERATURE_STORAGE, 50)

    -- Define o tempo de proteção futuro (impede o onThink de reduzir)
    player:setStorageValue(HUNGER_FULL_TIME, currentTime + protectionSeconds)
    player:setStorageValue(THIRST_FULL_TIME, currentTime + protectionSeconds)
    
    return true
end