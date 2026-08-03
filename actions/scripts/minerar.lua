local config = {
    -- Pedras que dão loot/recompensa e viram Debris (ID 1336)
    rewardStones = {1285, 1356, 1357, 1358, 1359, 3608, 3615, 3607, 3609, 3616, 3666, 3667, 3668, 3670, 1295, 1290},
    
    -- Pedras que apenas transformam em outro ID (Sistema de Hits)
    transformStones = {
        [22119] = 1336,
        [22118] = 1336,
        [22122] = 1336,
        [22120] = 1336
    },

    -- Configuração da Pedra Especial (Garantida)
    specialStone = {
        id = 18683,
        rewardItem = 11339,
        rewardAmount = 2,
        msg = "Voce minerou lama!"
    },

    level = 0,
    skill = SKILL_CLUB,
    skillReq = 0,
    effect = CONST_ME_BLOCKHIT,
    addTries = 2,
    debris = 1336,
    msgType = MESSAGE_EVENT_ADVANCE,
    soul = 0,
    cooldownMs = 120 * 1000,
    breakChance = 10,
    storageBase = 70000000
}

local lootTable = {
    [{1, 100}] = {msg = "Um rato saiu de um buraco embaixo da pedra", summon = "Rat"},
    [{101, 200}] = {msg = "Voce encontrou X pedras.", item = 1293, amountmax = 5}, 
    [{301, 400}] = {msg = "Voce encontrou X piece(s) of iron.", item = 2225},
    [{801, 900}] = {msg = "Voce encontrou X iron ore(s).", item = 5880},
    [{901, 1000}] = {msg = "Voce ficou exausto e perdeu D de vida.", damage = {1, 30}},
   [{1301, 1400}] = {msg = "Uma Spider estava embaixo da pedra.", summon = "Spider"},
    [{1401, 1500}] = {msg = "Cuidado! Voce irritou um Scorpion.", summon = "Scorpion"},
    [{1501, 1600}] = {msg = "Uma Centipede estava dormindo entre as pedras.", summon = "Centipede"},
    [{1601, 1700}] = {msg = "Voce sofreu D de dano de um deslizamento.", damage = {1, 100}},
    [{1701, 1800}] = {msg = "Tinha uma Snake dormindo atras da pedra.", summon = "Snake"},
    [{1801, 1900}] = {msg = "Voce acertou o ninho de uma Tarantula.", summon = "Tarantula"},
    [{1901, 2000}] = {msg = "Sua picareta quebrou.", destroy = true}
}

local function stoneStorage(pos)
    return config.storageBase + pos.x * 100000 + pos.y * 100 + pos.z
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local isRewardStone = table.contains(config.rewardStones, target.itemid)
    local transformTo = config.transformStones[target.itemid]
    local isSpecialStone = (target.itemid == config.specialStone.id)

    if not isRewardStone and not transformTo and not isSpecialStone then
        return false
    end

    if player:getLevel() < config.level or player:getSkillLevel(config.skill) < config.skillReq or player:getSoul() < config.soul then
        player:sendCancelMessage("Voce nao tem os requisitos necessarios.")
        return true
    end

    local pos = target:getPosition()
    
    if target.itemid == config.debris then
        player:sendCancelMessage("A rocha ja esta quebrada. Aguarde ela se recuperar.")
        return true
    end

    if math.random(100) <= config.breakChance then
        item:remove(1)
        pos:sendMagicEffect(CONST_ME_POFF)
        player:sendTextMessage(config.msgType, "Sua ferramenta quebrou.")
        return true
    end

    -- Lógica imediata para a Pedra Especial
    if isSpecialStone then
        player:addItem(config.specialStone.rewardItem, config.specialStone.rewardAmount)
        player:sendTextMessage(config.msgType, config.specialStone.msg)
        target:transform(config.debris)
        pos:sendMagicEffect(config.effect)
        
        addEvent(function(p, id) 
            local t = Tile(p)
            local i = t and t:getItemById(id)
            if i then i:remove() end
        end, config.cooldownMs, pos, config.debris)
        
        return true
    end

    local storage = stoneStorage(pos)
    local hits = Game.getStorageValue(storage)
    if hits < 0 then hits = math.random(1, 5) end

    hits = hits - 1

    if hits <= 0 then
        if isRewardStone then
            local v = math.random(2000)
            local amount, damage = 1, 0
            for i, k in pairs(lootTable) do
                if v >= i[1] and v <= i[2] then
                    if k.destroy then item:remove(1) end
                    if k.summon then Game.createMonster(k.summon, pos) end
                    if k.damage then
                        damage = math.random(k.damage[1], k.damage[2])
                        player:addHealth(-damage)
                        player:getPosition():sendMagicEffect(CONST_ME_DRAWBLOOD)
                    end
                    if k.item then
                        amount = k.amountmax and math.random(k.amountmax) or 1
                        player:addItem(k.item, amount)
                    end
                    if k.msg then
                        local msg = k.msg:gsub("X", amount):gsub("D", tostring(damage))
                        player:sendTextMessage(config.msgType, msg)
                    end
                    break
                end
            end
            target:transform(config.debris)
            addEvent(function(p, id) 
                local t = Tile(p)
                local i = t and t:getItemById(id)
                if i then i:remove() end
            end, config.cooldownMs, pos, config.debris)
        
        elseif transformTo then
            target:transform(transformTo)
        end

        Game.setStorageValue(storage, -1)
        pos:sendMagicEffect(config.effect)
        player:addSoul(-config.soul)
        player:addSkillTries(config.skill, config.addTries)
    else
        Game.setStorageValue(storage, hits)
        pos:sendMagicEffect(CONST_ME_POFF)
    end

    return true
end