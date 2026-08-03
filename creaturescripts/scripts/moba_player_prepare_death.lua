function onPrepareDeath(player, killer)
    if not MOBA.matchActive then return true end

    local skull = player:getSkull()

    if skull == SKULL_GREEN or skull == SKULL_RED then
        local pid = player:getId()
        
        -- >>> REGISTRA STATS (Morte do Player) <<<
        if MOBA_BOTS and MOBA_BOTS.registerStat then
            MOBA_BOTS.registerStat(pid, "death")
            
            -- >>> DETECTA QUEM DEU O KILL <<<
            local killerId = nil
            
            -- Primeiro: Verifica o FatalKillers
            if MOBA.FatalKillers and MOBA.FatalKillers[pid] and MOBA.FatalKillers[pid] > 0 then
                killerId = MOBA.FatalKillers[pid]
                MOBA.FatalKillers[pid] = nil
            elseif killer then
                killerId = killer:getId()
            end
            
            -- Registra o kill
            if killerId and killerId ~= pid then
                local killerCreature = Creature(killerId)
                if killerCreature then
                    if killerCreature:isPlayer() or (MOBA_BOTS.Data and MOBA_BOTS.Data[killerId]) then
                        MOBA_BOTS.registerStat(killerId, "kill")
                        print("[PLAYER DEATH] Kill registrado para: " .. killerCreature:getName())
                    end
                end
            end
        end
        
        -- Recompensa
        local rewardId = nil
        if MOBA.FatalKillers and MOBA.FatalKillers[pid] and MOBA.FatalKillers[pid] > 0 then
            rewardId = MOBA.FatalKillers[pid]
        elseif killer then
            rewardId = killer:getId()
        end
        
        if rewardId and rewardId ~= pid then
            local rewardTarget = Creature(rewardId)
            if rewardTarget and rewardTarget:isPlayer() then
                local reward = MOBA.REWARDS.PLAYER_KILL
                rewardTarget:addItem(2148, reward)
                rewardTarget:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Kill! +" .. reward .. " gold!")
            end
        end

        local team = (skull == SKULL_GREEN) and MOBA.TEAMS.LEFT or MOBA.TEAMS.RIGHT
        local basePos = Position(team.spawnPos.x, team.spawnPos.y, team.spawnPos.z)

        player:teleportTo(basePos)
        basePos:sendMagicEffect(CONST_ME_TELEPORT)
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "Voce renasceu na base!")

        addEvent(function(playerId)
            local p = Player(playerId)
            if p then
                p:addHealth(p:getMaxHealth())
                p:addMana(p:getMaxMana())
                p:removeCondition(CONDITION_FIRE)
                p:removeCondition(CONDITION_POISON)
                p:removeCondition(CONDITION_BLEEDING)
                p:removeCondition(CONDITION_INFIGHT)
            end
        end, 100, pid)

        return false
    end

    return true
end