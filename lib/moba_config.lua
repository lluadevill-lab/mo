MOBA = {
    STORAGE_TEAM = 50020,

    TEAMS = {
        LEFT = {
            id = 1,
            name = "Luz",
            skull = SKULL_GREEN,
            enemy_skull = SKULL_RED,
            nexus = {pos = {x = 259, y = 1044, z = 7}, name = "nucleo de luz"},
            towers = {
                top = {
                    {pos = {x = 264, y = 1032, z = 7}, name = "torre de luz", lane = "top", index = 1},
                    {pos = {x = 264, y = 1013, z = 7}, name = "torre de luz", lane = "top", index = 2},
                    {pos = {x = 264, y = 968, z = 7}, name = "torre de luz", lane = "top", index = 3}
                },
                mid = {
                    {pos = {x = 271, y = 1032, z = 7}, name = "torre de luz", lane = "mid", index = 1},
                    {pos = {x = 290, y = 1013, z = 7}, name = "torre de luz", lane = "mid", index = 2},
                    {pos = {x = 310, y = 993, z = 7}, name = "torre de luz", lane = "mid", index = 3}
                },
                bot = {
                    {pos = {x = 271, y = 1039, z = 7}, name = "torre de luz", lane = "bot", index = 1},
                    {pos = {x = 290, y = 1039, z = 7}, name = "torre de luz", lane = "bot", index = 2},
                    {pos = {x = 363, y = 1039, z = 7}, name = "torre de luz", lane = "bot", index = 3}
                }
            },
            spawnPos = {x = 253, y = 1050, z = 7},
            minionSpawn = {x = 259, y = 1044, z = 7}
        },
        RIGHT = {
            id = 2,
            name = "Sombra",
            skull = SKULL_RED,
            enemy_skull = SKULL_GREEN,
            nexus = {pos = {x = 374, y = 929, z = 7}, name = "nucleo sombrio"},
            towers = {
                top = {
                    {pos = {x = 362, y = 934, z = 7}, name = "torre sombria", lane = "top", index = 1},
                    {pos = {x = 340, y = 935, z = 7}, name = "torre sombria", lane = "top", index = 2},
                    {pos = {x = 286, y = 934, z = 7}, name = "torre sombria", lane = "top", index = 3}
                },
                mid = {
                    {pos = {x = 362, y = 941, z = 7}, name = "torre sombria", lane = "mid", index = 1},
                    {pos = {x = 340, y = 963, z = 7}, name = "torre sombria", lane = "mid", index = 2},
                    {pos = {x = 323, y = 980, z = 7}, name = "torre sombria", lane = "mid", index = 3}
                },
                bot = {
                    {pos = {x = 368, y = 941, z = 7}, name = "torre sombria", lane = "bot", index = 1},
                    {pos = {x = 368, y = 963, z = 7}, name = "torre sombria", lane = "bot", index = 2},
                    {pos = {x = 368, y = 1007, z = 7}, name = "torre sombria", lane = "bot", index = 3}
                }
            },
            spawnPos = {x = 381, y = 924, z = 7},
            minionSpawn = {x = 374, y = 929, z = 7}
        }
    },

    LANES = {"top", "mid", "bot"},

    WAYPOINTS = {
        top = {
            {x = 260, y = 1042, z = 7}, {x = 263, y = 1035, z = 7},
            {x = 263, y = 1021, z = 7}, {x = 264, y = 1003, z = 7},
            {x = 265, y = 991, z = 7}, {x = 265, y = 984, z = 7},
            {x = 265, y = 973, z = 7}, {x = 264, y = 961, z = 7},
            {x = 264, y = 952, z = 7}, {x = 264, y = 946, z = 7},
            {x = 264, y = 939, z = 7}, {x = 272, y = 934, z = 7},
            {x = 282, y = 934, z = 7}, {x = 294, y = 933, z = 7},
            {x = 311, y = 934, z = 7}, {x = 326, y = 933, z = 7},
            {x = 338, y = 934, z = 7}, {x = 356, y = 933, z = 7},
            {x = 366, y = 934, z = 7}, {x = 371, y = 929, z = 7}
        },
        mid = {
            {x = 261, y = 1042, z = 7}, {x = 264, y = 1039, z = 7},
            {x = 267, y = 1036, z = 7}, {x = 270, y = 1033, z = 7},
            {x = 276, y = 1027, z = 7}, {x = 280, y = 1024, z = 7},
            {x = 284, y = 1018, z = 7}, {x = 288, y = 1014, z = 7},
            {x = 295, y = 1007, z = 7}, {x = 301, y = 1002, z = 7},
            {x = 307, y = 996, z = 7}, {x = 313, y = 991, z = 7},
            {x = 319, y = 984, z = 7}, {x = 322, y = 981, z = 7},
            {x = 327, y = 975, z = 7}, {x = 338, y = 966, z = 7},
            {x = 345, y = 960, z = 7}, {x = 350, y = 956, z = 7},
            {x = 355, y = 948, z = 7}, {x = 363, y = 941, z = 7},
            {x = 364, y = 939, z = 7}, {x = 369, y = 933, z = 7},
	    {x = 372, y = 931, z = 7}
        },
        bot = {
            {x = 261, y = 1043, z = 7}, {x = 266, y = 1040, z = 7},
            {x = 270, y = 1039, z = 7}, {x = 278, y = 1039, z = 7},
            {x = 286, y = 1039, z = 7}, {x = 290, y = 1038, z = 7},
            {x = 299, y = 1039, z = 7}, {x = 308, y = 1039, z = 7},
            {x = 317, y = 1039, z = 7}, {x = 329, y = 1039, z = 7},
            {x = 336, y = 1040, z = 7}, {x = 343, y = 1040, z = 7},
            {x = 352, y = 1040, z = 7}, {x = 360, y = 1040, z = 7},
            {x = 367, y = 1039, z = 7}, {x = 369, y = 1035, z = 7},
            {x = 369, y = 1026, z = 7}, {x = 369, y = 1018, z = 7},
            {x = 368, y = 1009, z = 7}, {x = 369, y = 999, z = 7},
            {x = 369, y = 989, z = 7}, {x = 369, y = 980, z = 7},
            {x = 369, y = 970, z = 7}, {x = 369, y = 958, z = 7},
            {x = 369, y = 948, z = 7}, {x = 369, y = 939, z = 7},
            {x = 372, y = 934, z = 7}, {x = 373, y = 931, z = 7}
        }
    },

    -- Composição ideal do time: 1 knight, 1 sorcerer, 1 paladin, 2 druids
    IDEAL_COMP = {
        knight = 1,
        sorcerer = 1,
        paladin = 1,
        druid = 2
    },

    -- Mapeamento de vocação do servidor para classe MOBA
    VOC_MAP = {
        ["knight"] = "knight",
        ["elite knight"] = "knight",
        ["paladin"] = "paladin",
        ["royal paladin"] = "paladin",
        ["sorcerer"] = "sorcerer",
        ["master sorcerer"] = "sorcerer",
        ["druid"] = "druid",
        ["elder druid"] = "druid"
    },

    -- Layout ideal das lanes
    -- Cada lane tem slots com classe preferida
    LANE_LAYOUT = {
        top = {"knight", "druid"},
        mid = {"sorcerer"},
        bot = {"paladin", "druid"}
    },

    LOBBY_POS = Position(1422, 1071, 7),

    REWARDS = {
        PLAYER_KILL = 300, TOWER = 500, NEXUS = 1000, ASSIST_PERCENT = 0.5
    },

    MINIONS_CONFIG = {
        ["dwarf soldier"] = {range = 3, minDmg = 10, maxDmg = 20, attackSpeed = 1500, distEffect = CONST_ANI_BOLT, gold = 30, xp = 800, type = "ranged"},
        ["dwarf geomancer"] = {range = 4, minDmg = 20, maxDmg = 30, attackSpeed = 1500, distEffect = CONST_ANI_EARTH, gold = 50, xp = 2000, type = "ranged"},
        ["dwarf"] = {range = 1, minDmg = 5, maxDmg = 10, attackSpeed = 1500, gold = 10, xp = 500, type = "melee"},
        ["default"] = {range = 1, minDmg = 10, maxDmg = 20, attackSpeed = 1500, type = "melee", gold = 0, xp = 0}
    },

    MINIONS = {
        WAVE_ORDER = {"dwarf", "dwarf", "dwarf", "dwarf soldier", "dwarf soldier"},
        SIEGE = {"dwarf geomancer"}
    },

    FIRST_WAVE = 5,
    WAVE_INTERVAL = 20,
    SPAWN_DELAY = 1000,
    BOT_PREP_TIME = 3,

    MinionState = {},
    Objectives = {},
    LaneState = {},
    matchActive = false,
    matchTime = 0,
    waveCount = 0,
    spawnedStructures = {},
    botsSpawned = {[1] = false, [2] = false}
}

-- ============================================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================================

function getEnemyTeam(teamId)
    return teamId == MOBA.TEAMS.LEFT.id and MOBA.TEAMS.RIGHT.id or MOBA.TEAMS.LEFT.id
end

function MOBA.getTeamById(teamId)
    if teamId == 1 then return MOBA.TEAMS.LEFT end
    return MOBA.TEAMS.RIGHT
end

function MOBA.getEnemyTeamObj(teamId)
    if teamId == 1 then return MOBA.TEAMS.RIGHT end
    return MOBA.TEAMS.LEFT
end

function MOBA.getWaypoints(teamId, lane)
    if not lane then return {} end
    local wps = MOBA.WAYPOINTS[lane]
    if not wps then return {} end
    if teamId == 1 then return wps end
    local reversed = {}
    for i = #wps, 1, -1 do table.insert(reversed, wps[i]) end
    return reversed
end

function MOBA.findNearestWaypoint(pos, teamId, lane)
    local wps = MOBA.getWaypoints(teamId, lane)
    if #wps == 0 then return 1 end
    local bestIdx, bestDist = 1, 999999
    for i, wp in ipairs(wps) do
        local d = math.abs(pos.x - wp.x) + math.abs(pos.y - wp.y)
        if d < bestDist then bestDist = d bestIdx = i end
    end
    if bestIdx == 1 and bestDist <= 5 and #wps > 1 then bestIdx = 2 end
    return bestIdx
end

function MOBA.getNextObjective(teamId, lane)
    local enemyTeamId = getEnemyTeam(teamId)
    local enemyTeam = MOBA.getTeamById(enemyTeamId)
    local objectives = MOBA.Objectives[enemyTeamId]
    if not objectives then return nil end
    local laneTowers = objectives.towers[lane]
    if not laneTowers then return nil end
    for i = 3, 1, -1 do
        if laneTowers[i] then
            return {type = "tower", pos = enemyTeam.towers[lane][i].pos, lane = lane, index = i}
        end
    end
    if objectives.nexus then
        return {type = "nexus", pos = enemyTeam.nexus.pos, lane = lane}
    end
    return nil
end

function MOBA.getTowersDestroyed(teamId, lane)
    local obj = MOBA.Objectives[teamId]
    if not obj or not obj.towers[lane] then return 0 end
    local d = 0
    for i = 1, 3 do if not obj.towers[lane][i] then d = d + 1 end end
    return d
end

function MOBA.getTotalTowersDestroyed(teamId)
    local t = 0
    for _, lane in ipairs(MOBA.LANES) do t = t + MOBA.getTowersDestroyed(teamId, lane) end
    return t
end

function MOBA.getMostThreatenedLane(teamId)
    local worst, worstCount = nil, -1
    for _, lane in ipairs(MOBA.LANES) do
        local d = MOBA.getTowersDestroyed(teamId, lane)
        if d > worstCount then worstCount = d worst = lane end
    end
    return worst, worstCount
end

function MOBA.getInfo(cid, field)
    local state = MOBA.MinionState[cid]
    if not state then return 0 end
    if field == "team" then return state.teamId or 0 end
    if field == "lane" then return state.lane or "mid" end
    return 0
end

-- ============================================================
-- AUTO-SPAWN: Lê jogadores na base e spawna bots faltantes
-- ============================================================

function MOBA.getPlayerClass(player)
    if not player or not player:getVocation() then return nil end
    local vocName = player:getVocation():getName():lower()
    return MOBA.VOC_MAP[vocName]
end

function MOBA.getPlayersInBase(teamId)
    local team = MOBA.getTeamById(teamId)
    local baseFrom, baseTo

    if teamId == 1 then
        baseFrom = Position(251, 1032, 7)
        baseTo = Position(271, 1054, 7)
    else
        baseFrom = Position(362, 921, 7)
        baseTo = Position(386, 941, 7)
    end

    local players = {}
    for _, player in ipairs(Game.getPlayers()) do
        local pTeam = player:getStorageValue(MOBA.STORAGE_TEAM)
        if pTeam == teamId then
            local pos = player:getPosition()
            if pos.x >= baseFrom.x and pos.x <= baseTo.x and
               pos.y >= baseFrom.y and pos.y <= baseTo.y and
               pos.z == baseFrom.z then
                table.insert(players, player)
            end
        end
    end

    return players
end

function MOBA.countClassesInTeam(teamId)
    local counts = {knight = 0, sorcerer = 0, paladin = 0, druid = 0}

    -- Conta jogadores
    local players = MOBA.getPlayersInBase(teamId)
    for _, player in ipairs(players) do
        local cls = MOBA.getPlayerClass(player)
        if cls and counts[cls] ~= nil then
            counts[cls] = counts[cls] + 1
        end
    end

    -- Conta bots já spawnados
    if MOBA_BOTS and MOBA_BOTS.Data then
        for cid, bdata in pairs(MOBA_BOTS.Data) do
            if bdata.teamId == teamId then
                local c = Creature(cid)
                if c and c:getHealth() > 0 then
                    if counts[bdata.class] then
                        counts[bdata.class] = counts[bdata.class] + 1
                    end
                end
            end
        end
    end

    return counts
end

function MOBA.autoSpawnBots(teamId)
    if MOBA.botsSpawned[teamId] then return end
    MOBA.botsSpawned[teamId] = true

    local current = MOBA.countClassesInTeam(teamId)
    local toSpawn = {}

    for cls, needed in pairs(MOBA.IDEAL_COMP) do
        local missing = needed - (current[cls] or 0)
        for i = 1, missing do
            table.insert(toSpawn, cls)
        end
    end

    if #toSpawn == 0 then
        print("[MOBA] Time " .. teamId .. ": Composicao completa, nenhum bot necessario.")
        return
    end

    local teamName = teamId == 1 and "Luz" or "Sombra"
    print("[MOBA] Time " .. teamName .. ": Spawnando " .. #toSpawn .. " bots: " .. table.concat(toSpawn, ", "))

    for i, cls in ipairs(toSpawn) do
        addEvent(function(tid, className)
            if MOBA.matchActive and MOBA_BOTS then
                MOBA_BOTS.spawn(tid, className)
            end
        end, i * 500, teamId, cls)
    end
end

-- ============================================================
-- ATRIBUIÇÃO DE LANES BASEADA NO LAYOUT IDEAL
-- Lê todos os jogadores e bots e distribui conforme o layout
-- ============================================================

function MOBA.assignAllLanes(teamId)
    if not MOBA_BOTS then return end

    -- Coleta todos os heróis (jogadores + bots) do time
    local heroes = {}

    -- Jogadores
    for _, player in ipairs(Game.getPlayers()) do
        local pTeam = player:getStorageValue(MOBA.STORAGE_TEAM)
        if pTeam == teamId then
            local cls = MOBA.getPlayerClass(player)
            if cls then
                table.insert(heroes, {
                    id = player:getId(),
                    class = cls,
                    isPlayer = true,
                    assigned = false,
                    assignedLane = nil
                })
            end
        end
    end

    -- Bots
    for cid, bdata in pairs(MOBA_BOTS.Data) do
        if bdata.teamId == teamId then
            local c = Creature(cid)
            if c and c:getHealth() > 0 then
                table.insert(heroes, {
                    id = cid,
                    class = bdata.class,
                    isPlayer = false,
                    assigned = false,
                    assignedLane = nil
                })
            end
        end
    end

    -- Layout: top = {knight, druid}, mid = {sorcerer}, bot = {paladin, druid}
    local layout = {
        top = {"knight", "druid"},
        mid = {"sorcerer"},
        bot = {"paladin", "druid"}
    }

    local laneAssignments = {top = {}, mid = {}, bot = {}}

    -- Primeira passada: atribui por correspondência exata
    for _, lane in ipairs(MOBA.LANES) do
        for _, slotClass in ipairs(layout[lane]) do
            for _, hero in ipairs(heroes) do
                if not hero.assigned and hero.class == slotClass then
                    hero.assigned = true
                    hero.assignedLane = lane
                    table.insert(laneAssignments[lane], hero)
                    break
                end
            end
        end
    end

    -- Segunda passada: heróis não atribuídos vão para lanes com vagas
    for _, hero in ipairs(heroes) do
        if not hero.assigned then
            -- Tenta lane com menos gente
            local bestLane = nil
            local bestCount = 999
            for _, lane in ipairs(MOBA.LANES) do
                local maxSlots = #layout[lane]
                if #laneAssignments[lane] < maxSlots then
                    if #laneAssignments[lane] < bestCount then
                        bestCount = #laneAssignments[lane]
                        bestLane = lane
                    end
                end
            end

            if not bestLane then
                -- Tudo cheio, vai pra menos lotada
                bestLane = "mid"
                bestCount = 999
                for _, lane in ipairs(MOBA.LANES) do
                    if #laneAssignments[lane] < bestCount then
                        bestCount = #laneAssignments[lane]
                        bestLane = lane
                    end
                end
            end

            hero.assigned = true
            hero.assignedLane = bestLane
            table.insert(laneAssignments[bestLane], hero)
        end
    end

    -- Aplica as atribuições nos bots
    MOBA_BOTS.LaneSlots[teamId] = {top = {}, mid = {}, bot = {}}

    for _, lane in ipairs(MOBA.LANES) do
        for _, hero in ipairs(laneAssignments[lane]) do
            if not hero.isPlayer then
                local bdata = MOBA_BOTS.Data[hero.id]
                if bdata then
                    bdata.assignedLane = lane
                    bdata.wpIndex = 1
                    bdata.wpInitialized = true
                    table.insert(MOBA_BOTS.LaneSlots[teamId][lane], hero.id)

                    local bot = Creature(hero.id)
                    if bot then
                        local ln = {top="TOP", mid="MID", bot="BOT"}
                        bot:say(bdata.class:upper() .. " -> " .. (ln[lane] or "?"), TALKTYPE_MONSTER_YELL)
                    end
                end
            end
        end
    end

    local ln = {top="TOP", mid="MID", bot="BOT"}
    for _, lane in ipairs(MOBA.LANES) do
        local names = {}
        for _, h in ipairs(laneAssignments[lane]) do
            table.insert(names, h.class:upper() .. (h.isPlayer and "(P)" or "(B)"))
        end
        if #names > 0 then
            print("[MOBA] Time " .. teamId .. " " .. ln[lane] .. ": " .. table.concat(names, ", "))
        end
    end
end

-- ============================================================
-- START / END MATCH
-- ============================================================

function MOBA.startMatch()
    if MOBA.matchActive then return false end
    MOBA.matchActive = true
    MOBA.matchTime = 0
    MOBA.waveCount = 0
    MOBA.spawnedStructures = {}
    MOBA.MinionState = {}
    MOBA.Objectives = {}
    MOBA.LaneState = {}
    MOBA.botsSpawned = {[1] = false, [2] = false}

    -- MODIFICAÇÃO DE SEGURANÇA AQUI:
    if MOBA_BOTS then
        if MOBA_BOTS.resetScoreboard then
            MOBA_BOTS.resetScoreboard()
        end
        if MOBA_BOTS.resetPlayerStats then
            MOBA_BOTS.resetPlayerStats()
        end
    end

    for _, team in pairs({MOBA.TEAMS.LEFT, MOBA.TEAMS.RIGHT}) do
        MOBA.Objectives[team.id] = {
            nexus = true,
            towers = {top = {true, true, true}, mid = {true, true, true}, bot = {true, true, true}}
        }
    end

    for _, team in pairs({MOBA.TEAMS.LEFT, MOBA.TEAMS.RIGHT}) do
        MOBA.LaneState[team.id] = {}
        for _, lane in ipairs(MOBA.LANES) do
            MOBA.LaneState[team.id][lane] = {underThreat = false, lastThreatTime = 0, defenders = 0}
        end
    end

    local function spawnStructure(name, posCfg, team, isNexus, lane, towerIndex)
        local pos = Position(posCfg.x, posCfg.y, posCfg.z)
        local m = Game.createMonster(name, pos, false, true)
        if m then
            local cid = m:getId()
            m:setSkull(team.skull)
            MOBA.MinionState[cid] = {
                teamId = team.id, isStructure = true, isNexus = isNexus or false,
                enemySkull = team.enemy_skull, lane = lane, towerIndex = towerIndex,
                config = {range = 4, minDmg = 50, maxDmg = 80, attackSpeed = 1500, type = "ranged", distEffect = CONST_ANI_ENERGY}
            }
            m:registerEvent(isNexus and "MobaNexusDeath" or "MobaTowerDeath")
            m:registerEvent("MobaHealthChange")
            table.insert(MOBA.spawnedStructures, cid)
            if MobaMinionLogic then MobaMinionLogic(cid) end
        end
    end

    for _, team in pairs({MOBA.TEAMS.LEFT, MOBA.TEAMS.RIGHT}) do
        spawnStructure(team.nexus.name, team.nexus.pos, team, true, nil, nil)
        for _, lane in ipairs(MOBA.LANES) do
            for i, tower in ipairs(team.towers[lane]) do
                spawnStructure(tower.name, tower.pos, team, false, lane, i)
            end
        end
    end

    Game.broadcastMessage("[MOBA] A partida comecou! Bots serao spawnados em 5 segundos.", MESSAGE_STATUS_WARNING)

    -- Auto-spawn bots após 5 segundos (tempo para jogadores se posicionarem)
    addEvent(function()
        if not MOBA.matchActive then return end
        MOBA.autoSpawnBots(1)
        MOBA.autoSpawnBots(2)

        -- Após todos os bots spawnarem + 3s, atribui lanes
        addEvent(function()
            if not MOBA.matchActive then return end
            MOBA.assignAllLanes(1)
            MOBA.assignAllLanes(2)
            Game.broadcastMessage("[MOBA] Bots organizados! Preparando para batalha...", MESSAGE_STATUS_WARNING)
        end, 4000)
    end, 5000)

    return true
end

function MOBA.endMatch()
    if not MOBA.matchActive then return end
    MOBA.matchActive = false

    for _, cid in ipairs(MOBA.spawnedStructures) do
        local c = Creature(cid)
        if c then c:remove() end
    end

    for cid, state in pairs(MOBA.MinionState) do
        if not state.isBot then
            local c = Creature(cid)
            if c and not c:isPlayer() then c:remove() end
        end
    end

    if MOBA_BOTS and MOBA_BOTS.Data then
        for cid, _ in pairs(MOBA_BOTS.Data) do
            local bot = Creature(cid)
            if bot then bot:remove() end
        end
        MOBA_BOTS.Data = {}
    end

    for _, p in ipairs(Game.getPlayers()) do
        if p:getSkull() == SKULL_GREEN or p:getSkull() == SKULL_RED then
            p:teleportTo(MOBA.LOBBY_POS)
            p:setSkull(SKULL_NONE)
            p:setStorageValue(MOBA.STORAGE_TEAM, -1)
            p:unregisterEvent("MobaPlayerDeath")
            p:unregisterEvent("MobaPrepareDeath")
            p:unregisterEvent("MobaHealthChange")
            p:unregisterEvent("MobaManaChange")
            p:unregisterEvent("MobaKillReward")
            p:addHealth(p:getMaxHealth())
            p:addMana(p:getMaxMana())
        end
    end

    MOBA.MinionState = {}
    MOBA.Objectives = {}
    MOBA.LaneState = {}
    MOBA.spawnedStructures = {}
    MOBA.botsSpawned = {[1] = false, [2] = false}
end

