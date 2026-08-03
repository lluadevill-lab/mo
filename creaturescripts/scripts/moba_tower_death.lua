-- creaturescripts/moba_tower_death_event.lua

function onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
    local cid = creature:getId()
    local state = MOBA.MinionState[cid]
    
    if not state or not state.isStructure then
        return true
    end
    
    local teamId = state.teamId
    local lane = state.lane
    local towerIndex = state.towerIndex
    local isNexus = state.isNexus
    
    print("[TOWER DEATH] Team " .. teamId .. " | Lane: " .. tostring(lane) .. " | Index: " .. tostring(towerIndex))
    
    -- IMPORTANTE: Atualiza TowerState no scoreboard
    if MOBA_BOTS and MOBA_BOTS.onTowerDestroyed and lane and towerIndex then
        MOBA_BOTS.onTowerDestroyed(teamId, lane, towerIndex)
    end
    
    -- Atualiza MOBA.Objectives também
    if MOBA.Objectives and MOBA.Objectives[teamId] then
        if lane and towerIndex and MOBA.Objectives[teamId].towers[lane] then
            MOBA.Objectives[teamId].towers[lane][towerIndex] = false
        end
        if isNexus then
            MOBA.Objectives[teamId].nexus = false
        end
    end
    
    -- Recompensa
    local rewardTarget = killer or mostDamageKiller
    if rewardTarget then
        local reward = isNexus and (MOBA.REWARDS.NEXUS or 1000) or (MOBA.REWARDS.TOWER or 500)
        
        if rewardTarget:isPlayer() then
            rewardTarget:addItem(2148, reward)
            rewardTarget:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, 
                (isNexus and "NEXUS DESTRUIDO!" or "Torre destruida!") .. " +" .. reward .. " gold!")
        elseif MOBA_BOTS and MOBA_BOTS.Data[rewardTarget:getId()] then
            MOBA_BOTS.Data[rewardTarget:getId()].gold = (MOBA_BOTS.Data[rewardTarget:getId()].gold or 0) + reward
        end
    end
    
    MOBA.MinionState[cid] = nil
    
    if isNexus then
        local winnerTeam = teamId == 1 and "Sombra" or "Luz"
        Game.broadcastMessage("[MOBA] TIME " .. winnerTeam:upper() .. " VENCEU!", MESSAGE_STATUS_WARNING)
        addEvent(MOBA.endMatch, 5000)
    end
    
    return true
end