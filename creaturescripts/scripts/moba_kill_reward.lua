function onKill(player, target, lastHit)
    -- Verifica se é monstro e se foi last hit
    if not lastHit or not target or not target:isMonster() then return true end
    
    -- Verifica se o jogo está ativo
    if not MOBA or not MOBA.matchActive then return true end

    local mobName = target:getName():lower()
    local config = nil

    -- Procura na config
    for key, conf in pairs(MOBA.MINIONS_CONFIG) do
        if string.find(mobName, key) then
            config = conf
            break
        end
    end

    -- Se achou e tem gold
    if config and config.gold > 0 then
        -- Limpa IA do mob morto
        local cid = target:getId()
        if MOBA.MinionState[cid] then MOBA.MinionState[cid] = nil end

        -- Dá o Ouro (addItem funciona, StoreInbox as vezes não)
        player:addItem(2148, config.gold) 
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "+" .. config.gold .. " gold.")
        
        -- Dá XP
        if config.xp > 0 then
            player:addExperience(config.xp, true)
        end
    end

    return true
end