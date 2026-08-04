-- ==========================================================
-- MOBA WAVES - Spawna as ondas de minions nas 3 lanes
-- Registrado no globalevents.xml como "MobaWaves" (1000ms)
-- ==========================================================

local function isWalkable(pos)
    local tile = Tile(pos)
    if not tile then return false end
    if tile:hasFlag(TILESTATE_NOTWALKABLE) or tile:hasFlag(TILESTATE_BLOCKSOLID) then
        return false
    end
    local creatures = tile:getCreatures()
    if creatures and #creatures > 0 then return false end
    return true
end

-- Encontra um tile livre perto do spawn (para minions não empilharem)
local function findSpawnPos(team)
    local base = Position(team.minionSpawn.x, team.minionSpawn.y, team.minionSpawn.z)
    if isWalkable(base) then return base end

    local offsets = {
        {x = 1, y = 0}, {x = -1, y = 0}, {x = 0, y = 1}, {x = 0, y = -1},
        {x = 2, y = 0}, {x = -2, y = 0}, {x = 1, y = 1}, {x = -1, y = -1},
        {x = 2, y = 1}, {x = -2, y = -1}
    }
    for _, off in ipairs(offsets) do
        local p = Position(base.x + off.x, base.y + off.y, base.z)
        if isWalkable(p) then return p end
    end
    return base
end

local function spawnWaveMinion(teamId, lane, mobName, delay)
    addEvent(function(tId, ln, name)
        if not MOBA or not MOBA.matchActive then return end

        local team = MOBA.getTeamById(tId)
        if not team then return end

        local spawnPos = findSpawnPos(team)
        local m = Game.createMonster(name, spawnPos, false, true)
        if not m then return end

        local cid = m:getId()
        if MOBA.startAI then
            MOBA.startAI(cid, tId, ln)
        end

        m:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

        if MOBA_BOTS and MOBA_BOTS.WaveCount then
            MOBA_BOTS.WaveCount[tId] = (MOBA_BOTS.WaveCount[tId] or 0) + 1
        end
    end, delay, teamId, lane, mobName)
end

function onThink(interval)
    if not MOBA or not MOBA.matchActive then return true end
    if not MOBA.TEAMS or not MOBA.MINIONS then return true end

    MOBA.waveCount = (MOBA.waveCount or 0) + 1

    -- Primeira wave após FIRST_WAVE segundos; depois a cada WAVE_INTERVAL
    local firstWave = MOBA.FIRST_WAVE or 5
    local waveInterval = MOBA.WAVE_INTERVAL or 20

    if MOBA.waveCount < firstWave then return true end

    local waveIndex = MOBA.waveCount - firstWave + 1
    if (waveIndex - 1) % waveInterval ~= 0 then return true end

    local waveOrder = MOBA.MINIONS.WAVE_ORDER or {"dwarf", "dwarf", "dwarf"}
    local spawnDelay = MOBA.SPAWN_DELAY or 1000

    for teamId = 1, 2 do
        local team = MOBA.getTeamById(teamId)
        if team then
            for _, lane in ipairs(MOBA.LANES or {"top", "mid", "bot"}) do
                local delay = 0
                for _, mobName in ipairs(waveOrder) do
                    spawnWaveMinion(teamId, lane, mobName, delay)
                    delay = delay + spawnDelay
                end

                -- Minions de cerco a cada 5ª onda
                if waveIndex % 5 == 0 then
                    for _, siegeName in ipairs(MOBA.MINIONS.SIEGE or {}) do
                        spawnWaveMinion(teamId, lane, siegeName, delay)
                        delay = delay + spawnDelay
                    end
                end
            end
        end
    end

    return true
end
