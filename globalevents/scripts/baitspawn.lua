-- baitspawn.lua
local DEBUG = false
local MIN_GROUND = 4

-- CONFIGURE AQUI
local BAITS = {
    [2666] = {monster = "Wolf",    time = 10, chance = 20, max = 3, valid_ground = {4526, 103}},
    [2684] = {monster = "Rabbit",    time = 10, chance = 40, max = 1, valid_ground = {4526, 103}},
    [2667] = {
        monster = "Seagull",
        time = 10,
        chance = 30,
        max = 4,
        valid_ground = {231},                          -- areia
        mandatory = {4634, 4635, 4633, 4632},          -- bordas água
    },
}

local function contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

local function tileHasAnyId(tile, ids)
    local g = tile:getGround()
    if g and contains(ids, g:getId()) then
        return true
    end
    for _, id in ipairs(ids) do
        if tile:getItemById(id) then
            return true
        end
    end
    for _, i in ipairs(tile:getItems() or {}) do
        if contains(ids, i:getId()) then
            return true
        end
    end
    return false
end

local function areaHasGround(pos, validGround)
    local count = 0
    for dx = -4, 4 do
        for dy = -4, 4 do
            local t = Tile(Position(pos.x + dx, pos.y + dy, pos.z))
            if t and tileHasAnyId(t, validGround) then
                count = count + 1
                if count >= MIN_GROUND then
                    return count
                end
            end
        end
    end
    return count
end

local function areaHasMandatory(pos, mandatory)
    for dx = -4, 4 do
        for dy = -4, 4 do
            local t = Tile(Position(pos.x + dx, pos.y + dy, pos.z))
            if t and tileHasAnyId(t, mandatory) then
                return true
            end
        end
    end
    return false
end

local function tileIsWalkable(position)
    local tile = Tile(position)
    if not tile then return false end
    if tile:hasProperty(CONST_PROP_IMMOVABLEBLOCKSOLID) then return false end
    if tile:hasProperty(CONST_PROP_BLOCKSOLID) then return false end
    if tile:getTopCreature() then return false end
    return true
end

function onThink(interval, lastExecution)
    if not _G.BAIT_TRACK then return true end

    for key, data in pairs(_G.BAIT_TRACK) do
        local cfg = BAITS[data.id]
        if not cfg then
            _G.BAIT_TRACK[key] = nil
            goto continue
        end

        if os.time() - data.time < cfg.time then goto continue end

        local pos = data.pos
        local tile = Tile(pos)
        if not tile then _G.BAIT_TRACK[key] = nil goto continue end

        local item = tile:getItemById(data.id)
        if not item then _G.BAIT_TRACK[key] = nil goto continue end

        -- players perto impede spawn
        for _, p in ipairs(Game.getPlayers()) do
            if p:getPosition():getDistance(pos) <= 7 then goto continue end
        end

        -- debug
        if DEBUG then
            local nearest, dist = nil, 99999
            for _, p in ipairs(Game.getPlayers()) do
                local d = p:getPosition():getDistance(pos)
                if d < dist then nearest = p dist = d end
            end
            if nearest then
                local g = cfg.valid_ground and areaHasGround(pos, cfg.valid_ground) or 0
                local m = cfg.mandatory and areaHasMandatory(pos, cfg.mandatory) and 1 or 0
                nearest:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
                    ("DEBUG bait %d: ground=%d mandatory=%d"):format(data.id, g, m))
            end
        end

        -- valid_ground check
        if cfg.valid_ground then
            if areaHasGround(pos, cfg.valid_ground) < MIN_GROUND then
                goto continue
            end
        end

        -- mandatory check (pelo menos 1 tile presente)
        if cfg.mandatory then
            if not areaHasMandatory(pos, cfg.mandatory) then
                goto continue
            end
        end

        -- spawn
        if math.random(100) <= cfg.chance then
            for i = 1, cfg.max do
                local spawnPos
                for _ = 1, 20 do
                    local p = Position(
                        pos.x + math.random(-2,2),
                        pos.y + math.random(-2,2),
                        pos.z
                    )
                    if tileIsWalkable(p) then
                        spawnPos = p
                        break
                    end
                end
                if spawnPos then
                    Game.createMonster(cfg.monster, spawnPos, false, true)
                end
            end
        end

        item:remove()
        _G.BAIT_TRACK[key] = nil

        ::continue::
    end

    return true
end
