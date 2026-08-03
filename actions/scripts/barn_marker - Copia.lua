local BARN_CONFIG = {
    radius = 5,
    maxPets = 10
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local center = item:getPosition()
    
    -- Limpa para evitar duplicação no restart
    db.query(string.format("DELETE FROM `barn_system` WHERE `pos_x` = %d AND `pos_y` = %d AND `pos_z` = %d", center.x, center.y, center.z))

    local count = 0
    for x = -BARN_CONFIG.radius, BARN_CONFIG.radius do
        for y = -BARN_CONFIG.radius, BARN_CONFIG.radius do
            local pos = Position(center.x + x, center.y + y, center.z)
            local tile = Tile(pos)
            if tile then
                local creatures = tile:getCreatures()
                if creatures then
                    for _, creature in ipairs(creatures) do
                        if creature:isMonster() and not creature:getMaster() and count < BARN_CONFIG.maxPets then
                            local mid = creature:getId()
                            local gen = _G.MonsterGenetics and _G.MonsterGenetics[mid]
                            
                            -- Pega o gênero usando a sua função do onlook
                            local gid = 0
                            if getMonsterGender then
                                gid = getMonsterGender(mid)
                            end
                            
                            -- Se ainda for 0 (monstro novo), força 1 ou 2 como seu onlook faz
                            if gid == 0 then
                                gid = math.random(1, 2)
                                if setMonsterGender then setMonsterGender(mid, gid) end
                            end

                            local name = db.escapeString(creature:getName())
                            local rName = gen and gen.rankName or "Comum"
                            local lvl = gen and gen.lvl or 1
                            local iv = gen and gen.ivs or {vida=0, ataque=0, defesa=0, vitalidade=0, velocidade=0, resistencia=0, exp=0}

                            local query = string.format("INSERT INTO `barn_system` (`pos_x`, `pos_y`, `pos_z`, `monster_name`, `level`, `iv_health`, `iv_attack`, `iv_speed`, `iv_defense`, `iv_resistance`, `iv_exp`, `iv_vitality`, `monster_rank_name`, `gender`) VALUES (%d, %d, %d, %s, %d, %d, %d, %d, %d, %d, %d, %d, '%s', %d)", 
                                center.x, center.y, center.z, name, lvl, iv.vida, iv.ataque, iv.velocidade, iv.defesa, iv.resistencia, iv.exp, iv.vitalidade, rName, gid)
                            
                            db.query(query)
                            pos:sendMagicEffect(CONST_ME_MAGIC_GREEN)
                            count = count + 1
                        end
                    end
                end
            end
        end
    end
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Celeiro: " .. count .. " animais salvos.")
    return true
end