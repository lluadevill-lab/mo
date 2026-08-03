local MONSTER_RANKS = {
    ["rat"] = {1, 5},
    ["cat"] = {1, 3},
    ["spider"] = {5, 12},
    ["urso"] = {15, 25},
    ["dragon"] = {40, 60},
    ["demon"] = {80, 100}
}

local QUALITIES = {
    {name = "Comum", multiplier = 1.0, xpMultiplier = 1.0, chance = 80},
    {name = "Incomum", multiplier = 1.5, xpMultiplier = 1.3, chance = 20},
    {name = "Raro", multiplier = 2.5, xpMultiplier = 2.0, chance = 10},
    {name = "Elite", multiplier = 3.5, xpMultiplier = 3.5, chance = 5},
    {name = "Lendario", multiplier = 6.0, xpMultiplier = 10.0, chance = 2}
}

local function pickQuality()
    local total = 0
    for _, q in ipairs(QUALITIES) do total = total + q.chance end
    local rand = math.random() * total
    local acc = 0
    for _, q in ipairs(QUALITIES) do
        acc = acc + q.chance
        if rand <= acc then return q end
    end
    return QUALITIES[1]
end

function generateGenetics(creature)
    if not creature or not creature:isMonster() or creature:getMaster() then return end
    if not _G.MonsterGenetics then _G.MonsterGenetics = {} end
    if _G.MonsterGenetics[creature:getId()] then return _G.MonsterGenetics[creature:getId()] end

    local name = creature:getName():lower()
    local rankData = MONSTER_RANKS[name] or {1, 10}
    local baseLevel = math.random(rankData[1], rankData[2])
    local quality = pickQuality()

    local ivs = {
        vida = math.random(0, 31), ataque = math.random(0, 31),
        velocidade = math.random(0, 31), defesa = math.random(0, 31),
        resistencia = math.random(0, 31), exp = math.random(0, 31),
        vitalidade = math.random(0, 31)
    }

    _G.MonsterGenetics[creature:getId()] = {
        lvl = baseLevel,
        rankName = quality.name,
        xpMult = quality.xpMultiplier,
        ivs = ivs
    }

    local hpMult = quality.multiplier + (baseLevel * 0.03) + (ivs.vida / 100)
    local newMaxHP = math.floor(creature:getMaxHealth() * hpMult)
    
    creature:setMaxHealth(newMaxHP)
    creature:addHealth(newMaxHP)
    creature:changeSpeed(ivs.velocidade * 2)

    if quality.name == "Lendario" then
        creature:say("RAAAAAWRRR!", TALKTYPE_MONSTER_SAY)
        creature:getPosition():sendMagicEffect(CONST_ME_REDUNDANT_EFEITO_GRANDE)
    elseif quality.name == "Elite" then
        creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
    end
    
    return _G.MonsterGenetics[creature:getId()]
end

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not creature or not attacker then return primaryDamage, primaryType, secondaryDamage, secondaryType end

    if creature:isMonster() and not creature:getMaster() then generateGenetics(creature) end
    if attacker:isMonster() and not attacker:getMaster() then generateGenetics(attacker) end

    if attacker:isMonster() then
        local atkBonus = 1.0
        local master = attacker:getMaster()
        if master and master:isPlayer() then
            local ivAtk = master:getStorageValue(10007)
            if ivAtk > 0 then atkBonus = 1.0 + (ivAtk / 100) end
        elseif _G.MonsterGenetics[attacker:getId()] then
            atkBonus = 1.0 + (_G.MonsterGenetics[attacker:getId()].ivs.ataque / 100)
        end
        primaryDamage = primaryDamage * atkBonus
        secondaryDamage = secondaryDamage * atkBonus
    end

    if creature:isMonster() then
        local defBonus = 1.0
        local resBonus = 1.0
        local master = creature:getMaster()
        if master and master:isPlayer() then
            local ivDef = master:getStorageValue(10009)
            local ivRes = master:getStorageValue(10010)
            if ivDef > 0 then defBonus = 1.0 - (ivDef / 150) end
            if ivRes > 0 then resBonus = 1.0 - (ivRes / 150) end
        elseif _G.MonsterGenetics[creature:getId()] then
            defBonus = 1.0 - (_G.MonsterGenetics[creature:getId()].ivs.defesa / 150)
            resBonus = 1.0 - (_G.MonsterGenetics[creature:getId()].ivs.resistencia / 150)
        end
        
        if primaryType == COMBAT_PHYSICALDAMAGE then
            primaryDamage = primaryDamage * defBonus
        else
            primaryDamage = primaryDamage * resBonus
        end
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function onDeath(creature, corpse, killer, mostDamageKiller, lastHitKiller, mostDamageUnjustified, lastHitUnjustified)
    if not creature or not creature:isMonster() or creature:getMaster() then return true end
    
    local genetics = _G.MonsterGenetics[creature:getId()]
    if genetics and genetics.xpMult and genetics.xpMult > 1.0 then
        local monsterType = creature:getType()
        local baseExperience = monsterType:getExperience()
        
        -- Calcula apenas quanto de XP falta para chegar no multiplicador (ex: x10.0 ganha +900%)
        local bonusExp = math.floor(baseExperience * (genetics.xpMult - 1.0))
        
        -- Se houver um matador, entrega o bônus de XP para ele
        if killer then
            if killer:isPlayer() then
                killer:addExperience(bonusExp, true)
            elseif killer:getMaster() and killer:getMaster():isPlayer() then
                killer:getMaster():addExperience(bonusExp, true)
            end
        end
    end
    
    _G.MonsterGenetics[creature:getId()] = nil
    return true
end