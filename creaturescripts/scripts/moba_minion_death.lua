function onDeath(creature, corpse, lasthitkiller, mostdamagekiller)
    local cid = creature:getId()
    -- Limpa a IA da memória
    if MOBA.MinionState[cid] then
        MOBA.MinionState[cid] = nil
    end
    
    -- Tenta encontrar a config do monstro
    local mobName = creature:getName():lower()
    local config = nil
    
    -- Busca parcial (ex: "dwarf" acha config de "dwarf soldier")
    for key, conf in pairs(MOBA.MINIONS_CONFIG) do
        if string.find(mobName, key) then
            config = conf
            break
        end
    end
    
    -- Se não tem config ou não dá gold, sai
    if not config then return true end

    -- === RECOMPENSA LAST HIT (QUEM MATOU) ===
    if lasthitkiller and lasthitkiller:isPlayer() then
        if config.gold > 0 then
            lasthitkiller:addItem(2148, config.gold) -- 2148 = Gold Coin
            lasthitkiller:sendTextMessage(MESSAGE_STATUS_SMALL, "Last Hit! +" .. config.gold .. " gold.")
        end
        if config.xp > 0 then
            lasthitkiller:addExperience(config.xp, true)
        end
    end

    -- === RECOMPENSA ASSISTÊNCIA (QUEM DEU MAIS DANO) ===
    -- Só ganha se for player e for diferente de quem matou
    if mostdamagekiller and mostdamagekiller:isPlayer() and mostdamagekiller:getId() ~= lasthitkiller:getId() then
        -- Ganha 50% do valor (configurado no moba_config)
        local assistGold = math.floor(config.gold * 0.5) 
        local assistXp = math.floor(config.xp * 0.5)
        
        if assistGold > 0 then
            mostdamagekiller:addItem(2148, assistGold)
            mostdamagekiller:sendTextMessage(MESSAGE_STATUS_SMALL, "Assist! +" .. assistGold .. " gold.")
        end
        if assistXp > 0 then
            mostdamagekiller:addExperience(assistXp, true)
        end
    end

    return true
end