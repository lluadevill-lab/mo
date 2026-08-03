local COOLDOWN_STORAGE = 90123
local COOLDOWN_TIME = 0 * 60 * 60 -- 1 dia

local centerSpawn = Position(1635, 1447, 7)

local slots = {
    Position(1631, 1439, 7),
    Position(1632, 1439, 7),
    Position(1633, 1439, 7),
    Position(1634, 1439, 7),
    Position(1635, 1439, 7),
    Position(1636, 1439, 7),
    Position(1637, 1439, 7),
    Position(1638, 1439, 7),
    Position(1639, 1439, 7)
}

local monsters = {
    "Rat",
    "Cyclops",
    "Dragon",
    "Giant Spider",
    "Demon",
    "Vampire",
    "Slime",
    "Behemoth",
    "Ghoul"
}

-- VELOCIDADE DO GIRO (ms)
local interval = 500   -- <<< MODIFIQUE AQUI

local function clearSlot(pos)
    local tile = Tile(pos)
    if not tile then return end
    for _, thing in ipairs(tile:getCreatures() or {}) do
        if thing:isMonster() then
            thing:remove()
        end
    end
end

local function moveMonsters(monsterRefs, cyclesLeft)
    local last = monsterRefs[#monsterRefs]
    for i = #monsterRefs, 2, -1 do
        monsterRefs[i] = monsterRefs[i - 1]
    end
    monsterRefs[1] = last

    -- mover
    for i, m in ipairs(monsterRefs) do
        if m and m:isMonster() then
            m:teleportTo(slots[i], true)
            m:getPosition():sendMagicEffect(CONST_ME_POFF)
        end
    end

    -- continuar girando
    if cyclesLeft > 0 then
        addEvent(moveMonsters, interval, monsterRefs, cyclesLeft - 1)
        return
    end

    -- AQUI A ROLETA PAROU!
    local mid = math.ceil(#slots / 2)
    local finalMonster = monsterRefs[mid]

    -- remove todos EXCETO o vencedor
    for i, m in ipairs(monsterRefs) do
        if m and m:isMonster() and i ~= mid then
            m:remove()
        end
    end

    -- AGORA o vencedor fica sozinho por 2 segundos
    addEvent(function()
        if finalMonster and finalMonster:isMonster() then
            finalMonster:teleportTo(centerSpawn, true)
            centerSpawn:sendMagicEffect(CONST_ME_TELEPORT)
        end
    end, 2000) -- 2000 ms = 2 segundos
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)

    local last = getGlobalStorageValue(COOLDOWN_STORAGE)
    if last > os.time() then
        player:sendCancelMessage("A roleta pode ser usada apenas 1 vez por dia.")
        return true
    end

    setGlobalStorageValue(COOLDOWN_STORAGE, os.time() + COOLDOWN_TIME)

    -- limpa os slots
    for _, pos in ipairs(slots) do
        clearSlot(pos)
    end

    -- cria monstros
    local monsterRefs = {}
    for i, name in ipairs(monsters) do
        local m = Game.createMonster(name, slots[i], true, true)
        if m then
            monsterRefs[i] = m
        end
    end

    -- ciclos aleatórios
    local randomCycles = math.random(15, 35)

    moveMonsters(monsterRefs, randomCycles)
    return true
end
