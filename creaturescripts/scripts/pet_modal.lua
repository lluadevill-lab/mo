function onModalWindow(player, modalId, buttonId, choiceId)
   -- Impede execução se modal errada ou botão incorreto
    if modalId ~= 6000 or buttonId ~= 1 then
        return true
    end

    local uid = player:getPetUid()
    local pet = Creature(uid)

    -- Corrige detecção de pet spawnado
    if uid > 0 and pet and pet:isCreature() then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Recolha seu pet antes de trocar.")
        player:petSystemMessage("petUid=" .. uid .. " ainda ativo, recolha-o primeiro.")
        return true
    end

    local current = player:getPetType()
    local list = player:getPetList()
    local index = (current > 0) and (choiceId - 1) or choiceId

    if current > 0 and choiceId == 1 then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Este pet ja esta ativo.")
        return true
    end

    if not list[index] then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Pet invalido ou inexistente.")
        return true
    end

    local ok = player:swapPetByIndex(index)
    if ok then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Troca efetuada com sucesso! Seu novo pet esta pronto.")
        player:petSystemMessage("Pet ativo: " .. PETS.IDENTIFICATION[player:getPetType()].name)
    else
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Erro ao trocar pet.")
        player:petSystemMessage("Falha na funcao swapPetByIndex().")
    end
    return true
end
