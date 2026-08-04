-- ==========================================================
-- MOBA SCOREBOARD UPDATE - Sincroniza o placar periodicamente
-- com todos os jogadores na partida
-- Registrado no globalevents.xml como "MobaScoreboardUpdate" (1000ms)
-- ==========================================================

function onThink(interval)
    if not MOBA or not MOBA.matchActive then return true end
    if not sendScoreboardUpdate then return true end

    for _, p in ipairs(Game.getPlayers()) do
        local teamId = p:getStorageValue(MOBA.STORAGE_TEAM)
        if teamId == 1 or teamId == 2 then
            pcall(sendScoreboardUpdate, p)
        end
    end

    return true
end
