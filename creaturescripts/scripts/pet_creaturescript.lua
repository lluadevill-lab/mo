local ATTACK_BACK_DURATION = 30 -- segundos que o pet lembra do agressor
local attackBackTargets = {} -- tabela global para agressores

function onPrepareDeath(creature, killer)
    local player = creature:getMaster()
    if player then
        player:doKillPet(false)
        player:petSystemMessage("Pet desmaiou.")
    end
    return true
end

function onKill(creature, target)
    if target:isMonster() then
        local player = creature:getMaster()
        local exp = target:getType():getExperience()
        player:addPetExp(exp)
    end
    return true
end

function onThink(creature, interval)
    local owner = creature:getMaster()
    if not owner then return true end

    -- Teleporte se longe do dono
    local maxDistance = 13
    local petPos, ownerPos = creature:getPosition(), owner:getPosition()
    if petPos.z ~= ownerPos.z or ownerPos:getDistance(petPos) >= maxDistance then
        petPos:sendMagicEffect(CONST_ME_TELEPORT)
        creature:teleportTo(ownerPos)
        creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    end
    return true
end

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    local owner = creature:getMaster()
    if attacker and attacker:isPlayer() and owner and attacker:getId() == owner:getId() then
        return 0, primaryType, 0, secondaryType
    end

    -- marca agressor para attack back
    if attacker and attacker:isMonster() then
        attackBackTargets[creature:getId()] = {target = attacker, time = os.time()}
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end
