function onPrepareDeath(creature, killer)
    local cid = creature:getId()
    local oldData = MOBA_BOTS.Data[cid]
    
    if not oldData then return true end
    
    -- >>> REGISTRA MORTE DO BOT <<<
    if MOBA_BOTS and MOBA_BOTS.registerStat then
        MOBA_BOTS.registerStat(cid, "death")
        
        -- >>> DETECTA QUEM DEU O KILL <<<
        local killerId = nil
        
        -- Primeiro: Verifica o FatalKillers (último dano fatal)
        if MOBA.FatalKillers and MOBA.FatalKillers[cid] and MOBA.FatalKillers[cid] > 0 then
            killerId = MOBA.FatalKillers[cid]
            MOBA.FatalKillers[cid] = nil
        elseif killer then
            killerId = killer:getId()
        end
        
        -- Registra o kill para quem matou
        if killerId and killerId ~= cid then
            local killerCreature = Creature(killerId)
            if killerCreature then
                if killerCreature:isPlayer() or (MOBA_BOTS.Data and MOBA_BOTS.Data[killerId]) then
                    MOBA_BOTS.registerStat(killerId, "kill")
                    print("[BOT DEATH] Kill registrado para: " .. killerCreature:getName())
                end
            end
        end
    end
    
    -- Recompensa ao Killer
    local rewardId = nil
    if MOBA.FatalKillers and MOBA.FatalKillers[cid] and MOBA.FatalKillers[cid] > 0 then
        rewardId = MOBA.FatalKillers[cid]
    elseif killer then
        rewardId = killer:getId()
    end
    
    if rewardId and rewardId ~= cid then
        local rewardTarget = Creature(rewardId)
        if rewardTarget then
            local reward = MOBA.REWARDS.PLAYER_KILL or 300
            if rewardTarget:isPlayer() then
                rewardTarget:addItem(2148, reward)
                rewardTarget:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Voce matou um Bot! +" .. reward .. " gold!")
            elseif MOBA_BOTS.Data[rewardId] then
                MOBA_BOTS.Data[rewardId].gold = (MOBA_BOTS.Data[rewardId].gold or 0) + reward
            end
        end
    end

    -- Salva dados para o clone
    local teamId = oldData.teamId
    local className = oldData.class
    local savedLevel = oldData.level
    local savedExp = oldData.exp
    local savedGold = oldData.gold
    local savedSkill = oldData.skill
    local savedUid = oldData.uniqueId
    local savedLane = oldData.assignedLane

    -- AGORA PODE LIMPAR
    if MOBA_BOTS.cleanupDebuffs then
        MOBA_BOTS.cleanupDebuffs(cid)
    end
    MOBA_BOTS.Data[cid] = nil
    if MOBA.MinionState then MOBA.MinionState[cid] = nil end

    local classDisplay = className:gsub("^%l", string.upper)

    addEvent(function()
        if MOBA.matchActive then
            print(">> [BOT RESPAWN] " .. classDisplay .. " Time " .. teamId)
            MOBA_BOTS.respawnClone(teamId, className, savedLevel, savedExp, savedGold, savedSkill, savedUid, savedLane)
        end
    end, 5000)

    return true
end