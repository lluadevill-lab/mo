local PET_ATTACK_RANGE = {x = 7, y = 5, targetDistance = 1, walkDistance = 7}
local DAMAGE = {min = 10, max = 20}

local targetId = 0
local masterPosition = nil

function Creature.isAttackable(self)
    if self:isPlayer() then
        return false
    end

    if self:isMonster() then
        local master = self:getMaster()
        if master and master:isPlayer() then
            return true
        end
    end

    return false
end

function Npc.searchTarget(self)
    local pos = self:getPosition()
    for _, spectator in ipairs(Game.getSpectators(pos, false, false, PET_ATTACK_RANGE.x, PET_ATTACK_RANGE.x, PET_ATTACK_RANGE.y, PET_ATTACK_RANGE.y)) do
        if spectator:isAttackable() then
            targetId = spectator:getId()
            break
        end
    end
end

function onThink()
    local npc = Creature()
    if not masterPosition then
        masterPosition = npc:getPosition()
    end

    local target = Creature(targetId)

    -- Se não tem alvo ou alvo morreu
    if not target or not target:isCreature() then
        npc:searchTarget()
        return true
    end

    local npcPos = npc:getPosition()
    local targetPos = target:getPosition()
    local offsetX = math.abs(npcPos.x - targetPos.x)
    local offsetY = math.abs(npcPos.y - targetPos.y)

    -- Alvo fora do alcance
    if offsetX > PET_ATTACK_RANGE.x or offsetY > PET_ATTACK_RANGE.y then
        npc:searchTarget()
        return true
    end

    -- Volta para a posição do master se estiver muito longe
    if npcPos:getDistance(masterPosition) > PET_ATTACK_RANGE.walkDistance then
        npcPos:sendMagicEffect(CONST_ME_TELEPORT)
        npc:teleportTo(masterPosition)
        return true
    end

    -- Ataque
    doTargetCombatHealth(npc:getId(), target:getId(), COMBAT_PHYSICALDAMAGE, -DAMAGE.min, -DAMAGE.max, CONST_ME_HITAREA)
    npcPos:sendDistanceEffect(targetPos, CONST_ANI_PHYSICAL)

    -- Seguir alvo
    local path = npc:getPathTo(targetPos, 0, PET_ATTACK_RANGE.targetDistance, true, true)
    if path and npcPos:getDistance(targetPos) > PET_ATTACK_RANGE.targetDistance then
        doMoveCreature(npc:getId(), path[1])
    end

    return true
end

function onCreatureAppear(creature)
    if creature == Creature() and not masterPosition then
        masterPosition = creature:getPosition()
    end
end

function onCreatureDisappear(creature)
    if targetId == creature:getId() then
        targetId = 0
    end
end

function onHealthChange(attacker, attackerPos, combat, value)
    local npc = Creature()
    if attacker and attacker:isMonster() and attacker:getMaster() and attacker:getMaster():isPlayer() then
        targetId = attacker:getId()
    end
end
