-- ============================================
-- ULTIMATE REALISTIC WOLF PACK SCRIPT v2.1
-- CORREÇÕES: Menos spam, melhor posicionamento, corpo correto
-- ============================================

local MONSTER_NAME = "War Wolf"
local PREY_NAMES = {"Deer"}
local DEFAULT_INTERVAL = 800
local HUNTING_INTERVAL = 300
local FEEDING_INTERVAL = 3000
local COMBAT_INTERVAL = 1500

local AREA_FROM = Position(434, 375, 13)
local AREA_TO = Position(562, 479, 13)

-- CONFIGURAÇÕES DE MATILHA
local PACK_MAX_DISTANCE = 10
local PACK_DETECTION_RANGE = 12
local ALPHA_BONUS_DAMAGE = 10

-- CONFIGURAÇÕES DE CAÇA
local PREY_DETECTION_RANGE = 15
local ISOLATED_PREY_DISTANCE = 6
local SURROUND_DISTANCE = 5
local CHASE_DISTANCE = 20
local AMBUSH_POSITIONS = 4

-- CONFIGURAÇÕES DE ALIMENTAÇÃO
local HUNT_COOLDOWN_TIME = 120
local FEEDING_DURATION = 60
local CORPSE_DEER_FRESH = 3095
local CORPSE_DEER_EATEN = 3096
local FEEDING_DISTANCE = 1

-- Tabelas Globais
local wolfState = {}
local packs = {}
local wolfToPack = {}
local nextPackId = 1
local huntTargets = {}
local feedingSessions = {}

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================

local function isInArray(arr, val)
    for _, v in ipairs(arr) do
        if v == val then return true end
    end
    return false
end

local function getDistance(a, b)
    if not a or not b then return 999 end
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

local function posToKey(pos)
    return pos.x .. "," .. pos.y .. "," .. pos.z
end

local function copyPos(pos)
    if not pos then return nil end
    return Position(pos.x, pos.y, pos.z)
end

local function inBounds(pos)
    if not pos then return false end
    return pos.x >= AREA_FROM.x and pos.x <= AREA_TO.x and
           pos.y >= AREA_FROM.y and pos.y <= AREA_TO.y and
           pos.z == AREA_FROM.z
end

-- ============================================
-- TILE CHECKING
-- ============================================

local function isWalkable(pos, ignoreCreatures)
    if not pos or not inBounds(pos) then return false end
    
    local tile = Tile(pos)
    if not tile then return false end
    
    local ground = tile:getGround()
    if not ground then return false end
    
    local gName = ItemType(ground:getId()):getName():lower()
    if gName:find("water") or gName:find("lava") or gName:find("swamp") then
        return false
    end
    
    if tile:hasFlag(TILESTATE_NOTWALKABLE) or tile:hasFlag(TILESTATE_TELEPORT) or
       tile:hasFlag(TILESTATE_HOLE) or tile:hasFlag(TILESTATE_NOFLOOR) or
       tile:hasFlag(TILESTATE_FLOORCHANGE) then
        return false
    end
    
    if not ignoreCreatures and tile:getCreatureCount() > 0 then
        return false
    end
    
    local items = tile:getItems()
    if items then
        for _, it in ipairs(items) do
            if it:getType():isBlocking() then return false end
        end
    end
    
    return true
end

-- ============================================
-- A* PATHFINDING
-- ============================================

local function findAStarPath(start, goal, isTargetInteractable)
    if not goal then return nil end
    
    local maxNodes, nodesChecked = 500, 0
    local closed, open, cameFrom = {}, {start}, {}
    local gScore, fScore = {[posToKey(start)] = 0}, {[posToKey(start)] = getDistance(start, goal)}
    
    while #open > 0 do
        nodesChecked = nodesChecked + 1
        if nodesChecked > maxNodes then return nil end
        
        local current, ci = open[1], 1
        for i, p in ipairs(open) do
            if fScore[posToKey(p)] < fScore[posToKey(current)] then current, ci = p, i end
        end
        table.remove(open, ci)
        
        local distToGoal = getDistance(current, goal)
        local reached = false
        if isTargetInteractable then
            if distToGoal <= 1 then reached = true end
        else
            if current.x == goal.x and current.y == goal.y then reached = true end
        end

        if reached then
            local path, temp = {}, current
            while temp do
                local parent = cameFrom[posToKey(temp)]
                if parent then table.insert(path, 1, temp) end
                temp = parent
            end
            return path
        end
        
        closed[posToKey(current)] = true
        
        for dx = -1, 1 do
            for dy = -1, 1 do
                if not (dx == 0 and dy == 0) then
                    local n = Position(current.x + dx, current.y + dy, current.z)
                    local isGoalPos = (n.x == goal.x and n.y == goal.y)
                    
                    local walkable = isWalkable(n, false)
                    if isGoalPos and not isTargetInteractable then walkable = true end 

                    if walkable and not closed[posToKey(n)] then
                        local weight = (dx ~= 0 and dy ~= 0) and 3.0 or 1.0
                        
                        local g = gScore[posToKey(current)] + weight
                        if g < (gScore[posToKey(n)] or math.huge) then
                            cameFrom[posToKey(n)] = current
                            gScore[posToKey(n)] = g
                            fScore[posToKey(n)] = g + getDistance(n, goal)
                            
                            local inOpen = false
                            for _, op in ipairs(open) do
                                if op.x == n.x and op.y == n.y then inOpen = true break end
                            end
                            if not inOpen then table.insert(open, n) end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

local function getDirectionTo(a, b)
    local dx, dy = b.x - a.x, b.y - a.y
    if dx > 0 and dy == 0 then return DIRECTION_EAST
    elseif dx < 0 and dy == 0 then return DIRECTION_WEST
    elseif dx == 0 and dy > 0 then return DIRECTION_SOUTH
    elseif dx == 0 and dy < 0 then return DIRECTION_NORTH
    elseif dx > 0 and dy > 0 then return DIRECTION_SOUTHEAST
    elseif dx > 0 and dy < 0 then return DIRECTION_NORTHEAST
    elseif dx < 0 and dy > 0 then return DIRECTION_SOUTHWEST
    elseif dx < 0 and dy < 0 then return DIRECTION_NORTHWEST
    end
    return nil
end

local function getRandomNearbyWalkable(pos, range)
    for _ = 1, 15 do
        local x = pos.x + math.random(-range, range)
        local y = pos.y + math.random(-range, range)
        local p = Position(x, y, pos.z)
        if (x ~= pos.x or y ~= pos.y) and isWalkable(p, false) then
            return p
        end
    end
    return nil
end

-- ============================================
-- SISTEMA DE MATILHA
-- ============================================

local function getPack(id)
    local pid = wolfToPack[id]
    if pid and packs[pid] then return packs[pid], pid end
    return nil, nil
end

local function isAlpha(id)
    local pack = getPack(id)
    return pack and pack.alphaId == id
end

local function electAlpha(pack)
    if not pack then return end
    
    if pack.alphaId then
        local old = Monster(pack.alphaId)
        if old then old:setSkull(SKULL_NONE) end
    end
    
    local best, bestHp = nil, 0
    for _, id in ipairs(pack.members) do
        local m = Monster(id)
        if m and m:getHealth() > 0 then
            if m:getHealth() > bestHp then
                bestHp = m:getHealth()
                best = m
            end
        end
    end
    
    if best then
        pack.alphaId = best:getId()
        best:setSkull(SKULL_RED)
        best:say("*HOWL!*", TALKTYPE_MONSTER_YELL)
        best:getPosition():sendMagicEffect(CONST_ME_FIREATTACK)
    else
        pack.alphaId = nil
    end
end

local function removeFromPack(id)
    local pack, pid = getPack(id)
    if not pack then return end
    
    for i, mid in ipairs(pack.members) do
        if mid == id then
            table.remove(pack.members, i)
            break
        end
    end
    
    if pack.alphaId == id then
        local m = Monster(id)
        if m then m:setSkull(SKULL_NONE) end
        pack.alphaId = nil
        electAlpha(pack)
    end
    
    if #pack.members == 0 then
        packs[pid] = nil
        huntTargets[pid] = nil
        feedingSessions[pid] = nil
    end
    
    wolfToPack[id] = nil
end

local function createPack(founderId)
    local pid = nextPackId
    nextPackId = nextPackId + 1
    packs[pid] = {
        alphaId = nil,
        members = {founderId},
        lastHuntTime = 0
    }
    wolfToPack[founderId] = pid
    electAlpha(packs[pid])
    return pid
end

local function joinPack(id, pid)
    local pack = packs[pid]
    if not pack then return end
    removeFromPack(id)
    table.insert(pack.members, id)
    wolfToPack[id] = pid
end

local function findWolvesNearby(pos, range, myId)
    if not pos then return {} end
    local wolves = {}
    local specs = Game.getSpectators(pos, false, false, range, range, range, range)
    for _, c in ipairs(specs) do
        if c:isMonster() and c:getName() == MONSTER_NAME and c:getId() ~= myId then
            table.insert(wolves, c)
        end
    end
    return wolves
end

local function joinOrCreatePack(id, pos)
    if getPack(id) then return end
    
    local nearby = findWolvesNearby(pos, PACK_DETECTION_RANGE, id)
    for _, w in ipairs(nearby) do
        local pack, pid = getPack(w:getId())
        if pack then
            joinPack(id, pid)
            return
        end
    end
    
    createPack(id)
end

-- ============================================
-- DETECÇÃO DE PRESAS
-- ============================================

local function findPreyNearby(pos, range)
    if not pos then return {} end
    local prey = {}
    local specs = Game.getSpectators(pos, false, false, range, range, range, range)
    for _, c in ipairs(specs) do
        if c:isMonster() and isInArray(PREY_NAMES, c:getName()) and c:getHealth() > 0 then
            table.insert(prey, c)
        end
    end
    return prey
end

local function getPreyIsolationScore(preyPos, allPrey)
    local minDistToOther = 999
    
    for _, otherPrey in ipairs(allPrey) do
        local otherPos = otherPrey:getPosition()
        if not (otherPos.x == preyPos.x and otherPos.y == preyPos.y) then
            local dist = getDistance(preyPos, otherPos)
            if dist < minDistToOther then
                minDistToOther = dist
            end
        end
    end
    
    return minDistToOther
end

local function findBestTarget(wolfPos, allPrey)
    if not allPrey or #allPrey == 0 then return nil end
    
    local bestTarget = nil
    local bestScore = -999
    
    for _, prey in ipairs(allPrey) do
        local preyPos = prey:getPosition()
        local distToWolf = getDistance(wolfPos, preyPos)
        
        if distToWolf <= CHASE_DISTANCE then
            local isolationScore = getPreyIsolationScore(preyPos, allPrey)
            local healthPercent = (prey:getHealth() / prey:getMaxHealth()) * 100
            
            local score = isolationScore * 10
            score = score + (100 - healthPercent) * 0.5
            score = score - distToWolf * 0.3
            
            if score > bestScore then
                bestScore = score
                bestTarget = prey
            end
        end
    end
    
    return bestTarget
end

-- ============================================
-- SISTEMA DE ALIMENTAÇÃO (CORRIGIDO!)
-- ============================================

local function findWalkablePositionsAround(centerPos, numPositions)
    local positions = {}
    local tried = {}
    
    -- Tenta em múltiplos raios (1, 2, 3 sqm)
    for radius = 1, 3 do
        local angleStep = (2 * math.pi) / 8  -- 8 direções
        
        for i = 0, 7 do
            local angle = i * angleStep
            local x = centerPos.x + math.floor(math.cos(angle) * radius)
            local y = centerPos.y + math.floor(math.sin(angle) * radius)
            local pos = Position(x, y, centerPos.z)
            local key = posToKey(pos)
            
            if inBounds(pos) and not tried[key] then
                tried[key] = true
                if isWalkable(pos, true) then  -- Ignora criaturas
                    table.insert(positions, pos)
                    if #positions >= numPositions then
                        return positions
                    end
                end
            end
        end
    end
    
    -- Se não encontrou posições suficientes, adiciona a própria posição do corpo
    while #positions < numPositions do
        table.insert(positions, copyPos(centerPos))
    end
    
    return positions
end

local function transformCorpse(corpsePos)
    if not corpsePos then return false end
    
    local tile = Tile(corpsePos)
    if not tile then return false end
    
    -- REMOVE o corpo antigo
    local corpse = tile:getItemById(CORPSE_DEER_FRESH)
    if corpse then
        corpse:remove(1)
        
        -- CRIA o novo corpo
        local newCorpse = Game.createItem(CORPSE_DEER_EATEN, 1, corpsePos)
        if newCorpse then
            corpsePos:sendMagicEffect(CONST_ME_GROUNDSHAKER)
            corpsePos:sendMagicEffect(CONST_ME_HITBYFIRE)
            return true
        end
    end
    
    return false
end

local function startFeeding(pack, packId, corpsePos)
    if not pack or not corpsePos then return end
    
    -- Encontra posições walkable ao redor do corpo
    local feedingPositions = findWalkablePositionsAround(corpsePos, #pack.members)
    
    feedingSessions[packId] = {
        corpsePos = copyPos(corpsePos),
        startTime = os.time(),
        finished = false,
        assignments = {}
    }
    
    local posIndex = 1
    for _, id in ipairs(pack.members) do
        if posIndex <= #feedingPositions then
            feedingSessions[packId].assignments[id] = feedingPositions[posIndex]
            posIndex = posIndex + 1
        else
            -- Fallback: corpo mesmo
            feedingSessions[packId].assignments[id] = copyPos(corpsePos)
        end
    end
    
    if pack.alphaId then
        local alpha = Monster(pack.alphaId)
        if alpha then
            alpha:say("*FEAST!*", TALKTYPE_MONSTER_YELL)
            corpsePos:sendMagicEffect(CONST_ME_MORTAREA)
        end
    end
end

local function updateFeeding(pack, packId)
    if not pack then return end
    
    local feeding = feedingSessions[packId]
    if not feeding then return end
    
    local now = os.time()
    local elapsed = now - feeding.startTime
    
    if elapsed >= FEEDING_DURATION and not feeding.finished then
        transformCorpse(feeding.corpsePos)
        feeding.finished = true
        pack.lastHuntTime = now
        
        if pack.alphaId then
            local alpha = Monster(pack.alphaId)
            if alpha then
                alpha:say("*satisfied*", TALKTYPE_MONSTER_SAY)
            end
        end
        
        addEvent(function()
            feedingSessions[packId] = nil
        end, 5000)
    end
end

-- ============================================
-- SISTEMA DE CAÇA COORDENADA
-- ============================================

local function calculateSurroundPositions(targetPos, numPositions)
    local positions = {}
    local angleStep = (2 * math.pi) / numPositions
    
    for i = 0, numPositions - 1 do
        local angle = i * angleStep
        local x = targetPos.x + math.floor(math.cos(angle) * SURROUND_DISTANCE)
        local y = targetPos.y + math.floor(math.sin(angle) * SURROUND_DISTANCE)
        local pos = Position(x, y, targetPos.z)
        
        if inBounds(pos) then
            table.insert(positions, pos)
        end
    end
    
    return positions
end

local function assignHuntingRoles(pack, targetPos)
    if not pack or not targetPos then return end
    
    local assignments = {}
    local surroundPos = calculateSurroundPositions(targetPos, AMBUSH_POSITIONS)
    
    local packMembers = {}
    for _, id in ipairs(pack.members) do
        local w = Monster(id)
        if w and w:getHealth() > 0 then
            table.insert(packMembers, {id = id, wolf = w})
        end
    end
    
    if pack.alphaId then
        assignments[pack.alphaId] = {role = "CHASE", target = targetPos}
    end
    
    local posIndex = 1
    for _, member in ipairs(packMembers) do
        if member.id ~= pack.alphaId and posIndex <= #surroundPos then
            assignments[member.id] = {
                role = "SURROUND",
                target = targetPos,
                position = surroundPos[posIndex]
            }
            posIndex = posIndex + 1
        elseif member.id ~= pack.alphaId then
            assignments[member.id] = {role = "CHASE", target = targetPos}
        end
    end
    
    return assignments
end

local function updateHunt(pack, pid)
    if not pack then return end
    
    local hunt = huntTargets[pid]
    if not hunt then return end
    
    local target = Monster(hunt.targetId) or Creature(hunt.targetId)
    if not target or target:getHealth() <= 0 then
        local corpsePos = hunt.lastKnownPos
        huntTargets[pid] = nil
        startFeeding(pack, pid, corpsePos)
        return
    end
    
    local targetPos = target:getPosition()
    hunt.lastKnownPos = copyPos(targetPos)
    hunt.assignments = assignHuntingRoles(pack, targetPos)
end

local function startHunt(pack, pid, target)
    if not pack or not target then return end
    
    huntTargets[pid] = {
        targetId = target:getId(),
        huntStartTime = os.time(),
        lastKnownPos = copyPos(target:getPosition()),
        assignments = {}
    }
    
    updateHunt(pack, pid)
    
    if pack.alphaId then
        local alpha = Monster(pack.alphaId)
        if alpha then
            alpha:say("*HUNT!*", TALKTYPE_MONSTER_YELL)
            alpha:getPosition():sendMagicEffect(CONST_ME_FIREATTACK)
        end
    end
end

-- ============================================
-- COMBATE
-- ============================================

local function attackTarget(wolf, target, wolfId)
    if not wolf or not target then return false end
    
    local wolfPos = wolf:getPosition()
    local targetPos = target:getPosition()
    
    if getDistance(wolfPos, targetPos) <= 1 then
        local damage = math.random(20, 40)
        
        if isAlpha(wolfId) then
            damage = damage + ALPHA_BONUS_DAMAGE
        end
        
        target:addHealth(-damage)
        targetPos:sendMagicEffect(CONST_ME_DRAWBLOOD)
        
        -- Reduz spam: apenas 20% de chance de falar
        if math.random(100) <= 20 then
            wolf:say("*BITE!*", TALKTYPE_MONSTER_SAY)
        end
        
        return true
    end
    
    return false
end

-- ============================================
-- LOOP PRINCIPAL DO LOBO
-- ============================================

local function wolfLoop(id)
    local wolf = Monster(id)
    if not wolf then
        removeFromPack(id)
        wolfState[id] = nil
        return
    end
    
    local st = wolfState[id]
    if not st then return end
    
    if wolf:getHealth() <= 0 then
        removeFromPack(id)
        wolfState[id] = nil
        return
    end

    local pos = wolf:getPosition()
    local now = os.time()
    local interval = DEFAULT_INTERVAL
    
    joinOrCreatePack(id, pos)
    
    local pack, packId = getPack(id)
    local amAlpha = isAlpha(id)
    local hunt = pack and huntTargets[packId]
    local feeding = pack and feedingSessions[packId]
    
    -- ==========================================
    -- 1. MODO ALIMENTAÇÃO
    -- ==========================================
    if feeding and not feeding.finished then
        interval = FEEDING_INTERVAL
        
        local myFeedingPos = feeding.assignments[id]
        if myFeedingPos then
            local distToFeeding = getDistance(pos, myFeedingPos)
            
            if distToFeeding <= 1 then
                -- ESTÁ COMENDO!
                local dir = getDirectionTo(pos, feeding.corpsePos)
                if dir then wolf:setDirection(dir) end
                
                -- Reduz spam: apenas 10% de chance de falar
                if math.random(100) <= 10 then
                    local eatSounds = {"*chomp*", "*gnaw*", "*crunch*"}
                    wolf:say(eatSounds[math.random(#eatSounds)], TALKTYPE_MONSTER_SAY)
                end
                
                -- Efeito visual ocasional
                if math.random(100) <= 15 then
                    pos:sendMagicEffect(CONST_ME_HITBYFIRE)
                end
                
                if amAlpha then
                    updateFeeding(pack, packId)
                end
                
                addEvent(wolfLoop, FEEDING_INTERVAL, id)
                return
            else
                -- Indo para posição de alimentação
                if #st.astar == 0 then
                    local path = findAStarPath(pos, myFeedingPos, false)
                    if path and #path > 0 then
                        st.astar = path
                    else
                        -- Se não conseguir path, tenta ir direto ao corpo
                        path = findAStarPath(pos, feeding.corpsePos, false)
                        if path and #path > 0 then
                            st.astar = path
                        end
                    end
                end
                goto movement_phase
            end
        end
    end
    
    -- ==========================================
    -- 2. MODO CAÇA ATIVA
    -- ==========================================
    if hunt then
        interval = HUNTING_INTERVAL
        
        local assignment = hunt.assignments[id]
        local target = Monster(hunt.targetId) or Creature(hunt.targetId)
        
        if target and target:getHealth() > 0 then
            local targetPos = target:getPosition()
            
            if attackTarget(wolf, target, id) then
                st.lastAttackTime = os.mtime()
                addEvent(wolfLoop, COMBAT_INTERVAL, id)
                return
            end
            
            if assignment then
                if assignment.role == "CHASE" then
                    if #st.astar == 0 then
                        local path = findAStarPath(pos, targetPos, true)
                        if path and #path > 0 then
                            st.astar = path
                            -- Reduz spam: apenas 10% de chance
                            if math.random(100) <= 10 then
                                wolf:say("*growl*", TALKTYPE_MONSTER_SAY)
                            end
                        end
                    end
                elseif assignment.role == "SURROUND" and assignment.position then
                    local distToSurroundPos = getDistance(pos, assignment.position)
                    
                    if distToSurroundPos <= 1 then
                        if #st.astar == 0 then
                            local path = findAStarPath(pos, targetPos, true)
                            if path and #path > 0 then
                                st.astar = path
                            end
                        end
                    else
                        if #st.astar == 0 then
                            local path = findAStarPath(pos, assignment.position, false)
                            if path and #path > 0 then
                                st.astar = path
                                -- Reduz spam: apenas 5% de chance
                                if math.random(100) <= 5 then
                                    wolf:say("*flanking*", TALKTYPE_MONSTER_SAY)
                                end
                            end
                        end
                    end
                end
            else
                if #st.astar == 0 then
                    local path = findAStarPath(pos, targetPos, true)
                    if path and #path > 0 then
                        st.astar = path
                    end
                end
            end
            
            if amAlpha and math.random(100) <= 30 then
                updateHunt(pack, packId)
            end
        else
            huntTargets[packId] = nil
            st.astar = {}
        end
        
        goto movement_phase
    end
    
    -- ==========================================
    -- 3. PROCURA POR PRESAS (ALPHA)
    -- ==========================================
    if amAlpha and pack then
        local timeSinceLastHunt = now - pack.lastHuntTime
        
        if timeSinceLastHunt >= HUNT_COOLDOWN_TIME then
            local allPrey = findPreyNearby(pos, PREY_DETECTION_RANGE)
            
            if #allPrey > 0 then
                local target = findBestTarget(pos, allPrey)
                
                if target then
                    startHunt(pack, packId, target)
                    addEvent(wolfLoop, HUNTING_INTERVAL, id)
                    return
                end
            end
        end
    end
    
    -- ==========================================
    -- 4. SEGUIR A MATILHA
    -- ==========================================
    if not amAlpha and pack and pack.alphaId then
        local alpha = Monster(pack.alphaId)
        if alpha then
            local alphaPos = alpha:getPosition()
            local distToAlpha = getDistance(pos, alphaPos)
            
            if distToAlpha > PACK_MAX_DISTANCE then
                if #st.astar == 0 then
                    local path = findAStarPath(pos, alphaPos, false)
                    if path and #path > 0 then
                        st.astar = path
                    end
                end
                goto movement_phase
            end
        end
    end
    
    -- ==========================================
    -- 5. COMPORTAMENTO IDLE
    -- ==========================================
    if #st.astar == 0 then
        local roll = math.random(100)
        
        -- Uivo (apenas Alpha, 1% de chance)
        if amAlpha and (not st.lastHowl or now - st.lastHowl >= 60) and roll <= 1 then
            wolf:say("*HOWWWL!*", TALKTYPE_MONSTER_YELL)
            pos:sendMagicEffect(CONST_ME_SOUND_RED)
            st.lastHowl = now
            addEvent(wolfLoop, 2000, id)
            return
        end
        
        -- Patrulhar
        if roll <= 40 then
            local wanderPos = getRandomNearbyWalkable(pos, 5)
            if wanderPos then
                local path = findAStarPath(pos, wanderPos, false)
                if path and #path > 0 then
                    st.astar = path
                end
            end
        end
        
        -- Sons (reduzido para 15%)
        if roll <= 15 then
            local sounds = {"*sniff*", "*growl*"}
            wolf:say(sounds[math.random(#sounds)], TALKTYPE_MONSTER_SAY)
        end
    end
    
    -- ==========================================
    -- FASE DE MOVIMENTO
    -- ==========================================
    ::movement_phase::
    
    if #st.astar > 0 then
        local nextStep = st.astar[1]
        
        if isWalkable(nextStep, false) then
            local dir = getDirectionTo(pos, nextStep)
            if dir and wolf:move(dir) then
                table.remove(st.astar, 1)
                st.stuckCount = 0
            else
                st.stuckCount = (st.stuckCount or 0) + 1
                if st.stuckCount >= 3 then
                    st.astar = {}
                    st.stuckCount = 0
                end
            end
        else
            st.astar = {}
            st.stuckCount = 0
        end
    end
    
    addEvent(wolfLoop, interval, id)
end

-- ============================================
-- ONTHINK
-- ============================================

function onThink(interval)
    for pid, pack in pairs(packs) do
        local valid = {}
        for _, id in ipairs(pack.members) do
            local m = Monster(id)
            if m and m:getHealth() > 0 then
                table.insert(valid, id)
            else
                wolfToPack[id] = nil
                wolfState[id] = nil
            end
        end
        pack.members = valid
        
        if #pack.members == 0 then
            packs[pid] = nil
            huntTargets[pid] = nil
            feedingSessions[pid] = nil
        else
            if pack.alphaId then
                local alpha = Monster(pack.alphaId)
                if not alpha or alpha:getHealth() <= 0 then
                    if alpha then alpha:setSkull(SKULL_NONE) end
                    pack.alphaId = nil
                    electAlpha(pack)
                end
            else
                electAlpha(pack)
            end
        end
    end
    
    for pid, hunt in pairs(huntTargets) do
        local pack = packs[pid]
        if pack then
            updateHunt(pack, pid)
        end
    end
    
    for pid, feeding in pairs(feedingSessions) do
        local pack = packs[pid]
        if pack then
            updateFeeding(pack, pid)
        end
    end
    
    local cx = math.floor((AREA_FROM.x + AREA_TO.x) / 2)
    local cy = math.floor((AREA_FROM.y + AREA_TO.y) / 2)
    local center = Position(cx, cy, AREA_FROM.z)
    local rx = math.ceil((AREA_TO.x - AREA_FROM.x) / 2) + 10
    local ry = math.ceil((AREA_TO.y - AREA_FROM.y) / 2) + 10
    
    local specs = Game.getSpectators(center, false, false, rx, rx, ry, ry)
    for _, cre in ipairs(specs) do
        if cre:isMonster() and cre:getName() == MONSTER_NAME then
            local id = cre:getId()
            
            if not wolfState[id] then
                wolfState[id] = {
                    running = true,
                    astar = {},
                    stuckCount = 0,
                    lastAttackTime = 0,
                    lastHowl = 0
                }
                addEvent(wolfLoop, DEFAULT_INTERVAL + math.random(0, 300), id)
            elseif not wolfState[id].running then
                wolfState[id].running = true
                addEvent(wolfLoop, DEFAULT_INTERVAL, id)
            end
        end
    end
    
    return true
end