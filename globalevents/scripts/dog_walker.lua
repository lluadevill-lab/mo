-- cat_walker.lua (TFS 1.2)
local CAT_NAME = "Dog"
local DEFAULT_INTERVAL = 600
local AREA_FROM = Position(665, 382, 7)
local AREA_TO = Position(742, 438, 7)

local catData = nil
local spawnedCatId = nil

-- Caminho e segurança -------------------------------------
local function getDistance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end

local function isWalkable(pos)
    local tile = Tile(pos)
    if not tile or pos.z ~= 7 then return false end

    -- Checa chão
    local ground = tile:getGround()
    if not ground then return false end
    local groundId = ground:getId()

    -- Água e líquidos comuns (ajustável)
    local waterIds = {
        4820, 4821, 4822, 4823, 4608, 4609, 4610, 4611,
        4612, 4613, 4614, 4615, 4616, 4617, 4618, 4619,
        4620, 4621, 4622, 4623
    }
    for _, id in ipairs(waterIds) do
        if groundId == id then return false end
    end

    -- Flags de andar proibido
    if tile:hasFlag(TILESTATE_PROTECTIONZONE)
    or tile:hasFlag(TILESTATE_FLOORCHANGE)
    or tile:hasFlag(TILESTATE_TELEPORT)
    or tile:hasFlag(TILESTATE_NOTWALKABLE) then
        return false
    end

    -- Evita criaturas e campos
    local creatures = tile:getCreatures()
    if creatures and #creatures > 0 then
        return false
    end

    local items = tile:getItems()
    if items then
        for _, item in ipairs(items) do
            local itType = item:getType()
            if itType and (itType:isBlocking() or itType:isMagicField()) then
                return false
            end
        end
    end
    return true
end

local function posToKey(pos)
    return pos.x .. "," .. pos.y .. "," .. pos.z
end

local function findAStarPath(start, goal)
    local closed, open, cameFrom = {}, {start}, {}
    local gScore, fScore = { [posToKey(start)] = 0 }, { [posToKey(start)] = getDistance(start, goal) }

    while #open > 0 do
        local current, ci = open[1], 1
        for i, p in ipairs(open) do
            if fScore[posToKey(p)] < fScore[posToKey(current)] then current, ci = p, i end
        end
        table.remove(open, ci)
        if current.x == goal.x and current.y == goal.y then
            local path, temp = {}, current
            while temp do
                local parent = cameFrom[posToKey(temp)]
                if parent then table.insert(path, 1, temp) end
                temp = parent
            end
            return path
        end
        closed[posToKey(current)] = true
        for _, d in ipairs({{x=1,y=0},{x=-1,y=0},{x=0,y=1},{x=0,y=-1}}) do
            local n = Position(current.x+d.x, current.y+d.y, current.z)
            if isWalkable(n) and not closed[posToKey(n)] then
                local g = gScore[posToKey(current)] + 1
                if g < (gScore[posToKey(n)] or math.huge) then
                    cameFrom[posToKey(n)] = current
                    gScore[posToKey(n)] = g
                    fScore[posToKey(n)] = g + getDistance(n, goal)
                    table.insert(open, n)
                end
            end
        end
    end
end

local function getDirectionTo(a, b)
    if a.x > b.x then return DIRECTION_WEST
    elseif a.x < b.x then return DIRECTION_EAST
    elseif a.y > b.y then return DIRECTION_NORTH
    elseif a.y < b.y then return DIRECTION_SOUTH end
end

local function getRandomWalkable()
    for i = 1, 100 do
        local x = math.random(AREA_FROM.x, AREA_TO.x)
        local y = math.random(AREA_FROM.y, AREA_TO.y)
        local pos = Position(x, y, AREA_FROM.z)
        if isWalkable(pos) then return pos end
    end
    return Position(AREA_FROM.x, AREA_FROM.y, AREA_FROM.z)
end

-- Ciclo natural ------------------------------------------
local function catBehaviorLoop(monsterId)
    local cat = Monster(monsterId)
    if not cat or not catData then return end
    if cat:getHealth() <= 0 then catData = nil spawnedCatId = nil return end

    local state = catData
    if not state then return end

    -- chance de comportamento natural
    if not state.astar or #state.astar == 0 then
        local chance = math.random(100)
        if chance < 8 then
            -- dormir de 30 a 60s
            local sleepTime = math.random(30000, 60000)
            local pos = cat:getPosition()
            cat:say("*se deita*", TALKTYPE_MONSTER_SAY)

            local function sleepFx(rem)
                if not Monster(monsterId) then return end
                pos:sendMagicEffect(33)
                if rem > 0 then addEvent(sleepFx, 3000, rem - 3000) end
            end
            sleepFx(sleepTime)
            addEvent(catBehaviorLoop, sleepTime, monsterId)
            return
        elseif chance < 15 then
            cat:say("Woof!", TALKTYPE_MONSTER_SAY)
            addEvent(catBehaviorLoop, math.random(2000, 4000), monsterId)
            return
        elseif chance < 20 then
            cat:say("*se cocando*", TALKTYPE_MONSTER_SAY)
            addEvent(catBehaviorLoop, math.random(3000, 6000), monsterId)
            return
        elseif chance < 25 then
            local pos = cat:getPosition()
            local item = Game.createItem(2025, 1, Position(pos.x, pos.y+1, pos.z))
            doTransformItem(item.uid, 2025, 5)
            cat:say("*levantando a perna*", TALKTYPE_MONSTER_SAY)
            addEvent(catBehaviorLoop, math.random(2000, 4000), monsterId)
            return
        end
        -- novo destino
        local goal = getRandomWalkable()
        state.astar = findAStarPath(cat:getPosition(), goal) or {}
    end

    if state.astar and #state.astar > 0 then
        local nextStep = state.astar[1]
        local dir = getDirectionTo(cat:getPosition(), nextStep)
        if dir then cat:move(dir) end
        table.remove(state.astar, 1)
    end

    addEvent(catBehaviorLoop, DEFAULT_INTERVAL, monsterId)
end

local function spawnCat()
    if spawnedCatId then
        local existing = Monster(spawnedCatId)
        if existing then return end
    end

    local startPos = getRandomWalkable()
    local cat = Game.createMonster(CAT_NAME, startPos, false, true)
    if not cat then
        print("[CatWalker] Falha ao criar Cat.")
        return
    end

    spawnedCatId = cat:getId()
    catData = { astar = {} }
    addEvent(catBehaviorLoop, DEFAULT_INTERVAL, spawnedCatId)
end

function onThink(interval)
    spawnCat()
    return true
end
