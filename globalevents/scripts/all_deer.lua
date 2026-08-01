-- ============================================
-- ULTIMATE REALISTIC DEER SCRIPT v7.0 FINAL
-- A* CORRIGIDO - COPIADO DO GATO
-- ============================================

local MONSTER_NAME = "Deer"
local PREDATOR_NAMES = {"Lobo", "War Wolf", "Bear", "Hunter", "Orc", "Poacher"}
local DEFAULT_INTERVAL = 800
local SCARED_INTERVAL = 500
local AREA_FROM = Position(434, 375, 13)
local AREA_TO = Position(562, 479, 13)

-- ITENS
local FOOD_IDS = {621, 6218, 6219, 14920, 2767, 2768}
local FENCE_IDS = {1440}
local TREE_IDS = {2700, 2701}
local URINE_ID = 2025
local DUNG_ID = 24214

-- CONFIGURAÇÕES DE BANDO
local HERD_MAX_DISTANCE = 8
local HERD_FOLLOW_DISTANCE = 5
local HERD_DETECTION_RANGE = 8
local LEADER_FIGHT_RANGE = 3
local LEADER_HOME_RADIUS = 10
local LEADER_MIN_FOOD = 2
local CALL_DURATION = 20

-- TEMPOS
local SLEEP_DURATION_MIN = 8
local SLEEP_DURATION_MAX = 15
local SLEEP_COOLDOWN = 150
local ANTLER_DURATION_MIN = 3
local ANTLER_DURATION_MAX = 6
local ANTLER_COOLDOWN = 80
local EAT_COOLDOWN = 12
local EAT_HEAL_AMOUNT = 200
local DANGER_DURATION = 12

-- BRIGA
local LEADER_FIGHT_INTERVAL = 1500
local LEADER_DEFEAT_HP_PERCENT = 40
local LEADER_BASE_DAMAGE = 15

-- Tabelas Globais
local deerState = {}
local herds = {}
local deerToHerd = {}
local nextHerdId = 1
local disqualifiedLeaders = {}
local ongoingFights = {}
local deersInFight = {}
local fightImmunity = {}

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

local function ensureGender(id)
    local g = getMonsterGender(id)
    if not g or g == 0 then
        g = math.random(1, 2)
        setMonsterGender(id, g)
    end
    return g
end

local function isMale(id)
    return ensureGender(id) == 1
end

local function isInvisible(cre)
    if not cre then return true end
    if cre:getCondition(CONDITION_INVISIBLE) then return true end
    local o = cre:getOutfit()
    return o and o.lookType == 0
end

local function inBounds(pos)
    if not pos then return false end
    return pos.x >= AREA_FROM.x and pos.x <= AREA_TO.x and
           pos.y >= AREA_FROM.y and pos.y <= AREA_TO.y and
           pos.z == AREA_FROM.z
end

-- ============================================
-- TILE CHECKING (IGUAL AO GATO)
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

local function isFence(pos)
    if not pos then return false end
    local tile = Tile(pos)
    if not tile then return false end
    local items = tile:getItems()
    if items then
        for _, it in ipairs(items) do
            if isInArray(FENCE_IDS, it:getId()) then return true end
        end
    end
    return false
end

-- ============================================
-- A* PATHFINDING - COPIADO EXATAMENTE DO GATO!
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
                    
                    -- CRÍTICO: NÃO ignora criaturas no pathfinding (como o gato!)
                    local walkable = isWalkable(n, false)
                    
                    -- Cerca é walkable
                    if isFence(n) then walkable = true end
                    
                    -- Goal é sempre walkable se não for interactable (COMO O GATO!)
                    if isGoalPos and not isTargetInteractable then walkable = true end 

                    if walkable and not closed[posToKey(n)] then
                        local weight = (dx ~= 0 and dy ~= 0) and 3.0 or 1.0
                        if isFence(n) then weight = weight + 2 end
                        
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
    
    return nil  -- Retorna nil (como o gato) em vez de {}
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

local function getRandomGlobalWalkable()
    for _ = 1, 30 do
        local x = math.random(AREA_FROM.x, AREA_TO.x)
        local y = math.random(AREA_FROM.y, AREA_TO.y)
        local p = Position(x, y, AREA_FROM.z)
        if isWalkable(p, false) then
            return p
        end
    end
    return nil
end

-- ============================================
-- DETECÇÃO
-- ============================================

local function findDanger(pos)
    if not pos then return nil end
    local specs = Game.getSpectators(pos, false, false, 6, 6, 6, 6)
    
    for _, c in ipairs(specs) do
        if c and not isInvisible(c) then
            if c:isPlayer() or (c:isMonster() and isInArray(PREDATOR_NAMES, c:getName())) then
                return copyPos(c:getPosition())
            end
        end
    end
    return nil
end

local function countFoodInArea(pos, range)
    if not pos then return 0 end
    local count = 0
    
    for x = pos.x - range, pos.x + range do
        for y = pos.y - range, pos.y + range do
            local p = Position(x, y, pos.z)
            if inBounds(p) then
                local tile = Tile(p)
                if tile then
                    for _, fid in ipairs(FOOD_IDS) do
                        if tile:getItemById(fid) then
                            count = count + 1
                            break
                        end
                    end
                end
            end
        end
    end
    return count
end

local function findNearestFood(pos, range)
    if not pos then return nil end
    local best, bestD = nil, 999
    
    for x = pos.x - range, pos.x + range do
        for y = pos.y - range, pos.y + range do
            local p = Position(x, y, pos.z)
            if inBounds(p) then
                local tile = Tile(p)
                if tile then
                    for _, fid in ipairs(FOOD_IDS) do
                        if tile:getItemById(fid) then
                            local d = getDistance(pos, p)
                            if d < bestD then
                                bestD = d
                                best = copyPos(p)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
    return best
end

local function findTree(pos)
    if not pos then return nil end
    for dx = -1, 1 do
        for dy = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local p = Position(pos.x + dx, pos.y + dy, pos.z)
                local tile = Tile(p)
                if tile then
                    local items = tile:getItems()
                    if items then
                        for _, it in ipairs(items) do
                            if isInArray(TREE_IDS, it:getId()) then
                                return copyPos(p)
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function findNewFoodArea(pos)
    if not pos then return nil end
    local best, bestFood = nil, 0
    
    for _ = 1, 15 do
        local angle = math.random() * 2 * math.pi
        local dist = math.random(15, 25)
        local tx = pos.x + math.floor(math.cos(angle) * dist)
        local ty = pos.y + math.floor(math.sin(angle) * dist)
        local tp = Position(tx, ty, pos.z)
        
        if inBounds(tp) then
            local food = countFoodInArea(tp, LEADER_HOME_RADIUS)
            if food > bestFood then
                bestFood = food
                best = copyPos(tp)
            end
        end
    end
    
    return best, bestFood or 0
end

local function findDeersNearby(pos, range, myId)
    if not pos then return {} end
    local deers = {}
    local specs = Game.getSpectators(pos, false, false, range, range, range, range)
    for _, c in ipairs(specs) do
        if c:isMonster() and c:getName() == MONSTER_NAME and c:getId() ~= myId then
            table.insert(deers, c)
        end
    end
    return deers
end

-- ============================================
-- SISTEMA DE BANDOS
-- ============================================

local function getHerd(id)
    local hid = deerToHerd[id]
    if hid and herds[hid] then return herds[hid], hid end
    return nil, nil
end

local function isLeader(id)
    local h = getHerd(id)
    return h and h.leaderId == id
end

local function getLeaderOf(id)
    local h = getHerd(id)
    if h and h.leaderId and h.leaderId ~= id then
        return Monster(h.leaderId)
    end
    return nil
end

local function canLead(id)
    return isMale(id) and not disqualifiedLeaders[id]
end

local function electLeader(herd)
    if not herd then return end
    
    if herd.leaderId then
        local old = Monster(herd.leaderId)
        if old then old:setSkull(SKULL_NONE) end
    end
    
    local best, bestHp = nil, 0
    for _, id in ipairs(herd.members) do
        local m = Monster(id)
        if m and m:getHealth() > 0 and canLead(id) then
            if m:getHealth() > bestHp then
                bestHp = m:getHealth()
                best = m
            end
        end
    end
    
    if best then
        herd.leaderId = best:getId()
        best:setSkull(SKULL_WHITE)
        best:say("*SNORT!*", TALKTYPE_MONSTER_YELL)
        best:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    else
        herd.leaderId = nil
    end
end

local function removeFromHerd(id)
    local herd, hid = getHerd(id)
    if not herd then return end
    
    for i, mid in ipairs(herd.members) do
        if mid == id then
            table.remove(herd.members, i)
            break
        end
    end
    
    if herd.leaderId == id then
        local m = Monster(id)
        if m then m:setSkull(SKULL_NONE) end
        herd.leaderId = nil
        herd.homePos = nil
        electLeader(herd)
    end
    
    if #herd.members == 0 then
        herds[hid] = nil
    end
    
    deerToHerd[id] = nil
end

local function createHerd(founderId)
    local hid = nextHerdId
    nextHerdId = nextHerdId + 1
    herds[hid] = {
        leaderId = nil,
        members = {founderId},
        homePos = nil,
        alertTime = 0,
        alertType = nil,
        alertPos = nil,
        waitingForHerd = false,  -- NOVO!
        lastCallTime = 0
    }
    deerToHerd[founderId] = hid
    electLeader(herds[hid])
    return hid
end

local function joinHerd(id, hid)
    local herd = herds[hid]
    if not herd then return end
    removeFromHerd(id)
    table.insert(herd.members, id)
    deerToHerd[id] = hid
end

local function mergeHerds(winHid, loseHid)
    local win = herds[winHid]
    local lose = herds[loseHid]
    if not win or not lose or winHid == loseHid then return end
    
    if lose.leaderId then
        local l = Monster(lose.leaderId)
        if l then l:setSkull(SKULL_NONE) end
    end
    
    for _, id in ipairs(lose.members) do
        table.insert(win.members, id)
        deerToHerd[id] = winHid
    end
    herds[loseHid] = nil
end

local function joinOrCreateHerd(id, pos)
    if getHerd(id) then return end
    
    local nearby = findDeersNearby(pos, HERD_DETECTION_RANGE, id)
    for _, d in ipairs(nearby) do
        local h, hid = getHerd(d:getId())
        if h then
            joinHerd(id, hid)
            return
        end
    end
    
    createHerd(id)
end

local function alertHerd(herd, alertType, alertPos)
    if not herd then return end
    herd.alertTime = os.time()
    herd.alertType = alertType
    herd.alertPos = alertPos and copyPos(alertPos) or nil
end

-- ============================================
-- SISTEMA DE CHAMADO DO LÍDER (CORRIGIDO!)
-- ============================================

local function checkMembersDistance(leaderId, leaderPos, herd)
    if not herd or not leaderPos then return end
    
    local now = os.time()
    local allClose = true
    
    for _, memberId in ipairs(herd.members) do
        if memberId ~= leaderId then
            local member = Monster(memberId)
            if member then
                local memberPos = member:getPosition()
                local dist = getDistance(leaderPos, memberPos)
                
                if dist > HERD_MAX_DISTANCE then
                    allClose = false
                    break
                end
            end
        end
    end
    
    -- Se alguém está longe E não chamou recentemente
    if not allClose and (not herd.lastCallTime or now - herd.lastCallTime >= 10) then
        local leader = Monster(leaderId)
        if leader then
            leader:say("*CALLING HERD!*", TALKTYPE_MONSTER_YELL)
            leaderPos:sendMagicEffect(CONST_ME_MAGIC_RED)
            alertHerd(herd, "RETURN", leaderPos)
            herd.waitingForHerd = true  -- LÍDER FICA PARADO!
            herd.lastCallTime = now
        end
    end
    
    -- Se todos estão perto, libera o líder
    if allClose and herd.waitingForHerd then
        herd.waitingForHerd = false
        if herd.alertType == "RETURN" then
            herd.alertType = nil
            herd.alertPos = nil
        end
    end
end

-- ============================================
-- SISTEMA DE BRIGA
-- ============================================

local function getFightKey(a, b)
    return a < b and (a .. "_" .. b) or (b .. "_" .. a)
end

local function inFight(id)
    return deersInFight[id] ~= nil
end

local function hasImmunity(id)
    local imm = fightImmunity[id]
    if imm and os.time() < imm then return true end
    fightImmunity[id] = nil
    return false
end

local function endFight(fk, winId, loseId)
    local fight = ongoingFights[fk]
    if not fight then return end
    
    disqualifiedLeaders[loseId] = true
    fightImmunity[winId] = os.time() + 30
    fightImmunity[loseId] = os.time() + 30
    
    local loser = Monster(loseId)
    if loser then
        loser:setSkull(SKULL_NONE)
        loser:say("*whimper*", TALKTYPE_MONSTER_SAY)
    end
    
    local wH, wHid = getHerd(winId)
    local lH, lHid = getHerd(loseId)
    if wH and lH and wHid ~= lHid then
        mergeHerds(wHid, lHid)
    elseif lH then
        lH.leaderId = nil
        electLeader(lH)
    end
    
    deersInFight[fight.id1] = nil
    deersInFight[fight.id2] = nil
    ongoingFights[fk] = nil
    
    local winner = Monster(winId)
    if winner then
        winner:say("*SNORT!*", TALKTYPE_MONSTER_YELL)
        winner:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    end
end

local function processFight(fk)
    local fight = ongoingFights[fk]
    if not fight then return end
    
    local m1 = Monster(fight.id1)
    local m2 = Monster(fight.id2)
    
    if not m1 or not m2 or m1:getHealth() <= 0 or m2:getHealth() <= 0 then
        deersInFight[fight.id1] = nil
        deersInFight[fight.id2] = nil
        ongoingFights[fk] = nil
        return
    end
    
    local p1, p2 = m1:getPosition(), m2:getPosition()
    local hp1 = (m1:getHealth() / m1:getMaxHealth()) * 100
    local hp2 = (m2:getHealth() / m2:getMaxHealth()) * 100
    
    if hp1 < LEADER_DEFEAT_HP_PERCENT then
        endFight(fk, fight.id2, fight.id1)
        return
    end
    if hp2 < LEADER_DEFEAT_HP_PERCENT then
        endFight(fk, fight.id1, fight.id2)
        return
    end
    
    local now = os.mtime()
    if now - fight.lastHit < LEADER_FIGHT_INTERVAL then return end
    fight.lastHit = now
    
    if getDistance(p1, p2) > 1 then
        local st1 = deerState[fight.id1]
        local st2 = deerState[fight.id2]
        if st1 and #st1.astar == 0 then
            st1.astar = findAStarPath(p1, p2, true) or {}
        end
        if st2 and #st2.astar == 0 then
            st2.astar = findAStarPath(p2, p1, true) or {}
        end
        return
    end
    
    m1:setDirection(getDirectionTo(p1, p2) or DIRECTION_SOUTH)
    m2:setDirection(getDirectionTo(p2, p1) or DIRECTION_NORTH)
    
    if fight.turn == 1 then
        m2:addHealth(-LEADER_BASE_DAMAGE)
        p2:sendMagicEffect(CONST_ME_HITBYMELEE)
        m1:say("*SNORT!*", TALKTYPE_MONSTER_SAY)
        fight.turn = 2
    else
        m1:addHealth(-LEADER_BASE_DAMAGE)
        p1:sendMagicEffect(CONST_ME_HITBYMELEE)
        m2:say("*SNORT!*", TALKTYPE_MONSTER_SAY)
        fight.turn = 1
    end
end

local function startFight(l1, l2)
    local id1, id2 = l1:getId(), l2:getId()
    local fk = getFightKey(id1, id2)
    
    if ongoingFights[fk] or inFight(id1) or inFight(id2) then return false end
    if hasImmunity(id1) or hasImmunity(id2) then return false end
    
    local h1, hid1 = getHerd(id1)
    local h2, hid2 = getHerd(id2)
    if not h1 or not h2 or hid1 == hid2 then return false end
    
    ongoingFights[fk] = {id1 = id1, id2 = id2, turn = 1, lastHit = os.mtime()}
    deersInFight[id1] = fk
    deersInFight[id2] = fk
    
    l1:say("*SNORT SNORT!*", TALKTYPE_MONSTER_YELL)
    l2:say("*SNORT SNORT!*", TALKTYPE_MONSTER_YELL)
    l1:getPosition():sendMagicEffect(CONST_ME_HITAREA)
    l2:getPosition():sendMagicEffect(CONST_ME_HITAREA)
    return true
end

local function checkForFights(id, pos)
    if not isLeader(id) or inFight(id) or hasImmunity(id) then return false end
    
    local myH, myHid = getHerd(id)
    if not myH then return false end
    
    local nearby = findDeersNearby(pos, LEADER_FIGHT_RANGE, id)
    for _, d in ipairs(nearby) do
        local oid = d:getId()
        if isLeader(oid) and not inFight(oid) and not hasImmunity(oid) then
            local oH, oHid = getHerd(oid)
            if oH and oHid ~= myHid then
                return startFight(Monster(id), d)
            end
        end
    end
    return false
end

-- ============================================
-- LOOP PRINCIPAL - A* CORRIGIDO!
-- ============================================

local function deerLoop(id)
    local deer = Monster(id)
    if not deer then
        removeFromHerd(id)
        deerState[id] = nil
        return
    end
    
    local st = deerState[id]
    if not st then return end
    
    if deer:getHealth() <= 0 then
        removeFromHerd(id)
        deerState[id] = nil
        return
    end

    local pos = deer:getPosition()
    local now = os.time()
    local interval = DEFAULT_INTERVAL
    local danger = nil
    local scared = false
    
    joinOrCreateHerd(id, pos)
    
    local herd, herdId = getHerd(id)
    local amLeader = isLeader(id)
    local leader = getLeaderOf(id)
    local leaderPos = leader and leader:getPosition()
    local leaderSt = leader and deerState[leader:getId()]
    
    -- ==========================================
    -- 1. BRIGA
    -- ==========================================
    if inFight(id) then
        processFight(deersInFight[id])
        if #st.astar > 0 then goto movement_phase end
        addEvent(deerLoop, 500, id)
        return
    end
    
    if amLeader and checkForFights(id, pos) then
        addEvent(deerLoop, 500, id)
        return
    end
    
    -- ==========================================
    -- 2. PERIGO
    -- ==========================================
    danger = findDanger(pos)
    if danger then
        if not st.scaredUntil or now >= st.scaredUntil then
            deer:say("SNORT!!", TALKTYPE_MONSTER_YELL)
            pos:sendMagicEffect(CONST_ME_POFF)
            
            if amLeader and herd then
                alertHerd(herd, "DANGER", danger)
                herd.waitingForHerd = false  -- Cancela espera
            end
        end
        
        st.scaredUntil = now + DANGER_DURATION
        st.dangerPos = copyPos(danger)
        st.eatingTarget = nil
        st.sleeping = false
        st.resting = false
        st.scratching = false
        st.astar = {}
        st.forcePanic = true
        interval = SCARED_INTERVAL
    end
    
    if not danger and herd and herd.alertType == "DANGER" and herd.alertPos then
        if now - herd.alertTime < DANGER_DURATION then
            if not st.scaredUntil or now >= st.scaredUntil then
                deer:say("!", TALKTYPE_MONSTER_SAY)
            end
            st.scaredUntil = now + DANGER_DURATION
            st.dangerPos = copyPos(herd.alertPos)
            st.eatingTarget = nil
            st.sleeping = false
            st.resting = false
            st.scratching = false
            st.astar = {}
            st.forcePanic = true
            interval = SCARED_INTERVAL
        end
    end
    
    scared = st.scaredUntil and now < st.scaredUntil
    if scared then interval = SCARED_INTERVAL end
    
    -- FUGA COM FALLBACK ROBUSTO
    if scared and st.dangerPos then
        if st.forcePanic or #st.astar == 0 then
            st.forcePanic = false
            
            local dx = pos.x - st.dangerPos.x
            local dy = pos.y - st.dangerPos.y
            local len = math.sqrt(dx*dx + dy*dy)
            if len > 0 then
                dx, dy = dx/len, dy/len
            else
                dx, dy = math.random(-1, 1), math.random(-1, 1)
                if dx == 0 and dy == 0 then dx = 1 end
            end
            
            -- Tenta fugir
            for dist = 12, 6, -3 do
                local fleeX = math.floor(pos.x + dx * dist)
                local fleeY = math.floor(pos.y + dy * dist)
                fleeX = math.max(AREA_FROM.x + 3, math.min(AREA_TO.x - 3, fleeX))
                fleeY = math.max(AREA_FROM.y + 3, math.min(AREA_TO.y - 3, fleeY))
                
                local fleePos = Position(fleeX, fleeY, pos.z)
                local path = findAStarPath(pos, fleePos, false)
                if path and #path > 0 then
                    st.astar = path
                    break
                end
            end
            
            -- Fallback 1: perto
            if #st.astar == 0 then
                for i = 1, 5 do
                    local rnd = getRandomNearbyWalkable(pos, 4)
                    if rnd then
                        local path = findAStarPath(pos, rnd, false)
                        if path and #path > 0 then
                            st.astar = path
                            break
                        end
                    end
                end
            end
            
            -- Fallback 2: 1 SQM
            if #st.astar == 0 then
                local panicStep = getRandomNearbyWalkable(pos, 1)
                if panicStep then st.astar = {panicStep} end
            end
        end
        
        goto movement_phase
    end
    
    if not scared then
        st.dangerPos = nil
        st.forcePanic = false
        if herd and herd.alertType == "DANGER" and now - herd.alertTime >= DANGER_DURATION then
            herd.alertType = nil
            herd.alertPos = nil
        end
    end
    
    -- ==========================================
    -- 3. CHAMADO DO LÍDER - PRIORIDADE MÁXIMA!
    -- ==========================================
    if not scared and not amLeader and herd and herd.alertType == "RETURN" and herd.alertPos then
        if now - herd.alertTime < CALL_DURATION then
            local distToLeader = getDistance(pos, herd.alertPos)
            
            if distToLeader > HERD_FOLLOW_DISTANCE then
                -- PARA TUDO E VAI PARA O LÍDER!
                st.eatingTarget = nil
                st.sleeping = false
                st.resting = false
                st.scratching = false
                
                if #st.astar == 0 then
                    local path = findAStarPath(pos, herd.alertPos, false)
                    if path and #path > 0 then
                        st.astar = path
                        deer:say("*coming!*", TALKTYPE_MONSTER_SAY)
                    else
                        -- Path falhou, tenta se aproximar genericamente
                        local approachPos = getRandomNearbyWalkable(herd.alertPos, 2)
                        if approachPos then
                            path = findAStarPath(pos, approachPos, false)
                            if path and #path > 0 then st.astar = path end
                        end
                    end
                end
                goto movement_phase
            end
        else
            -- Timeout do chamado
            if herd.alertType == "RETURN" then
                herd.alertType = nil
                herd.alertPos = nil
            end
        end
    end
    
    -- ==========================================
    -- 4. LÍDER ESPERANDO BANDO
    -- ==========================================
    if amLeader and herd and herd.waitingForHerd then
        -- LÍDER FICA PARADO!
        checkMembersDistance(id, pos, herd)
        
        -- Faz efeito visual
        if math.random(100) <= 20 then
            pos:sendMagicEffect(CONST_ME_MAGIC_RED)
            deer:say("*waiting...*", TALKTYPE_MONSTER_SAY)
        end
        
        addEvent(deerLoop, 1500, id)
        return
    end
    
    -- ==========================================
    -- 5. ESTADOS PASSIVOS
    -- ==========================================
    
    if st.sleeping then
        local shouldWake = false
        if leaderSt and not leaderSt.sleeping then shouldWake = true end
        if now >= st.wakeUpTime then
            shouldWake = true
            st.sleepCooldown = now + SLEEP_COOLDOWN
        end
        
        if shouldWake then
            st.sleeping = false
            deer:say("*yawn*", TALKTYPE_MONSTER_SAY)
        else
            pos:sendMagicEffect(33)
            addEvent(deerLoop, 2000, id)
            return
        end
    end
    
    if st.resting then
        if now >= st.restEnd then
            st.resting = false
        else
            addEvent(deerLoop, 1500, id)
            return
        end
    end
    
    if st.scratching then
        if now >= st.scratchEnd then
            st.scratching = false
            st.scratchCooldown = now + ANTLER_COOLDOWN
        else
            if st.scratchPos then st.scratchPos:sendMagicEffect(4) end
            deer:say("*scrrtch*", TALKTYPE_MONSTER_SAY)
            addEvent(deerLoop, 1500, id)
            return
        end
    end
    
    -- ==========================================
    -- 6. COMER
    -- ==========================================
    
    if st.eatingTarget then
        local distFood = getDistance(pos, st.eatingTarget)
        
        if distFood <= 1 then
            local tile = Tile(st.eatingTarget)
            local foodItem = nil
            if tile then
                for _, fid in ipairs(FOOD_IDS) do
                    foodItem = tile:getItemById(fid)
                    if foodItem then break end
                end
            end
            
            if not foodItem then
                st.eatingTarget = nil
                st.eatWaitTime = nil
                st.astar = {}
            elseif not st.eatWaitTime then
                st.eatWaitTime = now + 2
                deer:say("*chomp*", TALKTYPE_MONSTER_SAY)
                local dir = getDirectionTo(pos, st.eatingTarget)
                if dir then deer:setDirection(dir) end
            elseif now >= st.eatWaitTime then
                foodItem:remove()
                deer:addHealth(EAT_HEAL_AMOUNT)
                deer:say("+HP", TALKTYPE_MONSTER_SAY)
                pos:sendMagicEffect(CONST_ME_MAGIC_GREEN)
                
                st.eatingTarget = nil
                st.eatWaitTime = nil
                st.eatCooldown = now + EAT_COOLDOWN
                st.astar = {}
                
                if amLeader and herd then
                    local foodHere = countFoodInArea(pos, LEADER_HOME_RADIUS)
                    if foodHere >= LEADER_MIN_FOOD and not herd.homePos then
                        herd.homePos = copyPos(pos)
                        deer:say("*TERRITORY!*", TALKTYPE_MONSTER_YELL)
                        pos:sendMagicEffect(CONST_ME_MAGIC_BLUE)
                        alertHerd(herd, "FOOD", pos)
                    end
                end
            else
                addEvent(deerLoop, 800, id)
                return
            end
        else
            if #st.astar == 0 then
                local path = findAStarPath(pos, st.eatingTarget, true)
                if path and #path > 0 then
                    st.astar = path
                else
                    -- Path falhou, desiste
                    st.eatingTarget = nil
                end
            end
            goto movement_phase
        end
        
        addEvent(deerLoop, interval, id)
        return
    end
    
    -- PROCURA COMIDA
    if now >= (st.eatCooldown or 0) then
        local homePos = herd and herd.homePos
        local searchRange = 15
        
        local food = findNearestFood(pos, searchRange)
        
        if food then
            local canEat = true
            if not amLeader and homePos then
                if getDistance(food, homePos) > HERD_MAX_DISTANCE then
                    canEat = false
                end
            end
            
            if canEat then
                st.eatingTarget = food
                local path = findAStarPath(pos, food, true)
                if path and #path > 0 then
                    st.astar = path
                    addEvent(deerLoop, interval, id)
                    return
                else
                    st.eatingTarget = nil
                end
            end
        end
    end
    
    -- ==========================================
    -- 7. ALERTA DE COMIDA
    -- ==========================================
    if not amLeader and herd and herd.alertType == "FOOD" and herd.alertPos then
        if now - herd.alertTime < 25 then
            local distToFood = getDistance(pos, herd.alertPos)
            if distToFood > 4 then
                if #st.astar == 0 then
                    local path = findAStarPath(pos, herd.alertPos, false)
                    if path and #path > 0 then st.astar = path end
                end
                goto movement_phase
            end
        else
            herd.alertType = nil
            herd.alertPos = nil
        end
    end
    
    -- ==========================================
    -- 8. LÍDER - GERENCIA TERRITÓRIO
    -- ==========================================
    if amLeader and herd then
        -- Checa se membros estão longe
        checkMembersDistance(id, pos, herd)
        
        local homePos = herd.homePos
        local foodCount = homePos and countFoodInArea(homePos, LEADER_HOME_RADIUS) or 0
        
        if homePos and foodCount >= LEADER_MIN_FOOD then
            -- TEM TERRITÓRIO
            local distToHome = getDistance(pos, homePos)
            if distToHome > LEADER_HOME_RADIUS / 2 then
                if #st.astar == 0 then
                    local path = findAStarPath(pos, homePos, false)
                    if path and #path > 0 then
                        st.astar = path
                    else
                        -- Path falhou, tenta ponto próximo
                        local nearHome = getRandomNearbyWalkable(homePos, 3)
                        if nearHome then
                            path = findAStarPath(pos, nearHome, false)
                            if path and #path > 0 then st.astar = path end
                        end
                    end
                end
                goto movement_phase
            else
                -- Vaga no território
                if #st.astar == 0 and math.random(100) <= 30 then
                    for i = 1, 5 do
                        local wx = homePos.x + math.random(-4, 4)
                        local wy = homePos.y + math.random(-4, 4)
                        local wp = Position(wx, wy, pos.z)
                        if inBounds(wp) and getDistance(wp, homePos) <= LEADER_HOME_RADIUS / 2 then
                            local path = findAStarPath(pos, wp, false)
                            if path and #path > 0 then
                                st.astar = path
                                break
                            end
                        end
                    end
                end
            end
        else
            -- BUSCA TERRITÓRIO
            herd.homePos = nil
            
            local currentFood = countFoodInArea(pos, LEADER_HOME_RADIUS)
            if currentFood >= LEADER_MIN_FOOD then
                herd.homePos = copyPos(pos)
                deer:say("*TERRITORY!*", TALKTYPE_MONSTER_YELL)
                pos:sendMagicEffect(CONST_ME_MAGIC_BLUE)
                alertHerd(herd, "FOOD", pos)
            else
                if not st.searchTarget then
                    local newArea, newFood = findNewFoodArea(pos)
                    if newArea and newFood >= LEADER_MIN_FOOD then
                        st.searchTarget = newArea
                        deer:say("*sniff sniff*", TALKTYPE_MONSTER_SAY)
                    end
                end
                
                if st.searchTarget then
                    local distToTarget = getDistance(pos, st.searchTarget)
                    if distToTarget < 5 then
                        local foodHere = countFoodInArea(pos, LEADER_HOME_RADIUS)
                        if foodHere >= LEADER_MIN_FOOD then
                            herd.homePos = copyPos(pos)
                            deer:say("*TERRITORY!*", TALKTYPE_MONSTER_YELL)
                            pos:sendMagicEffect(CONST_ME_MAGIC_BLUE)
                            alertHerd(herd, "FOOD", pos)
                        end
                        st.searchTarget = nil
                    else
                        if #st.astar == 0 then
                            local path = findAStarPath(pos, st.searchTarget, false)
                            if path and #path > 0 then
                                st.astar = path
                            else
                                -- Falhou, desiste e procura outra área
                                st.searchTarget = nil
                            end
                        end
                        goto movement_phase
                    end
                end
            end
        end
    end
    
    -- ==========================================
    -- 9. SEGUIDORES
    -- ==========================================
    if not amLeader and leader and leaderPos then
        local distToLeader = getDistance(pos, leaderPos)
        
        if distToLeader > HERD_MAX_DISTANCE then
            if #st.astar == 0 then
                local path = findAStarPath(pos, leaderPos, false)
                if path and #path > 0 then
                    st.astar = path
                else
                    -- Path falhou, tenta ponto próximo ao líder
                    local nearLeader = getRandomNearbyWalkable(leaderPos, 2)
                    if nearLeader then
                        path = findAStarPath(pos, nearLeader, false)
                        if path and #path > 0 then st.astar = path end
                    end
                end
            end
            goto movement_phase
        end
    end
    
    -- ==========================================
    -- 10. COMPORTAMENTOS IDLE
    -- ==========================================
    if #st.astar == 0 then
        local roll = math.random(100)
        
        local leaderSleeping = leaderSt and leaderSt.sleeping
        if (amLeader or leaderSleeping) and now > (st.sleepCooldown or 0) and roll <= 1 then
            local nearby = findDeersNearby(pos, 3, id)
            if #nearby >= 2 or amLeader then
                st.sleeping = true
                st.wakeUpTime = now + math.random(SLEEP_DURATION_MIN, SLEEP_DURATION_MAX)
                deer:say("*yawn*", TALKTYPE_MONSTER_SAY)
                addEvent(deerLoop, 2000, id)
                return
            end
        end
        
        if isMale(id) and now > (st.scratchCooldown or 0) and roll <= 2 then
            local tree = findTree(pos)
            if tree then
                st.scratching = true
                st.scratchPos = tree
                st.scratchEnd = now + math.random(ANTLER_DURATION_MIN, ANTLER_DURATION_MAX)
                addEvent(deerLoop, 1500, id)
                return
            end
        end
        
        if roll <= 3 then
            st.resting = true
            st.restEnd = now + math.random(4, 8)
            addEvent(deerLoop, 1500, id)
            return
        end
        
        if roll <= 4 then
            local item = Game.createItem(URINE_ID, 1, pos)
            if item then item:transform(2025, 5) end
            deer:say("", TALKTYPE_MONSTER_SAY)
            addEvent(deerLoop, 3000, id)
            return
        end
        
        if roll <= 5 then
            local item = Game.createItem(DUNG_ID, 1, pos)
            if item then item:decay() end
            deer:say("", TALKTYPE_MONSTER_SAY)
            addEvent(deerLoop, 3000, id)
            return
        end
        
        -- ANDAR
        if roll <= 40 then
            local homePos = herd and herd.homePos
            local wanderPos = nil
            
            if homePos then
                for i = 1, 5 do
                    local wx = pos.x + math.random(-4, 4)
                    local wy = pos.y + math.random(-4, 4)
                    local wp = Position(wx, wy, pos.z)
                    if inBounds(wp) and getDistance(wp, homePos) <= HERD_MAX_DISTANCE then
                        if isWalkable(wp, false) then
                            wanderPos = wp
                            break
                        end
                    end
                end
            else
                wanderPos = getRandomNearbyWalkable(pos, 4)
            end
            
            if wanderPos then
                local path = findAStarPath(pos, wanderPos, false)
                if path and #path > 0 then st.astar = path end
            end
        end
        
        if roll <= 50 then
            local sounds = amLeader and {"*SNORT*", "*sniff*"} or {"*sniff*", "..."}
            deer:say(sounds[math.random(#sounds)], TALKTYPE_MONSTER_SAY)
        end
    end
    
    -- ==========================================
    -- FALLBACK DE MOVIMENTO
    -- ==========================================
    if #st.astar == 0 and not st.sleeping and not st.resting and not st.scratching then
        if st.failPathCount and st.failPathCount >= 3 then
            -- Tenta movimento curtíssimo
            for i = 1, 5 do
                local nearPos = getRandomNearbyWalkable(pos, 2)
                if nearPos then
                    local path = findAStarPath(pos, nearPos, false)
                    if path and #path > 0 then
                        st.astar = path
                        st.failPathCount = 0
                        break
                    end
                end
            end
            
            if #st.astar == 0 then
                st.failPathCount = 0
            end
        end
    end
    
    -- ==========================================
    -- FASE DE MOVIMENTO
    -- ==========================================
    ::movement_phase::
    
    if #st.astar > 0 then
        local nextStep = st.astar[1]
        
        if isFence(nextStep) then
            local dx = nextStep.x - pos.x
            local dy = nextStep.y - pos.y
            local landPos = Position(nextStep.x + dx, nextStep.y + dy, nextStep.z)
            if isWalkable(landPos, false) then
                deer:teleportTo(landPos)
                pos:sendMagicEffect(CONST_ME_POFF)
                landPos:sendMagicEffect(CONST_ME_POFF)
                st.astar = {}
                st.stuckCount = 0
            else
                st.astar = {}
            end
        elseif isWalkable(nextStep, false) then
            local dir = getDirectionTo(pos, nextStep)
            if dir and deer:move(dir) then
                table.remove(st.astar, 1)
                st.stuckCount = 0
            else
                st.stuckCount = (st.stuckCount or 0) + 1
                if st.stuckCount >= 2 then
                    st.astar = {}
                    st.stuckCount = 0
                    st.failPathCount = (st.failPathCount or 0) + 1
                end
            end
        else
            -- Tile não walkable (criatura/obstáculo)
            st.astar = {}
            st.stuckCount = 0
            st.failPathCount = (st.failPathCount or 0) + 1
        end
    end
    
    addEvent(deerLoop, interval, id)
end

-- ============================================
-- ONTHINK
-- ============================================

function onThink(interval)
    for fk in pairs(ongoingFights) do
        processFight(fk)
    end
    
    local now = os.time()
    for id, exp in pairs(fightImmunity) do
        if now >= exp then fightImmunity[id] = nil end
    end
    
    for hid, herd in pairs(herds) do
        local valid = {}
        for _, id in ipairs(herd.members) do
            local m = Monster(id)
            if m and m:getHealth() > 0 then
                table.insert(valid, id)
            else
                deerToHerd[id] = nil
                deerState[id] = nil
            end
        end
        herd.members = valid
        
        if #herd.members == 0 then
            herds[hid] = nil
        else
            if herd.leaderId then
                local l = Monster(herd.leaderId)
                if not l or l:getHealth() <= 0 or not canLead(herd.leaderId) then
                    if l then l:setSkull(SKULL_NONE) end
                    herd.leaderId = nil
                    herd.homePos = nil
                    electLeader(herd)
                end
            else
                electLeader(herd)
            end
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
            ensureGender(id)
            
            if not deerState[id] then
                deerState[id] = {
                    running = true,
                    astar = {},
                    stuckCount = 0,
                    failPathCount = 0,
                    scaredUntil = 0,
                    dangerPos = nil,
                    forcePanic = false,
                    eatingTarget = nil,
                    eatWaitTime = nil,
                    eatCooldown = os.time() + math.random(3, 10),
                    sleeping = false,
                    wakeUpTime = 0,
                    sleepCooldown = os.time() + math.random(40, 120),
                    resting = false,
                    restEnd = 0,
                    scratching = false,
                    scratchPos = nil,
                    scratchEnd = 0,
                    scratchCooldown = os.time() + math.random(30, 80),
                    searchTarget = nil
                }
                addEvent(deerLoop, DEFAULT_INTERVAL + math.random(0, 400), id)
            elseif not deerState[id].running then
                deerState[id].running = true
                addEvent(deerLoop, DEFAULT_INTERVAL, id)
            end
        end
    end
    
    return true
end