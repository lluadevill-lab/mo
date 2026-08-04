-- ==========================================================
-- MOBA BASE - Regeneração na base (HP/Mana de jogadores e bots)
-- Registrado no globalevents.xml como "RegenAreas" (500ms)
-- ==========================================================

local function inZone(pos, zone)
    if not pos or not zone or not zone.from or not zone.to then return false end
    return pos.x >= zone.from.x and pos.x <= zone.to.x and
           pos.y >= zone.from.y and pos.y <= zone.to.y and
           pos.z == zone.from.z
end

function onThink(interval)
    if not MOBA or not MOBA.matchActive then return true end

    for teamId = 1, 2 do
        local team = MOBA.getTeamById(teamId)
        if not team or not team.healZone then return true end

        -- Jogadores
        for _, p in ipairs(Game.getPlayers()) do
            local pTeam = p:getStorageValue(MOBA.STORAGE_TEAM)
            if pTeam == teamId then
                local pos = p:getPosition()
                if inZone(pos, team.healZone) then
                    if p:getHealth() < p:getMaxHealth() then
                        p:addHealth(math.max(1, math.floor(p:getMaxHealth() * 0.04)))
                    end
                    if p:getMana() < p:getMaxMana() then
                        p:addMana(math.max(1, math.floor(p:getMaxMana() * 0.04)))
                    end
                end
            end
        end

        -- Bots
        if MOBA_BOTS and MOBA_BOTS.Data then
            for cid, d in pairs(MOBA_BOTS.Data) do
                if d.teamId == teamId then
                    local b = Creature(cid)
                    if b and b:getHealth() > 0 then
                        local pos = b:getPosition()
                        if inZone(pos, team.healZone) then
                            if b:getHealth() < b:getMaxHealth() then
                                b:addHealth(math.max(1, math.floor(b:getMaxHealth() * 0.04)))
                            end
                            -- Regen de mana dos bots na base
                            if d.maxMana and d.mana and d.mana < d.maxMana then
                                d.mana = math.min(d.maxMana, d.mana + d.maxMana * 0.06)
                            end
                        end
                    end
                end
            end
        end
    end

    return true
end
