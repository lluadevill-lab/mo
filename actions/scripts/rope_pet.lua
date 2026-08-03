local function getPetNumberByName(name)
    if not name then return nil end
    for number, info in ipairs(PETS.IDENTIFICATION) do
        if info.name and info.name:lower() == name:lower() then
            return number
        end
    end
    return nil
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not target or not target:isMonster() or target:getMaster() then
        player:say("Apenas animais selvagens podem virar pet.", TALKTYPE_MONSTER_SAY)
        return true
    end

    local targetName = target:getName() -- SALVA O NOME ANTES DE REMOVER
    local petNumber = getPetNumberByName(targetName)
    
    if not petNumber or not player:canGetPet(petNumber) then
        player:say("Impossivel domar este animal.", TALKTYPE_MONSTER_SAY)
        return true
    end

    if math.random(100) > math.ceil((1 - target:getHealth() / target:getMaxHealth()) * 100) then
        player:say("Quase! Tente de novo.", TALKTYPE_MONSTER_SAY)
        return true
    end

    if player.saveCurrentPet then player:saveCurrentPet() end

    local gen = _G.MonsterGenetics and _G.MonsterGenetics[target:getId()]
    player:doAddPet(petNumber, true)
    
    local storages = {10006, 10007, 10008, 10009, 10010, 10011, 10012}
    local rankMap = {["Comum"]=1, ["Incomum"]=2, ["Raro"]=3, ["Elite"]=4, ["Lendario"]=5}

    if gen and gen.ivs then
        player:setPetLevel(gen.lvl or 1)
        player:setStorageValue(10013, rankMap[gen.rankName] or 1)
        player:setStorageValue(storages[1], gen.ivs.vida or 0)
        player:setStorageValue(storages[2], gen.ivs.ataque or 0)
        player:setStorageValue(storages[3], gen.ivs.velocidade or 0)
        player:setStorageValue(storages[4], gen.ivs.defesa or 0)
        player:setStorageValue(storages[5], gen.ivs.resistencia or 0)
        player:setStorageValue(storages[6], gen.ivs.exp or 0)
        player:setStorageValue(storages[7], gen.ivs.vitalidade or 0)
    end

    target:getPosition():sendMagicEffect(CONST_ME_POFF)
    target:remove() -- AGORA O NOME JÁ ESTÁ SALVO NA VARIÁVEL
    item:remove(1)
    player:say("Domou um " .. targetName:lower() .. "!", TALKTYPE_MONSTER_SAY)
    return true
end