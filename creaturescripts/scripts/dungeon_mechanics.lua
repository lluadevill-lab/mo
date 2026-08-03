local OPCODE_DUNGEON = 88
local STORAGE_KILL_COUNT = 60005 

local DungeonsConfig = {
    [1] = { center = Position(446, 388, 13), range = 50, total = 30 }, 
    [2] = { center = Position(497, 387, 13), range = 50, total = 30 }, 
    [3] = { center = Position(550, 389, 13), range = 50, total = 30 }
}

local function isInDungeonRange(pos, center, range)
    return (math.abs(pos.x - center.x) <= range) and (math.abs(pos.y - center.y) <= range) and (pos.z == center.z)
end

function onKill(creature, target)
    if not creature:isPlayer() or not target:isMonster() then return true end
    
    local pos = creature:getPosition()
    
    for dungeonId, config in pairs(DungeonsConfig) do
        if isInDungeonRange(pos, config.center, config.range) then
            
            -- Incrementa
            local currentKills = math.max(0, creature:getStorageValue(STORAGE_KILL_COUNT)) + 1
            creature:setStorageValue(STORAGE_KILL_COUNT, currentKills)
            
            -- >>> ATUALIZA BARRA CLIENTE <<<
            local payload = "progress|" .. currentKills .. "|" .. config.total
            creature:sendExtendedOpcode(OPCODE_DUNGEON, payload)
            
            return true
        end
    end
    return true
end