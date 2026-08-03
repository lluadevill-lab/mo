local LEVER_CONFIG = {
    [50010] = { team = MOBA.TEAMS.LEFT, centerPos = Position(1418, 1074, 7), range = 1 },
    [50011] = { team = MOBA.TEAMS.RIGHT, centerPos = Position(1425, 1074, 7), range = 1 }
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local cfg = LEVER_CONFIG[item.uid]
    if not cfg then return false end

    item:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

    local specs = Game.getSpectators(cfg.centerPos, false, true, cfg.range, cfg.range, cfg.range, cfg.range)
    
    local playersFound = {}

    -- 1. Teleporta e Configura Jogadores
    for _, p in ipairs(specs) do
        if p:isPlayer() then
            local teamId = cfg.team.id
            local basePos

            if teamId == MOBA.TEAMS.LEFT.id then
                basePos = Position(253, 1048, 7)
            else
                basePos = Position(381, 924, 7)
            end

            p:teleportTo(basePos)
            basePos:sendMagicEffect(CONST_ME_TELEPORT)

            p:setSkull(cfg.team.skull)
            p:setStorageValue(MOBA.STORAGE_TEAM, teamId)

            p:registerEvent("MobaPrepareDeath")
            p:registerEvent("MobaHealthChange")
            p:registerEvent("MobaManaChange")
            p:registerEvent("MobaKillReward")
            p:registerEvent("MobaScoreboard")

            -- Registra no PlayerStats IMEDIATAMENTE (Para o Scoreboard pegar o nome certo)
            if MOBA_BOTS and MOBA_BOTS.initPlayerStats then
                MOBA_BOTS.initPlayerStats(p)
            end

            p:sendTextMessage(MESSAGE_INFO_DESCR, "Voce entrou para o time " .. cfg.team.name .. "!")
            table.insert(playersFound, p)
        end
    end

    if #playersFound > 0 then
        -- Inicia a partida (O auto-spawn de bots acontece dentro dessa função agora)
        MOBA.startMatch()
    else
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Fique perto do cristal!")
        cfg.centerPos:sendMagicEffect(CONST_ME_TUTORIALARROW)
    end

    return true
end