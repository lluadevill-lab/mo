local CAT_NAME = "Cat"
local DEFAULT_INTERVAL = 600 -- Velocidade normal
local SCARED_INTERVAL = 300 -- Velocidade quando assustado (corre)
local AREA_FROM = Position(665, 382, 7)
local AREA_TO = Position(742, 438, 7)

-- IDs NOVOS
local BED_ID = 24171
local FISH_ID = 2667

local catData = nil
local spawnedCatId = nil

-- === CONFIGURAÇÃO DE CHANCES ===
local CHANCE_SOUND = 15   -- Chance de som
local CHANCE_PEE = 1      -- Chance de xixi
local CHANCE_SLEEP = 15   -- Chance de dormir

-- === FUNÇÕES DE UTILIDADE ===

local function getDistance(a, b)
  return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

local function isWalkable(pos)
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

  local items = tile:getItems()
  if items then
    for _, item in ipairs(items) do
      local itType = item:getType()
      if itType and itType:isBlocking() then
        return false
      end
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
      if name:find("window") and not name:find("closed") then
        return true
      end
    end
  end
  return false
end

local function searchItemNearby(centerPos, range, itemId)
  for x = centerPos.x - range, centerPos.x + range do
    for y = centerPos.y - range, centerPos.y + range do
      local p = Position(x, y, centerPos.z)
      local tile = Tile(p)
      if tile then
        local item = tile:getItemById(itemId)
        if item then return p end
      end
    end
  end
  return nil
end

local function getRandomGlobalWalkable()
  for i = 1, 50 do
    local x, y = math.random(AREA_FROM.x, AREA_TO.x), math.random(AREA_FROM.y, AREA_TO.y)
    local pos = Position(x, y, AREA_FROM.z)
    if isWalkable(pos) then return pos end
  end
  return nil
end

local function getRandomNearbyWalkable(currentPos, range)
  for i = 1, 20 do
    local x = math.random(currentPos.x - range, currentPos.x + range)
    local y = math.random(currentPos.y - range, currentPos.y + range)
    local pos = Position(x, y, currentPos.z)
    if (x ~= currentPos.x or y ~= currentPos.y) and isWalkable(pos) then
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
         
          if (isWalkable(n) or isJumpableWindow(n) or (n.x == goal.x and n.y == goal.y)) and not closed[posToKey(n)] then
           
            local weight = 1
            if dx ~= 0 and dy ~= 0 then
              weight = 3.0
            end

            if isJumpableWindow(n) then
              weight = 0.5
            end
           
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

-- === LÓGICA DE COMPORTAMENTO ===

local function catBehaviorLoop(monsterId)
  local cat = Monster(monsterId)
  if not cat or not catData then return end
 
  local currentHealth = cat:getHealth()
  if currentHealth <= 0 then catData = nil spawnedCatId = nil return end
 
  local state = catData
  local pos = cat:getPosition()
  local currentTime = os.time()
  local loopInterval = DEFAULT_INTERVAL

  -- 1. DETECTOR DE DANO / SUSTO
  if currentHealth < state.lastHealth then
    state.sleeping = false
    state.goingToBed = nil
    state.eatingTarget = nil
    state.eatWaitTime = nil
    state.scaredUntil = currentTime + 10
    state.sleepCooldown = currentTime + 30
    state.astar = {}
    state.stuckCount = 0
    loopInterval = SCARED_INTERVAL
    cat:say("WREEUNN!!", TALKTYPE_MONSTER_YELL)
  end
  state.lastHealth = currentHealth

  local isScared = (currentTime < state.scaredUntil)
  if isScared then loopInterval = SCARED_INTERVAL end

  -- 2. VERIFICAÇÃO DE JOGADORES (ACORDAR)
  if state.sleeping then
    local spectators = Game.getSpectators(pos, false, true, 2, 2, 2, 2)
    if #spectators > 0 then
      state.sleeping = false
      loopInterval = DEFAULT_INTERVAL
      state.scaredUntil = 0
      state.astar = {}
      cat:say("*acordando*", TALKTYPE_MONSTER_SAY)
      pos:sendMagicEffect(CONST_ME_POFF)
    end
  end

  -- 3. ESTADO: DORMINDO
  if state.sleeping then
    if currentTime < state.wakeUpTime then
      pos:sendMagicEffect(33) -- Zzz
      addEvent(catBehaviorLoop, 2000, monsterId)
      return
    else
      state.sleeping = false
      loopInterval = DEFAULT_INTERVAL
      state.sleepCooldown = currentTime + 30
      cat:say("*espreguica*", TALKTYPE_MONSTER_SAY)
    end
  end

  -- 4. ESTADO: ACORDADO
  if not state.sleeping then
    -- 4.1 COMER PEIXE (Prioridade Máxima se não assustado)
    if not isScared then
      if state.eatWaitTime then
        if currentTime >= state.eatWaitTime then
          local tile = Tile(pos)
          local fish = tile and tile:getItemById(FISH_ID)
          if fish then
            fish:remove()
            cat:say("Chomp.", TALKTYPE_MONSTER_SAY)
            pos:sendMagicEffect(CONST_ME_BLOCKHIT)
          end
          state.eatWaitTime = nil
          state.eatingTarget = nil
        end
        addEvent(catBehaviorLoop, 1000, monsterId)
        return
      end

      if not state.eatingTarget then
        local fishPos = searchItemNearby(pos, 8, FISH_ID)
        if fishPos then
          state.eatingTarget = fishPos
          state.astar = {}
          state.goingToBed = nil
        end
      end

      if state.eatingTarget then
        local tile = Tile(state.eatingTarget)
        if not tile or not tile:getItemById(FISH_ID) then
          state.eatingTarget = nil
        else
          if getDistance(pos, state.eatingTarget) <= 1 then
            cat:teleportTo(state.eatingTarget)
            state.eatWaitTime = currentTime + 5
            state.astar = {}
            cat:say("*comendo*", TALKTYPE_MONSTER_SAY)
            addEvent(catBehaviorLoop, 2000, monsterId)
            return
          else
            if not state.astar or #state.astar == 0 then
              state.astar = findAStarPath(pos, state.eatingTarget)
            end
            if not state.astar or #state.astar == 0 then
              state.eatingTarget = nil
            else
              loopInterval = 400
            end
          end
        end
      end
    end

    if not state.eatingTarget then
      -- 4.2 FLUFF (Sons/Xixi)
      if not isScared and not state.goingToBed then
        if currentTime > state.sleepCooldown and math.random(100) <= CHANCE_SLEEP and (not state.astar or #state.astar == 0) then
          local bedPos = searchItemNearby(pos, 20, BED_ID)
          if bedPos then
            state.goingToBed = bedPos
            state.astar = {}
            cat:say("*sono*", TALKTYPE_MONSTER_SAY)
          else
            state.sleeping = true
            state.astar = {}
            state.wakeUpTime = currentTime + math.random(20, 60)
            cat:say("*bocejando*", TALKTYPE_MONSTER_SAY)
            addEvent(catBehaviorLoop, 3000, monsterId)
            return
          end
        end

        if currentTime > state.nextSoundTime and math.random(100) <= CHANCE_SOUND then
          cat:say(math.random(1, 2) == 1 and "Meow!" or "Purrr..", TALKTYPE_MONSTER_SAY)
          state.nextSoundTime = currentTime + math.random(5, 10)
        end

        if math.random(1000) <= (CHANCE_PEE * 10) then
          local item = Game.createItem(2025, 1, Position(pos.x, pos.y, pos.z))
          if item then item:transform(2025, 5) end
          cat:say("*urinando*", TALKTYPE_MONSTER_SAY)
          addEvent(catBehaviorLoop, 3000, monsterId)
          return
        end
      end

      -- 4.3 INDO PARA A CAMA
      if state.goingToBed then
        if getDistance(pos, state.goingToBed) <= 1 then
          cat:teleportTo(state.goingToBed)
          state.sleeping = true
          state.goingToBed = nil
          state.astar = {}
          state.wakeUpTime = currentTime + math.random(40, 90)
          cat:say("Prrr...", TALKTYPE_MONSTER_SAY)
          addEvent(catBehaviorLoop, 1000, monsterId)
          return
        else
          if not state.astar or #state.astar == 0 then
            state.astar = findAStarPath(pos, state.goingToBed)
            if not state.astar or #state.astar == 0 then
              state.goingToBed = nil
              state.sleeping = true
              state.wakeUpTime = currentTime + math.random(20, 60)
            end
          end
        end
      end

      -- 4.4 MOVIMENTAÇÃO PADRÃO
      if not state.astar or #state.astar == 0 then
        local goal = nil
        if isScared then
          for i=1, 10 do
            local tryPos = getRandomGlobalWalkable()
            if tryPos and getDistance(pos, tryPos) >= 10 then
              goal = tryPos
              break
            end
          end
        elseif not state.goingToBed then
          if state.failPathCount >= 3 then
            for x = pos.x - 4, pos.x + 4 do
              for y = pos.y - 4, pos.y + 4 do
                local p = Position(x, y, pos.z)
                if isJumpableWindow(p) then goal = p break end
              end
            end
            if not goal then goal = getRandomNearbyWalkable(pos, 4) end
          else
            goal = getRandomGlobalWalkable()
          end
        end

        if goal then
          state.astar = findAStarPath(pos, goal)
          if not state.astar or #state.astar == 0 then
            state.failPathCount = state.failPathCount + 1
          else
            if not isScared and state.failPathCount >= 3 then state.failPathCount = 0 end
          end
        end

        if not state.astar or #state.astar == 0 then
          local dir = math.random(0, 3)
          if isWalkable(pos:getNextPosition(dir)) then cat:move(dir) end
          addEvent(catBehaviorLoop, DEFAULT_INTERVAL, monsterId)
          return
        end
      end
    end

    -- EXECUTAR PASSOS DO A*
    if state.astar and #state.astar > 0 then
      local nextStep = state.astar[1]
     
      if isJumpableWindow(nextStep) then
        local dx = nextStep.x - pos.x
        local dy = nextStep.y - pos.y
        local landPos = Position(nextStep.x + dx, nextStep.y + dy, nextStep.z)
       
        if not isWalkable(landPos) and state.astar[2] then landPos = state.astar[2] end

        if isWalkable(landPos) then
          if not isScared then cat:say("*pulou a janela*", TALKTYPE_MONSTER_SAY) end
          cat:teleportTo(landPos)
          pos:sendMagicEffect(CONST_ME_POFF)
          landPos:sendMagicEffect(CONST_ME_POFF)
          state.astar = {}
          state.failPathCount = 0
        else
          state.astar = {}
        end
     
      elseif isWalkable(nextStep) or (state.eatingTarget and nextStep.x == state.eatingTarget.x and nextStep.y == state.eatingTarget.y) or (state.goingToBed and nextStep.x == state.goingToBed.x and nextStep.y == state.goingToBed.y) then
        local dir = getDirectionTo(pos, nextStep)
        if dir and cat:move(dir) then
          table.remove(state.astar, 1)
          state.stuckCount = 0
          if #state.astar == 0 then state.failPathCount = 0 end
        else
          state.stuckCount = (state.stuckCount or 0) + 1
          if state.stuckCount >= 2 then state.astar = {} end
        end
      else
        state.astar = {}
      end
    end
  end

  addEvent(catBehaviorLoop, loopInterval, monsterId)
end

local function spawnCat()
  if spawnedCatId and Monster(spawnedCatId) then return end
  local startPos = getRandomGlobalWalkable()
  if not startPos then return end

  local cat = Game.createMonster(CAT_NAME, startPos, false, true)
  if not cat then return end

  spawnedCatId = cat:getId()
  catData = {
    astar = {},
    sleeping = false,
    sleepCooldown = os.time() + 10,
    wakeUpTime = 0,
    scaredUntil = 0,
    lastHealth = cat:getHealth(),
    stuckCount = 0,
    failPathCount = 0,
    nextSoundTime = os.time() + 5,
    goingToBed = nil,     -- Armazena posição da cama alvo
    eatingTarget = nil,   -- Armazena posição do peixe alvo
    eatWaitTime = nil     -- Timer para comer o peixe
  }

  addEvent(catBehaviorLoop, DEFAULT_INTERVAL, spawnedCatId)
end

function onThink(interval)
  spawnCat()
  return true
end

