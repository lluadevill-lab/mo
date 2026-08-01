-- ==========================================================
-- MOBA AI CORE - WAYPOINTS + DESVIO MELHORADO
-- ==========================================================

local function getDistance(a, b)
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

local function getDirectionTo(a, b)
    if b.x > a.x then return DIRECTION_EAST
    elseif b.x < a.x then return DIRECTION_WEST
    elseif b.y > a.y then return DIRECTION_SOUTH
    elseif b.y < a.y then return DIRECTION_NORTH
    end
    return nil
end

-- ============================================================
-- LÓGICA DE INIMIGO
-- ============================================================

local function isEnemy(myCid, targetCid)
    local target = Creature(targetCid)
    if not target then return false end

    local myBotData = nil
    if MOBA_BOTS then myBotData = MOBA_BOTS.Data[myCid] end
    local myState = MOBA.MinionState[myCid]

    local myEnemySkull = SKULL_NONE
    local myTeamId = 0

    if myState then
        myEnemySkull = myState.enemySkull
        myTeamId = myState.teamId
    elseif myBotData then
        myEnemySkull = myBotData.enemySkull
        myTeamId = myBotData.teamId
    else
        return false
    end

    if target:isPlayer() then
        return target:getSkull() == myEnemySkull
    end

    if MOBA_BOTS and MOBA_BOTS.Data[targetCid] then
        return MOBA_BOTS.Data[targetCid].teamId ~= myTeamId
    end

    if target:getSkull() ~= SKULL_NONE then
        return target:getSkull() == myEnemySkull
    end

    local targetState = MOBA.MinionState[targetCid]
    if targetState and targetState.teamId then
        return targetState.teamId ~= myTeamId
    end

    return false
end

-- ============================================================
-- TILE CHECKING
-- ============================================================

local function isFreeTile(pos, myCid)
    local tile = Tile(pos)
    if not tile then return false end
    if tile:hasFlag(TILESTATE_NOTWALKABLE) or tile:hasFlag(TILESTATE_BLOCKSOLID) then return false end

    local creatures = tile:getCreatures()
    if creatures and #creatures > 0 then
        for _, c in ipairs(creatures) do
            if c:isMonster() then
                if c:getId() ~= myCid then
                    return false
                end
            elseif c:isPlayer() then
                local myState = MOBA.MinionState[myCid]
                if myState then
                    if c:getSkull() == myState.enemySkull then
                        return false
                    end
                end
            end
        end
    end

    return true
end

-- Verifica se tile é andável (sem checar criaturas, só terreno)
local function isWalkableTerrain(pos)
    local tile = Tile(pos)
    if not tile then return false end
    if tile:hasFlag(TILESTATE_NOTWALKABLE) or tile:hasFlag(TILESTATE_BLOCKSOLID) then return false end
    return true
end

-- ============================================================
-- MOVIMENTO COM DESVIO INTELIGENTE
-- O minion tenta ir direto. Se bloqueado, tenta desvios
-- cada vez mais amplos (1, 2, 3 tiles de distância)
-- ============================================================

local function moveToward(creature, targetPos)
    local myPos = creature:getPosition()
    local dx = targetPos.x - myPos.x
    local dy = targetPos.y - myPos.y
    local myCid = creature:getId()

    if dx == 0 and dy == 0 then return true end

    -- Direção principal e secundária
    local primaryDirs = {}
    local secondaryDirs = {}

    if math.abs(dx) > math.abs(dy) then
        if dx > 0 then table.insert(primaryDirs, DIRECTION_EAST) else table.insert(primaryDirs, DIRECTION_WEST) end
        if dy > 0 then table.insert(primaryDirs, DIRECTION_SOUTH) elseif dy < 0 then table.insert(primaryDirs, DIRECTION_NORTH) end
        if dy >= 0 then table.insert(secondaryDirs, DIRECTION_NORTH) else table.insert(secondaryDirs, DIRECTION_SOUTH) end
        if dx >= 0 then table.insert(secondaryDirs, DIRECTION_WEST) else table.insert(secondaryDirs, DIRECTION_EAST) end
    elseif math.abs(dy) > math.abs(dx) then
        if dy > 0 then table.insert(primaryDirs, DIRECTION_SOUTH) else table.insert(primaryDirs, DIRECTION_NORTH) end
        if dx > 0 then table.insert(primaryDirs, DIRECTION_EAST) elseif dx < 0 then table.insert(primaryDirs, DIRECTION_WEST) end
        if dx >= 0 then table.insert(secondaryDirs, DIRECTION_WEST) else table.insert(secondaryDirs, DIRECTION_EAST) end
        if dy >= 0 then table.insert(secondaryDirs, DIRECTION_NORTH) else table.insert(secondaryDirs, DIRECTION_SOUTH) end
    else
        if dx > 0 then table.insert(primaryDirs, DIRECTION_EAST) else table.insert(primaryDirs, DIRECTION_WEST) end
        if dy > 0 then table.insert(primaryDirs, DIRECTION_SOUTH) else table.insert(primaryDirs, DIRECTION_NORTH) end
        if dy >= 0 then table.insert(secondaryDirs, DIRECTION_NORTH) else table.insert(secondaryDirs, DIRECTION_SOUTH) end
        if dx >= 0 then table.insert(secondaryDirs, DIRECTION_WEST) else table.insert(secondaryDirs, DIRECTION_EAST) end
    end

    -- Tenta primárias
    for _, dir in ipairs(primaryDirs) do
        local nextPos = Position(myPos.x, myPos.y, myPos.z)
        nextPos:getNextPosition(dir)
        if isFreeTile(nextPos, myCid) then
            creature:move(dir)
            return true
        end
    end

    -- Tenta secundárias
    for _, dir in ipairs(secondaryDirs) do
        local nextPos = Position(myPos.x, myPos.y, myPos.z)
        nextPos:getNextPosition(dir)
        if isFreeTile(nextPos, myCid) then
            creature:move(dir)
            return true
        end
    end

    return false
end

-- ============================================================
-- SISTEMA DE DESVIO AMPLO PARA MINIONS TRAVADOS
-- Quando o minion fica stuck, calcula um ponto de desvio
-- lateral e navega até ele antes de retomar o waypoint
-- ============================================================

local function calculateDetour(creature, state, targetPos)
    local myPos = creature:getPosition()
    local myCid = creature:getId()

    -- Direção principal para o alvo
    local dx = targetPos.x - myPos.x
    local dy = targetPos.y - myPos.y

    -- Calcula perpendiculares
    local perpDirs = {}
    if math.abs(dx) >= math.abs(dy) then
        -- Movendo principalmente em X, desvia em Y
        perpDirs = {{x = 0, y = 1}, {x = 0, y = -1}}
    else
        -- Movendo principalmente em Y, desvia em X
        perpDirs = {{x = 1, y = 0}, {x = -1, y = 0}}
    end

    -- Alterna direção do desvio baseado no stuckCount para não ficar preso
    if not state.detourSide then state.detourSide = 1 end

    -- Tenta desvios de 2 a 5 tiles de distância
    for radius = 2, 5 do
        for _, side in ipairs({state.detourSide, -state.detourSide}) do
            local perpIdx = side > 0 and 1 or 2
            local perp = perpDirs[perpIdx]

            local detourPos = Position(
                myPos.x + (perp.x * radius),
                myPos.y + (perp.y * radius),
                myPos.z
            )

            if isWalkableTerrain(detourPos) then
                return detourPos
            end
        end
    end

    -- Inverte lado para próxima tentativa
    state.detourSide = state.detourSide * -1

    return nil
end

-- ============================================================
-- ATAQUE
-- ============================================================

local function executeAttack(cid, targetId, state)
    local attacker = Creature(cid)
    local target = Creature(targetId)
    if not attacker or not target then return end

    local myPos = attacker:getPosition()
    local targetPos = target:getPosition()

    if not state.isStructure then
        local dir = getDirectionTo(myPos, targetPos)
        if dir then attacker:setDirection(dir) end
    end

    if state.config.type == "ranged" then
        myPos:sendDistanceEffect(
            targetPos,
            state.config.distEffect or CONST_ANI_BOLT
        )
    else
        targetPos:sendMagicEffect(CONST_ME_DRAWBLOOD)
    end

    local min = state.config.minDmg or 10
    local max = state.config.maxDmg or 20
    local dmg = math.random(min, max)

    if not MOBA.FatalKillers then MOBA.FatalKillers = {} end
    local targetCid = target:getId()
    if target:getHealth() <= dmg then
        MOBA.FatalKillers[targetCid] = 0
    end

    if target:getHealth() > 0 then
        target:addHealth(-dmg)
    end

    doTargetCombatHealth(
        cid,
        target,
        COMBAT_PHYSICALDAMAGE,
        -dmg,
        -dmg,
        CONST_ME_NONE
    )
end

-- ============================================================
-- LÓGICA PRINCIPAL DOS MINIONS
-- ============================================================

function MobaMinionLogic(cid)
    local creature = Creature(cid)
    if not creature or creature:getHealth() <= 0 then
        MOBA.MinionState[cid] = nil
        return
    end

    creature:setFollowCreature(nil)

    local state = MOBA.MinionState[cid]
    if not state then return end

    if not state.lastAttack then state.lastAttack = 0 end
    if not state.lastPos then state.lastPos = creature:getPosition() end
    if not state.stuckCount then state.stuckCount = 0 end
    if not state.detourTarget then state.detourTarget = nil end

    local myPos = creature:getPosition()
    local currentTime = os.time() * 1000

    -- Limpa target inválido
    local currentTarget = creature:getTarget()
    if currentTarget and not isEnemy(cid, currentTarget:getId()) then
        creature:setTarget(nil)
    end

    -- =====================
    -- SCAN INIMIGOS
    -- =====================
    local target = nil
    local bestDist = 999
    local scanRange = state.isStructure and 9 or 8

    local specs = Game.getSpectators(myPos, false, false, scanRange, scanRange, scanRange, scanRange)
    for _, spec in ipairs(specs) do
        if spec:getId() ~= cid and spec:getHealth() > 0 and isEnemy(cid, spec:getId()) then
            local d = getDistance(myPos, spec:getPosition())
            if d < bestDist then
                bestDist = d
                target = spec
            end
        end
    end

    local nextThink = 500

    -- =====================
    -- COM ALVO - COMBATE
    -- =====================
    if target then
        state.waypointResumed = false
        state.detourTarget = nil

        if creature:getTarget() ~= target then
            creature:setTarget(target)
        end

        local dist = getDistance(myPos, target:getPosition())
        local range = state.config.range

        if dist <= range then
            if (currentTime - state.lastAttack) >= state.config.attackSpeed then
                executeAttack(cid, target:getId(), state)
                state.lastAttack = currentTime
            end
            nextThink = state.config.attackSpeed
        else
            if not state.isStructure then
                local curPos = creature:getPosition()

                if curPos.x == state.lastPos.x and curPos.y == state.lastPos.y then
                    state.stuckCount = state.stuckCount + 1
                else
                    state.stuckCount = 0
                end

                state.lastPos = curPos

                local dest = target:getPosition()

                -- Se stuck perseguindo inimigo, calcula desvio
                if state.stuckCount >= 3 then
                    local detour = calculateDetour(creature, state, dest)
                    if detour then
                        moveToward(creature, detour)
                    else
                        dest = Position(
                            dest.x + math.random(-2, 2),
                            dest.y + math.random(-2, 2),
                            dest.z
                        )
                        moveToward(creature, dest)
                    end
                    if state.stuckCount >= 6 then
                        state.stuckCount = 0
                    end
                else
                    moveToward(creature, dest)
                end

                nextThink = 800
            end
        end

    -- =====================
    -- SEM ALVO - SEGUE WAYPOINTS
    -- =====================
    else
        creature:setTarget(nil)

        if not state.isStructure then
            local lane = state.lane or "mid"
            local teamId = state.teamId
            local wps = MOBA.getWaypoints(teamId, lane)

	    if wps and #wps > 0 then
                -- Inicializa ou retoma waypoint index
                if not state.wpIndex or not state.waypointResumed then
                    state.wpIndex = MOBA.findNearestWaypoint(myPos, teamId, lane)
                    state.waypointResumed = true
                    state.detourTarget = nil
                end

                -- Detecção de stuck
                local curPos = creature:getPosition()
                if curPos.x == state.lastPos.x and curPos.y == state.lastPos.y then
                    state.stuckCount = state.stuckCount + 1
                else
                    state.stuckCount = 0
                    -- Se estava desviando e conseguiu andar, verifica se chegou no desvio
                    if state.detourTarget then
                        local detDist = getDistance(curPos, state.detourTarget)
                        if detDist <= 1 then
                            state.detourTarget = nil
                        end
                    end
                end
                state.lastPos = curPos

                -- Se está em modo desvio, vai para o ponto de desvio
                if state.detourTarget then
                    moveToward(creature, state.detourTarget)

                    -- Se stuck mesmo desviando, cancela e tenta novo desvio
                    if state.stuckCount >= 4 then
                        state.detourTarget = nil
                        state.stuckCount = 0
                        state.detourSide = (state.detourSide or 1) * -1
                    end

                    nextThink = 500
                else
                    -- Navegação normal por waypoints
                    local wpIdx = state.wpIndex
                    if wpIdx > #wps then wpIdx = #wps end

                    local wpTarget = wps[wpIdx]
                    local wpPos = Position(wpTarget.x, wpTarget.y, wpTarget.z)
                    local distToWp = getDistance(myPos, wpPos)

                    if distToWp <= 2 then
                        state.wpIndex = math.min(wpIdx + 1, #wps)
                        state.stuckCount = 0
                    end

                    local curWp = wps[state.wpIndex]
                    if curWp then
                        local destPos = Position(curWp.x, curWp.y, curWp.z)

                        -- Stuck demais: calcula desvio amplo
                        if state.stuckCount >= 4 then
                            local detour = calculateDetour(creature, state, destPos)
                            if detour then
                                state.detourTarget = detour
                                moveToward(creature, detour)
                            else
                                -- Não encontrou desvio, pula waypoint
                                state.wpIndex = math.min(state.wpIndex + 1, #wps)
                                state.stuckCount = 0
                            end
                        else
                            -- Variação leve para não empilhar
                            local finalDest = Position(
                                destPos.x + math.random(-1, 1),
                                destPos.y + math.random(-1, 1),
                                destPos.z
                            )
                            moveToward(creature, finalDest)
                        end
                    end

                    nextThink = 600
                end
            end
        end
    end

    addEvent(MobaMinionLogic, nextThink, cid)
end

-- ============================================================
-- START AI
-- ============================================================

function MOBA.startAI(cid, teamId, lane)
    local team = MOBA.getTeamById(teamId)
    local creature = Creature(cid)
    local config = MOBA.MINIONS_CONFIG["default"]

    if creature then
        local name = creature:getName():lower()
        for key, conf in pairs(MOBA.MINIONS_CONFIG) do
            if string.find(name, key) then
                config = conf
                break
            end
        end
    end

    local assignedLane = lane or "mid"

    MOBA.MinionState[cid] = {
        teamId = teamId,
        enemySkull = team.enemy_skull,
        lane = assignedLane,
        config = config,
        lastAttack = 0,
        stuckCount = 0,
        wpIndex = 1,
        waypointResumed = true,
        detourTarget = nil,
        detourSide = 1
    }

    MobaMinionLogic(cid)
end