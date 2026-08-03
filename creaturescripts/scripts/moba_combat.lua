if not MOBA.FatalKillers then MOBA.FatalKillers = {} end

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    
    -- SISTEMA DE DETECÇÃO DE DANO (CRUCIAL PARA A IA)
    if creature:isMonster() and MOBA_BOTS and MOBA_BOTS.Data[creature:getId()] then
        local totalDmg = primaryDamage + secondaryDamage
        if totalDmg > 0 and attacker then
            local name = attacker:getName():lower()
            
            -- 1. Dano de Torre (PRIORIDADE MÁXIMA DE FUGA)
            if string.find(name, "torre") or string.find(name, "nucleo") then
                MOBA_BOTS.registerDamage(creature:getId(), "tower", totalDmg)
            
            -- 2. Dano de Herói (Player ou Bot)
            elseif attacker:isPlayer() or MOBA_BOTS.Data[attacker:getId()] then
                MOBA_BOTS.registerDamage(creature:getId(), "hero", totalDmg)
            
            -- 3. Dano de Minion
            else
                MOBA_BOTS.registerDamage(creature:getId(), "minion", totalDmg)
            end
        end
    end
    
    -- DETECTOR DE LAST HIT
    if creature:isMonster() and primaryDamage > 0 then
        local total = primaryDamage + secondaryDamage
        local cid = creature:getId()
        
        if total >= creature:getHealth() then
            if attacker and attacker:isPlayer() then
                MOBA.FatalKillers[cid] = attacker:getId()
            elseif attacker and attacker:getMaster() and attacker:getMaster():isPlayer() then
                MOBA.FatalKillers[cid] = attacker:getMaster():getId()
            else
                MOBA.FatalKillers[cid] = 0
            end
        end
    end

    -- SISTEMA DE TIMES (Proteção TK)
    if not MOBA.matchActive then return primaryDamage, primaryType, secondaryDamage, secondaryType end
    if not attacker then return primaryDamage, primaryType, secondaryDamage, secondaryType end
    
    local atkTeam = 0
    local tgtTeam = 0
    
    if attacker:isPlayer() then 
        atkTeam = attacker:getStorageValue(MOBA.STORAGE_TEAM)
    elseif MOBA.MinionState and MOBA.MinionState[attacker:getId()] then 
        atkTeam = MOBA.MinionState[attacker:getId()].teamId
    elseif MOBA_BOTS and MOBA_BOTS.Data[attacker:getId()] then 
        atkTeam = MOBA_BOTS.Data[attacker:getId()].teamId
    end
    
    if atkTeam <= 0 then return primaryDamage, primaryType, secondaryDamage, secondaryType end
    
    local cid = creature:getId()
    if creature:isPlayer() then 
        tgtTeam = creature:getStorageValue(MOBA.STORAGE_TEAM)
    elseif MOBA.MinionState and MOBA.MinionState[cid] then 
        tgtTeam = MOBA.MinionState[cid].teamId
    elseif MOBA_BOTS and MOBA_BOTS.Data[cid] then 
        tgtTeam = MOBA_BOTS.Data[cid].teamId
    end
    
    if tgtTeam > 0 and tgtTeam == atkTeam then
        if attacker:isPlayer() then 
            attacker:sendCancelMessage("Voce nao pode atacar aliados.") 
        end
        return false
    end
    
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end