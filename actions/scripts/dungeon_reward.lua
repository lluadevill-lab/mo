local OPCODE_DUNGEON = 88
local CONFIG = {
    lobbyPosition = Position(499, 368, 12),
    globalStorageBase = 80000,
    storageKillCount = 60005,
    storageUnlockPrefix = 75000,
    storageStartTime = 60010,
    dungeonTotals = {[1] = 50, [2] = 1, [3] = 30},
    rewards = {
        [5001] = {dungeonId = 1, basic = {id = 2152, count = 1}, full = {id = 2160, count = 5}},
        [5002] = {dungeonId = 2, basic = {id = 2160, count = 1}, full = {id = 2472, count = 5}},
        [5003] = {dungeonId = 3, basic = {id = 2160, count = 1}, full = {id = 2520, count = 5}}
    }
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local config = CONFIG.rewards[item.actionid]
    if not config then return false end
    
    local kills = math.max(0, player:getStorageValue(CONFIG.storageKillCount))
    local totalNeeded = CONFIG.dungeonTotals[config.dungeonId] or 100
    local percent = (kills / totalNeeded) * 100
    
    if player:getFreeCapacity() < 100 then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Sem cap.")
        return true
    end

    local startTime = player:getStorageValue(CONFIG.storageStartTime)
    local timeTaken = os.time() - startTime
    local currentDiff = player:getStorageValue(60001)
    local recordStorage = 76000 + (config.dungeonId * 10) + currentDiff
    local currentRecord = player:getStorageValue(recordStorage)

    if percent >= 100 then
        player:addItem(config.full.id, config.full.count)
        
        local unlockStorage = CONFIG.storageUnlockPrefix + config.dungeonId
        local currentUnlock = math.max(1, player:getStorageValue(unlockStorage))
        if currentDiff == currentUnlock and currentUnlock < 4 then
            player:setStorageValue(unlockStorage, currentUnlock + 1)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "DIFICULDADE DESBLOQUEADA!")
        end
        
        if currentRecord <= 0 or timeTaken < currentRecord then
            player:setStorageValue(recordStorage, timeTaken)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "NOVO RECORDE!")
        end
        player:sendTextMessage(MESSAGE_INFO_DESCR, "SUCESSO 100%!")
    elseif percent >= 80 then
        player:addItem(config.basic.id, config.basic.count)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "SUCESSO BASICO.")
    else
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "FALHA.")
    end

    Game.setStorageValue(CONFIG.globalStorageBase + config.dungeonId, 0)
    player:setStorageValue(60001, 0)
    player:setStorageValue(CONFIG.storageKillCount, 0)
    
    -- >>> ESCONDE BARRA <<<
    player:sendExtendedOpcode(OPCODE_DUNGEON, "hide_progress")
    
    player:teleportTo(CONFIG.lobbyPosition)
    player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    return true
end