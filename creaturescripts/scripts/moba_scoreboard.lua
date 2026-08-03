local OPCODE_SCOREBOARD = 109

function sendScoreboardUpdate(player)
    if not player or not MOBA_BOTS then return end
    
    -- Sincroniza torres
    if MOBA_BOTS.syncTowerState then
        MOBA_BOTS.syncTowerState()
    end
    
    local buffer = ""
    
    -- === 1. TIMES (usando TeamScores) ===
    for teamId = 1, 2 do
        -- USA TeamScores ao invés de Scoreboard!
        local score = MOBA_BOTS.TeamScores[teamId] or {kills=0, deaths=0, towersDestroyed=0, totalGold=0, totalExp=0, minionsKilled=0}
        local towers = MOBA_BOTS.TowerState[teamId] or { top = {true,true,true,true}, mid = {true,true,true,true}, bot = {true,true,true,true} }
        
        local tStr = ""
        for _, lane in ipairs({"top", "mid", "bot"}) do
            for i = 1, 4 do
                local alive = "0"
                if towers[lane] and towers[lane][i] then
                    alive = "1"
                end
                tStr = tStr .. "," .. alive
            end
        end
        
        -- USA "kills" e "deaths" (não heroKills/heroDeaths)
        buffer = buffer .. string.format("%d,%d,%d,%d,%d,%d,%d%s", 
            teamId,
            score.towersDestroyed or 0, 
            score.minionsKilled or 0,
            score.kills or 0,           -- Antes era heroKills
            score.deaths or 0,          -- Antes era heroDeaths
            score.totalGold or 0, 
            score.totalExp or 0,
            tStr
        )
        
        if teamId == 1 then buffer = buffer .. "@" end
    end
    
    buffer = buffer .. "#"
    
    -- === 2. JOGADORES ===
    local entries = {}
    
    for _, tid in ipairs({1, 2}) do
        local players = MOBA_BOTS.getTeamPlayers(tid)
        for _, p in ipairs(players) do
            table.insert(entries, {tid = tid, data = p})
        end
    end
    
    for i, item in ipairs(entries) do
        local p = item.data
        local safeName = (p.name or "Unknown"):gsub("[,@#]", "")
        
        local line = string.format("%d,%s,%d,%s,%d,%d,%d,%d", 
            item.tid, 
            safeName, 
            p.isBot and 1 or 0, 
            p.vocation or "Unknown", 
            p.kills or 0, 
            p.deaths or 0, 
            p.gold or 0,
            p.level or 1
        )
            
        buffer = buffer .. line
        
        if i < #entries then buffer = buffer .. "@" end
    end
    
    player:sendExtendedOpcode(OPCODE_SCOREBOARD, "UPDATE:" .. buffer)
end

function onExtendedOpcode(player, opcode, buffer)
    if opcode == OPCODE_SCOREBOARD then
        if buffer == "REQUEST" then
            sendScoreboardUpdate(player)
        end
        return true
    end
    return false
end