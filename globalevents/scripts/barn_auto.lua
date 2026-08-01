local BARN_CONFIG = { 
    radius = 10, 
    maxPets = 10, 
    markerId = 22869
}

function onThink(interval)
    local markers = db.storeQuery("SELECT x, y, z FROM `barn_markers`")
    if markers == false then return true end

    repeat
        local cx, cy, cz = result.getNumber(markers, "x"), result.getNumber(markers, "y"), result.getNumber(markers, "z")
        local tileCenter = Tile(Position(cx, cy, cz))
        
        if not tileCenter or not tileCenter:getItemById(BARN_CONFIG.markerId) then
            db.query(string.format("DELETE FROM `barn_markers` WHERE `x` = %d AND `y` = %d AND `z` = %d", cx, cy, cz))
        else
            db.query(string.format("DELETE FROM `barn_env` WHERE `marker_x` = %d AND `marker_y` = %d AND `marker_z` = %d", cx, cy, cz))
            db.query(string.format("DELETE FROM `barn_system` WHERE `pos_x` BETWEEN %d AND %d AND `pos_y` BETWEEN %d AND %d AND `pos_z` <= %d", cx-5, cx+5, cy-5, cy+5, cz))

            local envQueries = {}
            local monsterQueries = {}

            for z = cz, 1, -1 do
                for x = -BARN_CONFIG.radius, BARN_CONFIG.radius do
                    for y = -BARN_CONFIG.radius, BARN_CONFIG.radius do
                        local pos = Position(cx + x, cy + y, z)
                        local tile = Tile(pos)
                        if tile then
                            -- Coleta Itens e Ground
                            local ground = tile:getGround()
                            if ground then
                                table.insert(envQueries, string.format("(%d,%d,%d,%d,%d,%d,%d,%d)", cx, cy, cz, pos.x, pos.y, pos.z, ground:getId(), 1))
                            end

                            local items = tile:getItems()
                            if items then
                                for _, item in ipairs(items) do
                                    local id = item:getId()
                                    if id > 1 and item ~= ground then
                                        table.insert(envQueries, string.format("(%d,%d,%d,%d,%d,%d,%d,%d)", cx, cy, cz, pos.x, pos.y, pos.z, id, item:getCount()))
                                    end
                                end
                            end

                            -- Coleta Monstros
                            local creatures = tile:getCreatures()
                            if creatures then
                                for _, creature in ipairs(creatures) do
                                    if creature:isMonster() and not creature:getMaster() then
                                        local mid = creature:getId()
                                        local gen = _G.MonsterGenetics and _G.MonsterGenetics[mid]
                                        local gid = (getMonsterGender and getMonsterGender(mid)) or math.random(1, 2)
                                        local iv = gen and gen.ivs or {vida=0, ataque=0, defesa=0, vitalidade=0, velocidade=0, resistencia=0, exp=0}
                                        
                                        table.insert(monsterQueries, string.format("(%d,%d,%d,'%s',%d,%d,%d,%d,%d,%d,%d,%d,'%s',%d)", 
                                            pos.x, pos.y, pos.z, creature:getName(), (gen and gen.lvl or 1), iv.vida, iv.ataque, iv.velocidade, iv.defesa, iv.resistencia, iv.exp, iv.vitalidade, (gen and gen.rankName or "Comum"), gid))
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Executa tudo em blocos (Reduz de 2000 queries para apenas 2)
            if #envQueries > 0 then
                db.query("INSERT INTO `barn_env` VALUES " .. table.concat(envQueries, ","))
            end
            if #monsterQueries > 0 then
                db.query("INSERT INTO `barn_system` (`pos_x`,`pos_y`,`pos_z`,`monster_name`,`level`,`iv_health`,`iv_attack`,`iv_speed`,`iv_defense`,`iv_resistance`,`iv_exp`,`iv_vitality`,`monster_rank_name`,`gender`) VALUES " .. table.concat(monsterQueries, ","))
            end
        end
    until not result.next(markers)
    result.free(markers)
    return true
end