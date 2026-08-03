local OPCODE_DUNGEON = 88
local STORAGE_DIFF = 60001
local STORAGE_COOLDOWN_PREFIX = 70000
local GLOBAL_DUNGEON_STATUS = 80000
local STORAGE_START_TIME = 60010

local Dungeons = {
    [1] = { name = "Demon Oak", level = 1, destination = Position(446, 388, 13), center = Position(446, 388, 13), range = 50, cooldown = 0 * 0 * 0 },
    [2] = { name = "Orshabaal", level = 2, destination = Position(497, 387, 13), center = Position(497, 387, 13), range = 50, cooldown = 0 * 0 * 0 },
    [3] = { name = "Ferumbras", level = 3, destination = Position(550, 389, 13), center = Position(550, 389, 13), range = 50, cooldown = 0 * 0 * 0 }
}

local DUNGEON_TIME_LIMIT = 10 * 60 
local DifficultyNames = {[1] = "Normal", [2] = "Hard", [3] = "Expert", [4] = "Hell"}

function onExtendedOpcode(player, opcode, buffer)
    if opcode ~= OPCODE_DUNGEON then return false end
    
    -- >>> HANDSHAKE CRUCIAL <<<
    if buffer == "check_active" then
        if player:getStorageValue(STORAGE_DIFF) > 0 then
            print(">>> SERVER: RE-ENVIANDO BARRA PARA " .. player:getName())
            player:sendExtendedOpcode(OPCODE_DUNGEON, "timer|" .. DUNGEON_TIME_LIMIT)
            player:sendExtendedOpcode(OPCODE_DUNGEON, "progress|0|100")
        end
        return true
    end

    if buffer == "init" then
        local dg1 = math.max(1, player:getStorageValue(75001))
        local dg2 = math.max(1, player:getStorageValue(75002))
        local dg3 = math.max(1, player:getStorageValue(75003))
        player:sendExtendedOpcode(OPCODE_DUNGEON, "unlocks|"..dg1.."|"..dg2.."|"..dg3)
        return true
    end
    
    if buffer == "req_times" then
        for i = 1, 3 do
            local t1 = math.max(0, player:getStorageValue(76000 + (i*10) + 1))
            local t2 = math.max(0, player:getStorageValue(76000 + (i*10) + 2))
            local t3 = math.max(0, player:getStorageValue(76000 + (i*10) + 3))
            local t4 = math.max(0, player:getStorageValue(76000 + (i*10) + 4))
            player:sendExtendedOpcode(OPCODE_DUNGEON, "besttimes|"..i.."|"..t1.."|"..t2.."|"..t3.."|"..t4)
        end
        return true
    end
    
    local action, dungeonIdStr, diffIdStr = buffer:match("([^|]+)|([^|]+)|([^|]+)")
    local dungeonId = tonumber(dungeonIdStr)
    local diffId = tonumber(diffIdStr)
    
    if action == "enter" and dungeonId and diffId then
        local dungeon = Dungeons[dungeonId]
        if not dungeon then return false end
        
        if player:getStorageValue(STORAGE_DIFF) > 0 then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "Voce ja esta em uma dungeon!")
            return false
        end
        
        if player:getLevel() < dungeon.level then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "Level insuficiente.")
            return false
        end
        
        local cdStorage = STORAGE_COOLDOWN_PREFIX + dungeonId
        if player:getStorageValue(cdStorage) > os.time() then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "Dungeon em cooldown.")
            return false
        end
        
        local specs = Game.getSpectators(dungeon.center, false, true, dungeon.range, dungeon.range, dungeon.range, dungeon.range)
        for _, spec in ipairs(specs) do
            if spec:isPlayer() then
                player:sendTextMessage(MESSAGE_STATUS_SMALL, "Sala ocupada por " .. spec:getName() .. ".")
                return false
            end
        end
        
        player:setStorageValue(STORAGE_DIFF, diffId)
        player:setStorageValue(cdStorage, os.time() + dungeon.cooldown)
        player:setStorageValue(60005, 0)
        player:setStorageValue(STORAGE_START_TIME, os.time())
        Game.setStorageValue(GLOBAL_DUNGEON_STATUS + dungeonId, diffId)
        
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        player:teleportTo(dungeon.destination)
        player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
        
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Entrando em " .. dungeon.name .. " (" .. (DifficultyNames[diffId] or "") .. ")!")
        
        -- ENVIA COMANDO INICIAL
        player:sendExtendedOpcode(OPCODE_DUNGEON, "timer|" .. DUNGEON_TIME_LIMIT)
        player:sendExtendedOpcode(OPCODE_DUNGEON, "progress|0|100")
        
        addEvent(function(cid, lobbyPos)
            local p = Player(cid)
            if p and p:getStorageValue(STORAGE_DIFF) > 0 then
                p:setStorageValue(STORAGE_DIFF, 0)
                p:teleportTo(lobbyPos)
                p:sendTextMessage(MESSAGE_STATUS_WARNING, "Tempo esgotado!")
                p:sendExtendedOpcode(OPCODE_DUNGEON, "hide_progress")
            end
        end, DUNGEON_TIME_LIMIT * 1000, player:getId(), Position(499, 368, 12))
    end
end