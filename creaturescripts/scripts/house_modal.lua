function onModalWindow(player, modalId, buttonId, choiceId)
    if modalId == 9000 then -- Selecao de Categoria/Quick Build/Desconstruir (Main Window)
        if buttonId == 0 then return true end

        if buttonId == 1 then -- Botao "Confirmar Selecao"
            if choiceId == 0 then 
                player:sendCancelMessage("Selecione uma opcao primeiro.")
                return true
            end
            
            -- Opcao Desconstruir (ID 1)
            if choiceId == 1 then
                HOUSE_BUILDER.deconstruct(player)
                return true
            end

            local quickBuildOffset = player:getStorageValue(99003) or 0
            
            -- Opcao de Quick Build ou Titulo
            if choiceId <= quickBuildOffset then
                local quickBuiltString = player:getStorageValue(99002) or ""
                local quickBuiltItems = {}
                if type(quickBuiltString) == "string" and quickBuiltString ~= "" then
                    for itemID in string.gmatch(quickBuiltString, "([^,]+)") do
                        table.insert(quickBuiltItems, tonumber(itemID))
                    end
                end
                
                -- O Choice ID 1 agora é o Desconstruir. Os titulos e itens Quick Build começam do ID 2.
                -- Se o choiceId estiver entre 2 e quickBuildOffset-1, é um item Quick Build válido.
                if choiceId > 1 and choiceId < quickBuildOffset then
                    -- Index no array quickBuiltItems: choiceId - 2 (pula Desconstruir e Titulo)
                    local itemIndex = choiceId - 2
                    local itemID = quickBuiltItems[itemIndex]
                    
                    local category = HOUSE_BUILDER.ITEM_TO_CATEGORY[itemID]
                    if category then
                        local list = HOUSE_BUILDER.CATEGORIES[category]
                        for _, entry in ipairs(list) do
                            if entry.id == itemID then
                                HOUSE_BUILDER.build(player, entry) -- Constrói diretamente
                                return true
                            end
                        end
                    end
                end
                
                -- Se o choice for um dos titulos, ou for um item invalido, retorna
                player:sendCancelMessage("Selecao de Quick Build invalida ou titulo.")
                return true
            end
            
            -- Opcao de Categoria Principal
            -- O offset agora precisa ser ajustado corretamente, pois o ID 1 é Desconstruir.
            local categoryIndex = choiceId - quickBuildOffset
            local category = HOUSE_BUILDER.CATEGORY_LIST[categoryIndex]
            
            if category then
                player:setStorageValue(99000, category) -- Armazena a STRING da categoria
                player:setStorageValue(99001, categoryIndex) -- Storage auxiliar
                HOUSE_BUILDER.showItemWindow(player, category)
            end
            return true
        end

    elseif modalId == 9001 then -- Selecao de Item (Item Window)
        if buttonId == 2 then -- Botao "Voltar"
            HOUSE_BUILDER.showMainWindow(player)
            return true
        end

        if buttonId ~= 1 then return true end -- Botao "Construir" ou Fechar/Cancelar

        -- Lemos o valor da storage 99000.
        local storedValue = player:getStorageValue(99000)
        local category = nil
        
        if type(storedValue) == "string" and storedValue ~= "" then
            category = storedValue
        end
        
        -- Fallback: Tenta usar a storage 99001 se 99000 falhou
        if not category then
            local categoryIndex = player:getStorageValue(99001)
            if categoryIndex > 0 then
                 category = HOUSE_BUILDER.CATEGORY_LIST[categoryIndex]
            end
        end

        -- Se a categoria for nil (ou seja, nao foi lida corretamente)
        if not category or type(category) ~= "string" then
             player:sendCancelMessage("Erro: Categoria nao selecionada ou invalida.")
             HOUSE_BUILDER.showMainWindow(player)
             return true
        end
        
        local list = HOUSE_BUILDER.CATEGORIES[category]
        if not list then 
             player:sendCancelMessage("Erro ao carregar lista de itens. Voltando ao menu principal.")
             HOUSE_BUILDER.showMainWindow(player)
             return true 
        end
        
        local entry = list[choiceId]
        if not entry then return true end

        HOUSE_BUILDER.build(player, entry)
        return true
    end

    return true
end