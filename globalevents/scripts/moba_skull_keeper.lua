-- ==========================================================
-- MOBA SKULL KEEPER - Mantém os skulls corretos dos jogadores
-- durante a partida (evita que o skull suma por qualquer motivo)
-- Registrado no globalevents.xml como "MobaSkullKeeper" (1000ms)
-- ==========================================================

function onThink(interval)
    if not MOBA or not MOBA.matchActive then return true end

    for _, p in ipairs(Game.getPlayers()) do
        local teamId = p:getStorageValue(MOBA.STORAGE_TEAM)
        if teamId == 1 then
            if p:getSkull() ~= MOBA.TEAMS.LEFT.skull then
                p:setSkull(MOBA.TEAMS.LEFT.skull)
            end
        elseif teamId == 2 then
            if p:getSkull() ~= MOBA.TEAMS.RIGHT.skull then
                p:setSkull(MOBA.TEAMS.RIGHT.skull)
            end
        end
    end

    return true
end
