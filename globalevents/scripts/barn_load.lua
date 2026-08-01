function onStartup()
    addEvent(function()
        -- 1. CARREGAR ITENS E PISOS
        local itemsResult = db.storeQuery("SELECT * FROM `barn_env` ORDER BY `itemid` ASC")
        if itemsResult ~= false then
            repeat
                local pos = Position(result.getNumber(itemsResult, "pos_x"), result.getNumber(itemsResult, "pos_y"), result.getNumber(itemsResult, "pos_z"))
                local itemid = result.getNumber(itemsResult, "itemid")
                local count = result.getNumber(itemsResult, "count")
                local tile = Tile(pos)
                if tile then
                    local ground = tile:getGround()
                    local itType = ItemType(itemid)
                    if itType:isGroundTile() then
                        if ground and ground:getId() ~= itemid then ground:transform(itemid) end
                    else
                        if not tile:getItemById(itemid) then Game.createItem(itemid, count, pos) end
                    end
                end
            until not result.next(itemsResult)
            result.free(itemsResult)
        end

        -- 2. CARREGAR MONSTROS RECALCULANDO VIDA PELO SEU SISTEMA
        local monstersResult = db.storeQuery("SELECT * FROM `barn_system`")
        if monstersResult ~= false then
            if not _G.MonsterGenetics then _G.MonsterGenetics = {} end
            
            -- Tabela de consulta rápida para os multiplicadores de qualidade
            local qualityMults = {
                ["Comum"] = 1.0, ["Incomum"] = 1.5, ["Raro"] = 2.5, ["Elite"] = 3.5, ["Lendario"] = 6.0
            }

            repeat
                local name = result.getString(monstersResult, "monster_name")
                local pos = Position(result.getNumber(monstersResult, "pos_x"), result.getNumber(monstersResult, "pos_y"), result.getNumber(monstersResult, "pos_z"))
                
                local monster = Game.createMonster(name, pos, true, true)
                if monster then
                    local mid = monster:getId()
                    local rName = result.getString(monstersResult, "monster_rank_name")
                    local lvl = result.getNumber(monstersResult, "level")
                    
                    local ivs = {
                        vida = result.getNumber(monstersResult, "iv_health"), 
                        ataque = result.getNumber(monstersResult, "iv_attack"),
                        defesa = result.getNumber(monstersResult, "iv_defense"), 
                        vitalidade = result.getNumber(monstersResult, "iv_vitality"),
                        velocidade = result.getNumber(monstersResult, "iv_speed"), 
                        resistencia = result.getNumber(monstersResult, "iv_resistance"),
                        exp = result.getNumber(monstersResult, "iv_exp")
                    }

                    -- Injeta na global ANTES de calcular
                    _G.MonsterGenetics[mid] = {
                        lvl = lvl,
                        rankName = rName,
                        xpMult = 1.0, -- Valor temporário
                        ivs = ivs
                    }

                    -- REPRODUZ EXATAMENTE O SEU CALCULO DE VIDA
                    local baseMult = qualityMults[rName] or 1.0
                    local hpMult = baseMult + (lvl * 0.03) + (ivs.vida / 100)
                    local newMaxHP = math.floor(monster:getMaxHealth() * hpMult)
                    
                    monster:setMaxHealth(newMaxHP)
                    monster:addHealth(newMaxHP)
                    monster:changeSpeed(ivs.velocidade * 2)

                    if setMonsterGender then 
                        setMonsterGender(mid, result.getNumber(monstersResult, "gender")) 
                    end
                end
            until not result.next(monstersResult)
            result.free(monstersResult)
        end
    end, 1000)
    return true
end