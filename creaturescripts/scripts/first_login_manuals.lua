local STORAGE_FIRST_LOGIN = 96096
local ITEMS = {13831, 13632, 10006, 2347, 24976, 9690, 24776, 1685}

function onLogin(player)
    local inbox = player:getSlotItem(CONST_SLOT_STORE_INBOX)
    if not inbox then
        return true
    end

    local needsUpdate = false
    local itemsInInbox = {}
    
    -- Mapeia itens presentes na inbox
    local size = inbox:getSize()
    if size > 0 then
        for i = 0, size - 1 do
            local item = inbox:getItem(i)
            if item then
                itemsInInbox[item:getId()] = true
            end
        end
    end

    -- Verifica se falta algum item da lista
    for _, itemId in ipairs(ITEMS) do
        if not itemsInInbox[itemId] then
            needsUpdate = true
            break
        end
    end

    if needsUpdate then
        -- Remove todos os itens da lista que estiverem na inbox para resetar a ordem
        if size > 0 then
            for i = size - 1, 0, -1 do
                local item = inbox:getItem(i)
                if item then
                    for _, targetId in ipairs(ITEMS) do
                        if item:getId() == targetId then
                            item:remove()
                            break
                        end
                    end
                end
            end
        end

        -- Adiciona novamente na ordem exata
        for _, itemId in ipairs(ITEMS) do
            inbox:addItem(itemId, 1)
        end
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Manuais atualizados na store inbox.")
    end

    return true
end