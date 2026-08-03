local DmgMultipliers = {
    [1] = 1.0, -- Normal
    [2] = 1.3, -- Hard (leva +30% de dano)
    [3] = 2.0, -- Expert (leva dobro de dano)
    [4] = 5.0  -- Hell (leva 5x de dano)
}

local STORAGE_DIFF = 60001

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    -- Verifica se quem está tomando dano é player
    if not creature:isPlayer() then 
        return primaryDamage, primaryType, secondaryDamage, secondaryType 
    end

    -- Verifica se quem atacou existe e é um monstro (para não aumentar dano de PvP ou fields)
    if not attacker or not attacker:isMonster() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    -- Verifica a dificuldade salva no player
    local diffId = creature:getStorageValue(STORAGE_DIFF)

    if diffId and diffId > 1 and DmgMultipliers[diffId] then
        local mult = DmgMultipliers[diffId]
        
        -- Multiplica os danos
        primaryDamage = primaryDamage * mult
        secondaryDamage = secondaryDamage * mult
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end