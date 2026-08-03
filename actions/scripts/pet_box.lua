function onUse(player, item)
    -- Garante que a lib foi carregated caso o erro persista
    if not player.getPetList then
        dofile("data/lib/pet_storage_lib.lua") 
    end

    local modal = ModalWindow(6000, "Pet Box", "Selecione um pet para trocar")
    local current = player:getPetType()
    
    if current > 0 then
        modal:addChoice(1, "[ATUAL] "..PETS.IDENTIFICATION[current].name..
            " | Lvl "..player:getPetLevel()..
            " | Rank "..player:getStorageValue(PETS.STORAGE.RANK))
    end

    local list = player:getPetList()
    for i, pet in ipairs(list) do
        local info = PETS.IDENTIFICATION[pet.type]
        local choiceIdx = (current > 0) and (i + 1) or i
        modal:addChoice(choiceIdx, 
            string.format("%s | Lvl %d | Rank %d | HP:%d ATK:%d", 
            info.name, pet.level, pet.rank, pet.ivs[1] or 0, pet.ivs[2] or 0))
    end

    modal:addButton(1, "Trocar")
    modal:addButton(2, "Sair")
    modal:sendToPlayer(player)
    return true
end