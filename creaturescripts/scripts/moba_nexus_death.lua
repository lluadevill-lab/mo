function onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
    if not MOBA.matchActive then return true end
    
    local cid = creature:getId()
    local state = MOBA.MinionState[cid]
    
    if not state then return true end

    -- =========================================================================
    -- 1. NEXUS DESTRUÍDO - FIM DE JOGO
    -- =========================================================================
    if state.isStructure and state.isNexus then
        local loserTeamId = state.teamId
        -- Se o perdedor for o time 1 (Luz), o vencedor é o 2 (Sombra) e vice-versa
        local winnerTeamId = (loserTeamId == 1) and 2 or 1
        
        local loserName = (loserTeamId == 1) and "LUZ" or "SOMBRA"
        local winnerName = (winnerTeamId == 1) and "LUZ" or "SOMBRA"
        
        -- Anúncios
        Game.broadcastMessage("[MOBA] O NUCLEO DO TIME " .. loserName .. " FOI DESTRUIDO!", MESSAGE_EVENT_ADVANCE)
        Game.broadcastMessage("[MOBA] VITORIA DO TIME " .. winnerName .. "!", MESSAGE_STATUS_WARNING)
        
        -- Efeito visual na morte do nexus
        creature:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
        
        -- Marca o nexus como destruído (usado pelo auto-aprendizado / placar)
        if MOBA.Objectives and MOBA.Objectives[loserTeamId] then
            MOBA.Objectives[loserTeamId].nexus = false
        end
        if MOBA_BOTS and MOBA_BOTS.addScore then
            MOBA_BOTS.addScore(winnerTeamId, "nexusDestroyed", 1)
        end
        
        -- Posição do Lobby
        local lobbyPos = Position(1421, 1071, 7)

        -- Trata os Jogadores (Teleporte + Recompensa)
        for _, player in ipairs(Game.getPlayers()) do
            local pTeam = player:getStorageValue(MOBA.STORAGE_TEAM)
            
            -- Verifica se o jogador está participando (Time 1 ou 2)
            if pTeam == 1 or pTeam == 2 then
                
                -- 1. Entrega recompensa aos vencedores
                if pTeam == winnerTeamId then
                    player:addItem(2361, 1) -- Item do vencedor
                    player:sendTextMessage(MESSAGE_INFO_DESCR, "VITORIA! Voce recebeu sua recompensa.")
                    player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
                else
                    player:sendTextMessage(MESSAGE_INFO_DESCR, "DERROTA! Mais sorte na proxima.")
                end
                
                -- 2. Teleporta para o lobby
                player:teleportTo(lobbyPos)
                lobbyPos:sendMagicEffect(CONST_ME_TELEPORT)
                
                -- 3. Reseta status do jogador
                player:setSkull(SKULL_NONE)
                player:setStorageValue(MOBA.STORAGE_TEAM, -1)
                player:addHealth(player:getMaxHealth())
                player:addMana(player:getMaxMana())
                
                -- Remove conditions de batalha
                player:removeCondition(CONDITION_INFIGHT)
                player:removeCondition(CONDITION_FIRE)
                player:removeCondition(CONDITION_POISON)
                player:removeCondition(CONDITION_BLEEDING)
                
                -- Remove registro de eventos (importante para não bugar depois)
                player:unregisterEvent("MobaPrepareDeath")
                player:unregisterEvent("MobaHealthChange")
                player:unregisterEvent("MobaManaChange")
                player:unregisterEvent("MobaKillReward")
                player:unregisterEvent("MobaScoreboard")
            end
        end
        
        -- Chama o endMatch para limpar bots, minions e estruturas restantes
        -- O endMatch vai tentar teleportar jogadores de novo, mas como tiramos o STORAGE_TEAM acima,
        -- ele vai ignorar os players (o que é perfeito, pois já tratamos eles aqui).
        MOBA.endMatch()
        
        return true
    end

    -- =========================================================================
    -- 2. TORRE DESTRUÍDA
    -- =========================================================================
    if state.isStructure and state.towerIndex then
        local teamName = (state.teamId == 1 and "Luz" or "Sombra")
        
        -- Identifica quem matou para a mensagem
        local killerName = "Minions"
        if lasthitkiller then
            if lasthitkiller:isPlayer() then 
                killerName = lasthitkiller:getName()
            elseif MOBA_BOTS and MOBA_BOTS.Data[lasthitkiller:getId()] then 
                killerName = "Bot Hero"
            end
        end
        
        Game.broadcastMessage("[MOBA] Uma torre do time " .. teamName .. " foi destruida por " .. killerName .. "!", MESSAGE_STATUS_CONSOLE_ORANGE)
        
        -- Atualiza Scoreboard dos Bots (Torres destruídas)
        if MOBA_BOTS and MOBA_BOTS.onTowerDestroyed then
            MOBA_BOTS.onTowerDestroyed(state.teamId, state.lane, state.towerIndex)
        end
        
        -- Atualiza Objetivos (para os minions saberem que podem avançar)
        if MOBA.onTowerDestroyed then
            MOBA.onTowerDestroyed(state.teamId, state.lane, state.towerIndex)
        end
    end
    
    -- Limpa estado da memória
    MOBA.MinionState[cid] = nil
    return true
end