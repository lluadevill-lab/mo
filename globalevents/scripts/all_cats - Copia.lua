local CAT_NAME = "Gato"
local DEFAULT_INTERVAL = 600
local SCARED_INTERVAL = 300
local AREA_FROM = Position(665, 382, 7)
local AREA_TO = Position(742, 438, 7)
local BED_ID = 24171
local FISH_ID = 2667

local catsState = {}

local function getDistance(a, b)
  return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

local function isBedOccupied(pos, myId)
  local tile = Tile(pos)
  if not tile then return false end
  local creatures = tile:getCreatures()
  if creatures then
    for _, cre in ipairs(creatures) do
      if cre:isMonster() and cre:getName() == CAT_NAME and cre:getId() ~= myId then
        return true
      end
    end
  end
  for id, state in pairs(catsState) do
    if id ~= myId and state.goingToBed and state.goingToBed.x == pos.x and state.goingToBed.y == pos.y then
      return true
    end
  end
  return false
end

local function isFishTargeted(pos, myId)
  local tile = Tile(pos)
  if not tile then return true end
  local creatures = tile:getCreatures()
  if creatures then
    for _, cre in ipairs(creatures) do
      if cre:isMonster() and cre:getName() == CAT_NAME and cre:getId() ~= myId then
        return true
      end
    end
  end
  for id, state in pairs(catsState) do
    if id ~= myId and state.eatingTarget and state.eatingTarget.x == pos.x and state.eatingTarget.y == pos.y then
      return true
    end
  end
  return false
end

local function isWalkable(pos, ignoreCreatures)
  local tile = Tile(pos)
  if not tile or pos.z ~= AREA_FROM.z then return false end
  local ground = tile:getGround()
  if not ground then return false end
  local gname = ItemType(ground:getId()):getName():lower()
  if gname:find("water") or gname:find("sea") or gname:find("river") or gname:find("lake")
  or gname:find("swamp") or gname:find("lava") or gname:find("mud") or gname:find("pond")
  or gname:find("pool") or gname:find("liquid") then
    return false
  end
  if tile:hasFlag(TILESTATE_NOTWALKABLE)
  or tile:hasFlag(TILESTATE_TELEPORT)
  or tile:hasFlag(TILESTATE_HOLE)
  or tile:hasFlag(TILESTATE_NOFLOOR)
  or tile:hasFlag(TILESTATE_MAGICFIELD)
  or tile:hasFlag(TILESTATE_FLOORCHANGE) then
    return false
  end
  if not ignoreCreatures and tile:getCreatureCount() > 0 then
    return false
  end
  local items = tile:getItems()
  if items then
    for _, item in ipairs(items) do
      local itType = item:getType()
      if itType and itType:isBlocking() then return false end
    end
  end
  return true
end

local function isJumpableWindow(pos)
  local tile = Tile(pos)
  if not tile then return false end
  local items = tile:getItems()
  if items then
    for _, item in ipairs(items) do
      local name = item:getType():getName():lower()
      if name:find("window") and not name:find("closed") then return true end
    end
  end
  return false
end

local function searchFreeBedNearby(centerPos, range, myId)
  for x = centerPos.x - range, centerPos.x + range do
    for y = centerPos.y - range, centerPos.y + range do
      local p = Position(x, y, centerPos.z)
      local tile = Tile(p)
      if tile and tile:getItemById(BED_ID) then
        if not isBedOccupied(p, myId) then return p end
      end
    end
  end
  return nil
end

local function searchFreeFishNearby(centerPos, range, myId)
  for x = centerPos.x - range, centerPos.x + range do
    for y = centerPos.y - range, centerPos.y + range do
      local p = Position(x, y, centerPos.z)
      local tile = Tile(p)
      if tile and tile:getItemById(FISH_ID) then
        if not isFishTargeted(p, myId) then return p end
      end
    end
  end
  return nil
end

local function getRandomGlobalWalkable()
  for i = 1, 50 do
    local x, y = math.random(AREA_FROM.x, AREA_TO.x), math.random(AREA_FROM.y, AREA_TO.y)
    local pos = Position(x, y, AREA_FROM.z)
    if isWalkable(pos, true) then return pos end
  end
  return nil
end

local function getRandomNearbyWalkable(currentPos, range)
  for i = 1, 20 do
    local x = math.random(currentPos.x - range, currentPos.x + range)
    local y = math.random(currentPos.y - range, currentPos.y + range)
    local pos = Position(x, y, currentPos.z)
    if (x ~= currentPos.x or y ~= currentPos.y) and isWalkable(pos, false) then
      return pos
    end
  end
  return nil
end

local function posToKey(pos)
  return pos.x .. "," .. pos.y .. "," .. pos.z
end

local function findAStarPath(start, goal)
  local maxNodes = 400
  local nodesChecked = 0
  local closed, open, cameFrom = {}, {start}, {}
  local gScore, fScore = { [posToKey(start)] = 0 }, { [posToKey(start)] = getDistance(start, goal) }
  while #open > 0 do
    nodesChecked = nodesChecked + 1
    if nodesChecked > maxNodes then return nil end
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
    for dx = -1, 1 do
      for dy = -1, 1 do
        if not (dx == 0 and dy == 0) then
          local n = Position(current.x + dx, current.y + dy, current.z)
          local isGoal = (n.x == goal.x and n.y == goal.y)
          if (isWalkable(n, false) or isJumpableWindow(n) or isGoal) and not closed[posToKey(n)] then
            local weight = (dx ~= 0 and dy ~= 0) and 3.0 or 1
            if isJumpableWindow(n) then weight = 0.5 end
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

local function catBehaviorLoop(monsterId)
  local cat = Monster(monsterId)
  if not cat then catsState[monsterId] = nil return end
  local state = catsState[monsterId]
  if not state then return end
  local currentHealth = cat:getHealth()
  if currentHealth <= 0 then catsState[monsterId] = nil return end
  local pos = cat:getPosition()
  local currentTime = os.time()
  local loopInterval = DEFAULT_INTERVAL

  if currentHealth < state.lastHealth then
    state.sleeping, state.goingToBed, state.eatingTarget, state.eatWaitTime = false, nil, nil, nil
    state.scaredUntil, state.sleepCooldown, state.astar, state.stuckCount = currentTime + 10, currentTime + 30, {}, 0
    loopInterval = SCARED_INTERVAL
    cat:say("WREEUNN!!", TALKTYPE_MONSTER_YELL)
  end
  state.lastHealth = currentHealth
  local isScared = (currentTime < state.scaredUntil)
  if isScared then loopInterval = SCARED_INTERVAL end

  if state.sleeping then
    local spectators = Game.getSpectators(pos, false, true, 2, 2, 2, 2)
    if #spectators > 0 then
      state.sleeping, state.scaredUntil, state.astar = false, 0, {}
      cat:say("!!", TALKTYPE_MONSTER_SAY)
      pos:sendMagicEffect(CONST_ME_POFF)
    elseif currentTime >= state.wakeUpTime then
      state.sleeping, state.sleepCooldown = false, currentTime + 30
      cat:say("", TALKTYPE_MONSTER_SAY)
    else
      pos:sendMagicEffect(33)
      addEvent(catBehaviorLoop, 2000, monsterId)
      return
    end
  end

  if not state.sleeping then
    if not isScared then
      if state.eatWaitTime then
        if currentTime >= state.eatWaitTime then
          local tile = Tile(pos)
          local fish = tile and tile:getItemById(FISH_ID)
          if fish then 
            fish:remove(1) 
            cat:say("Chomp.", TALKTYPE_MONSTER_SAY) 
            pos:sendMagicEffect(CONST_ME_BLOCKHIT)
            state.eatCooldown = currentTime + 60
          end
          state.eatWaitTime, state.eatingTarget = nil, nil
        end
        addEvent(catBehaviorLoop, 1000, monsterId)
        return
      end
      if not state.eatingTarget and not state.goingToBed and currentTime >= (state.eatCooldown or 0) then
        local fishPos = searchFreeFishNearby(pos, 8, monsterId)
        if fishPos then state.eatingTarget, state.astar = fishPos, {} end
      end
      if state.eatingTarget then
        if isFishTargeted(state.eatingTarget, monsterId) and getDistance(pos, state.eatingTarget) > 0 then
          state.eatingTarget, state.astar = nil, {}
        else
          if getDistance(pos, state.eatingTarget) <= 1 then
            cat:teleportTo(state.eatingTarget)
            state.eatWaitTime, state.astar = currentTime + 5, {}
            cat:say("", TALKTYPE_MONSTER_SAY)
            addEvent(catBehaviorLoop, 2000, monsterId)
            return
          elseif #state.astar == 0 then
            state.astar = findAStarPath(pos, state.eatingTarget) or {}
            if #state.astar == 0 then state.eatingTarget = nil else loopInterval = 400 end
          end
        end
      end
    end

    if not state.eatingTarget then
      if not isScared and not state.goingToBed then
        if currentTime > state.sleepCooldown and math.random(100) <= 15 then
          local bedPos = searchFreeBedNearby(pos, 20, monsterId)
          if bedPos then 
            state.goingToBed, state.astar = bedPos, {}
            cat:say("", TALKTYPE_MONSTER_SAY)
          else
            state.sleeping, state.astar, state.wakeUpTime = true, {}, currentTime + math.random(20, 60)
            cat:say("", TALKTYPE_MONSTER_SAY)
            addEvent(catBehaviorLoop, 3000, monsterId)
            return
          end
        end
        if currentTime > state.nextSoundTime and math.random(100) <= 15 then
          cat:say(math.random(1, 2) == 1 and "Meow!" or "Purrr..", TALKTYPE_MONSTER_SAY)
          state.nextSoundTime = currentTime + math.random(5, 10)
        end
        if math.random(1000) <= 10 then
          local item = Game.createItem(2025, 1, pos)
          if item then item:transform(2025, 5) end
          cat:say("", TALKTYPE_MONSTER_SAY)
          addEvent(catBehaviorLoop, 3000, monsterId)
          return
        end
      end

      if state.goingToBed then
        if isBedOccupied(state.goingToBed, monsterId) and getDistance(pos, state.goingToBed) > 0 then
          state.goingToBed, state.astar = nil, {}
        elseif getDistance(pos, state.goingToBed) <= 1 then
          cat:teleportTo(state.goingToBed)
          state.sleeping, state.goingToBed, state.astar, state.wakeUpTime = true, nil, {}, currentTime + math.random(40, 90)
          cat:say("", TALKTYPE_MONSTER_SAY)
          addEvent(catBehaviorLoop, 1000, monsterId)
          return
        elseif #state.astar == 0 then
          state.astar = findAStarPath(pos, state.goingToBed) or {}
          if #state.astar == 0 then state.goingToBed, state.sleeping, state.wakeUpTime = nil, true, currentTime + math.random(20, 60) end
        end
      end

      if #state.astar == 0 then
        local goal = nil
        if isScared then
          for i=1, 10 do local tp = getRandomGlobalWalkable() if tp and getDistance(pos, tp) >= 10 then goal = tp break end end
        elseif not state.goingToBed then
          if state.failPathCount >= 3 then
            for x = pos.x-4, pos.x+4 do for y = pos.y-4, pos.y+4 do
              local p = Position(x, y, pos.z) if isJumpableWindow(p) then goal = p break end
            end if goal then break end end
            if not goal then goal = getRandomNearbyWalkable(pos, 4) end
          else goal = getRandomGlobalWalkable() end
        end
        if goal then
          state.astar = findAStarPath(pos, goal) or {}
          state.failPathCount = (#state.astar == 0) and (state.failPathCount + 1) or 0
        end
        if #state.astar == 0 then
          local dir = math.random(0, 3)
          if isWalkable(pos:getNextPosition(dir), false) then cat:move(dir) end
          addEvent(catBehaviorLoop, DEFAULT_INTERVAL, monsterId)
          return
        end
      end
    end

    if #state.astar > 0 then
      local nextStep = state.astar[1]
      if isJumpableWindow(nextStep) then
        local dx, dy = nextStep.x - pos.x, nextStep.y - pos.y
        local landPos = Position(nextStep.x + dx, nextStep.y + dy, nextStep.z)
        if not isWalkable(landPos, false) and state.astar[2] then landPos = state.astar[2] end
        if isWalkable(landPos, false) then
          if not isScared then cat:say("", TALKTYPE_MONSTER_SAY) end
          cat:teleportTo(landPos)
          pos:sendMagicEffect(CONST_ME_POFF) landPos:sendMagicEffect(CONST_ME_POFF)
          state.astar, state.failPathCount = {}, 0
        else state.astar = {} end
      elseif isWalkable(nextStep, false) or (state.eatingTarget and nextStep.x == state.eatingTarget.x and nextStep.y == state.eatingTarget.y) or (state.goingToBed and nextStep.x == state.goingToBed.x and nextStep.y == state.goingToBed.y) then
        local dir = getDirectionTo(pos, nextStep)
        if dir and cat:move(dir) then table.remove(state.astar, 1) state.stuckCount = 0
        else state.stuckCount = state.stuckCount + 1 if state.stuckCount >= 2 then state.astar = {} end end
      else state.astar = {} end
    end
  end
  addEvent(catBehaviorLoop, loopInterval, monsterId)
end

function onThink(interval)
  local center = Position((AREA_FROM.x + AREA_TO.x)/2, (AREA_FROM.y + AREA_TO.y)/2, AREA_FROM.z)
  local spectators = Game.getSpectators(center, false, false, 50, 50, 50, 50)
  for _, cre in ipairs(spectators) do
    if cre:isMonster() and cre:getName() == CAT_NAME then
      local id = cre:getId()
      if not catsState[id] then
        catsState[id] = {astar={}, sleeping=false, sleepCooldown=os.time()+10, wakeUpTime=0, scaredUntil=0, lastHealth=cre:getHealth(), stuckCount=0, failPathCount=0, nextSoundTime=os.time()+5, goingToBed=nil, eatingTarget=nil, eatWaitTime=nil, eatCooldown=0}
        addEvent(catBehaviorLoop, DEFAULT_INTERVAL, id)
      end
    end
  end
  return true
end