-- data/lib/house_builder.lua

HOUSE_BUILDER = {}

-- Lista de IDs de Parede do sistema + IDs comuns (adaptar conforme seu mapa)
HOUSE_BUILDER.WALL_IDS = {
    [1023] = true, [10250] = true, [10249] = true, 
    [10253] = true, [10251] = true,
    [1007] = true, 
    [1022] = true,
}

HOUSE_BUILDER.CATEGORIES = {
    ["Paredes"] = {
        {id = 1023, name = "Madeira Horiz.", cost = { {5901, 5} }},
        {id = 1023, name = "Madeira Vert.", cost = { {5901, 5} }},
        {id = 1023, name = "Madeira Canto Direito.", cost = { {5901, 5} }},
        {id = 1023, name = "Coluna de Madeira", cost = { {5901, 5} }},

        {id = 10250, name = "Pedra Horiz.", cost = { {1293, 2} }},
        {id = 10249, name = "Pedra Vert.", cost = { {1293, 2} }},
        {id = 10253, name = "Pedra Canto Direito.", cost = { {1293, 2} }},
        {id = 10251, name = "Coluna de Pedra", cost = { {1293, 2} }},
    },

    ["Pisos"] = {
        {id = 3139, name = "Piso de Madeira", cost = { {5901, 2} }},
        {id = 19785, name = "Piso de Pedra", cost = { {1293, 2} }},
    },

    ["Portas"] = {
        {id = 1623, name = "Porta de Madeira", cost = { {5901, 10} }},
        {id = 6252, name = "Pedra Horiz.", cost = { {1293, 2} }},
        {id = 6249, name = "Pedra Vert.", cost = { {1293, 2} }},

    },

    ["Essenciais"] = {
        {id = 22868, name = "Marcador de casa/celeiro", cost = { {5901, 20} }},

    },

    ["Decoracao"] = {
        {id = 3945, name = "Tocha parede Vert.", cost = { {2148, 50} }},
        {id = 5614, name = "Bandeira Pirata Horiz.", cost = { {2148, 50} }},
        {id = 1736, name = "Espelho", cost = { {2148, 100} }},
    }
}

HOUSE_BUILDER.CATEGORY_LIST = {}
for category, _ in pairs(HOUSE_BUILDER.CATEGORIES) do
    table.insert(HOUSE_BUILDER.CATEGORY_LIST, category)
end

HOUSE_BUILDER.ITEM_TO_ENTRY = {}
HOUSE_BUILDER.ITEM_TO_CATEGORY = {}
for category, list in pairs(HOUSE_BUILDER.CATEGORIES) do
    for _, entry in ipairs(list) do
        if not HOUSE_BUILDER.ITEM_TO_ENTRY[entry.id] then
             HOUSE_BUILDER.ITEM_TO_ENTRY[entry.id] = entry
             HOUSE_BUILDER.ITEM_TO_CATEGORY[entry.id] = category
        end
        if not HOUSE_BUILDER.ITEM_TO_CATEGORY[entry.id] then
            HOUSE_BUILDER.ITEM_TO_CATEGORY[entry.id] = category
        end
    end
end

function HOUSE_BUILDER.getFrontPosition(player)
    local dir = player:getDirection()
    local pos = player:getPosition()

    if dir == NORTH then pos.y = pos.y - 1
    elseif dir == SOUTH then pos.y = pos.y + 1
    elseif dir == EAST then pos.x = pos.x + 1
    elseif dir == WEST then pos.x = pos.x - 1 end
    
    return pos
end 

function HOUSE_BUILDER.showMainWindow(player)
    local mw = ModalWindow(9000, "Construcao", "Escolha um item ou categoria:")

    local choiceIdCounter = 1

    local quickBuiltItems = {}
    local quickBuiltString = player:getStorageValue(99002)
    if type(quickBuiltString) == "string" and quickBuiltString ~= "" then
        for itemID in string.gmatch(quickBuiltString, "([^,]+)") do
            table.insert(quickBuiltItems, tonumber(itemID))
        end
    end

    mw:addChoice(choiceIdCounter, "[DESTRUIR] Desconstruir Item a Frente")
    choiceIdCounter = choiceIdCounter + 1
    
    if #quickBuiltItems > 0 then
        mw:addChoice(choiceIdCounter, "-- Ultimos Construidos --")
        choiceIdCounter = choiceIdCounter + 1

        for _, itemID in ipairs(quickBuiltItems) do
            local categoryName = HOUSE_BUILDER.ITEM_TO_CATEGORY[itemID]
            
            if categoryName then
                local itemType = ItemType(itemID)
                local itemName = itemType and itemType:getName() or "Item Desconhecido"
                local itemText = itemName .. " (" .. categoryName .. ")"
                mw:addChoice(choiceIdCounter, itemText) 
                choiceIdCounter = choiceIdCounter + 1
            end
        end
        
        mw:addChoice(choiceIdCounter, "-- Categorias --")
        choiceIdCounter = choiceIdCounter + 1
    end
    
    local quickBuildOffset = choiceIdCounter - 1
    
    player:setStorageValue(99003, quickBuildOffset) 

    for _, category in ipairs(HOUSE_BUILDER.CATEGORY_LIST) do
        mw:addChoice(choiceIdCounter, category)
        choiceIdCounter = choiceIdCounter + 1
    end

    mw:addButton(1, "Confirmar Selecao") 
    mw:setDefaultEnterButton(1)
    mw:setDefaultEscapeButton(0)

    player:registerEvent("HouseModal")
    mw:sendToPlayer(player)
end

function HOUSE_BUILDER.showItemWindow(player, category)
    local mw = ModalWindow(9001, category, "Escolha o item para construir")

    for choiceId, entry in ipairs(HOUSE_BUILDER.CATEGORIES[category]) do
        local costText = ""
        for _, req in ipairs(entry.cost) do
            local itemType = ItemType(req[1])
            local itemName = itemType and itemType:getName() or "Item Desconhecido"
            
            costText = costText .. itemName .. " x" .. req[2] .. ", "
        end
        
        if costText ~= "" then
            costText = string.sub(costText, 1, -3)
        end

        local itemText = entry.name .. " (Custo: " .. costText .. ")"
        mw:addChoice(choiceId, itemText)
    end
    
    mw:addButton(1, "Construir")
    mw:addButton(2, "Voltar")
    mw:setDefaultEnterButton(1)
    
    player:registerEvent("HouseModal")
    mw:sendToPlayer(player)
end

function HOUSE_BUILDER.build(player, entry)
    local pos = HOUSE_BUILDER.getFrontPosition(player)

    local tile = Tile(pos)
    if not tile then
        player:sendCancelMessage("Nao e possivel construir neste local.")
        return
    end

    local itemType = ItemType(entry.id)
    if not itemType then
        player:sendCancelMessage("Erro: Tipo de item de construcao invalido.")
        return
    end

    local canBuild = true
    if tile:getGround() and tile:getGround().uid == 0 and itemType:getGroup() == ITEM_GROUP_GROUND then
        canBuild = false
    end

    local isWallDecoration = (HOUSE_BUILDER.ITEM_TO_CATEGORY[entry.id] == "Decoracao")

    if tile:getItemCount() > 0 then
        if isWallDecoration then
            local hasWall = false
            for i = 0, tile:getItemCount() - 1 do
                -- CORREÇÃO: Usando tile:getTopItem(i)
                local existingItem = tile:getTopItem(i) 
                
                if existingItem and (HOUSE_BUILDER.WALL_IDS[existingItem.itemid] or existingItem:isWall()) then
                    hasWall = true
                    break
                end
            end
            
            if not hasWall then
                player:sendCancelMessage("Voce precisa de uma parede para construir este item.")
                return
            end
        else 
            local hasBlockingItem = false
            for i = 0, tile:getItemCount() - 1 do
                -- CORREÇÃO: Usando tile:getTopItem(i)
                local existingItem = tile:getTopItem(i) 
                
                if existingItem and existingItem:isWall() == false and existingItem:isContainer() == false and existingItem:isLiquidPool() == false and existingItem:isMoveable() == true then
                    hasBlockingItem = true
                    break
                end
            end
            
            if hasBlockingItem and entry.id ~= 1023 and entry.id ~= 1024 then
                 canBuild = false
            end
        end
    end

    if not canBuild then
         player:sendCancelMessage("Ja existe algo que impede a construcao neste local.")
         return
    end

    -- verificar materiais
    for _, req in ipairs(entry.cost) do
        if player:getItemCount(req[1]) < req[2] then
            local requiredItemType = ItemType(req[1])
            local requiredItemName = requiredItemType and requiredItemType:getName() or "Item Desconhecido"
            player:sendCancelMessage("Faltam materiais: " .. requiredItemName .. " x" .. req[2] .. ".")
            return
        end
    end

    -- remover materiais
    for _, req in ipairs(entry.cost) do
        player:removeItem(req[1], req[2])
    end

    -- criar item
    Game.createItem(entry.id, 1, pos)
    pos:sendMagicEffect(CONST_ME_GROUNDSHAKER)

    -- QUICK BUILD: Salvar ultimo item construido (Storage 99002)
    local lastBuiltString = player:getStorageValue(99002)
    local lastBuilt = {}
    if type(lastBuiltString) == "string" and lastBuiltString ~= "" then
        for itemID in string.gmatch(lastBuiltString, "([^,]+)") do
            table.insert(lastBuilt, tonumber(itemID))
        end
    end
    
    local exists = false
    for i, id in ipairs(lastBuilt) do
        if id == entry.id then
            table.remove(lastBuilt, i)
            break
        end
    end
    table.insert(lastBuilt, 1, entry.id)
    
    while #lastBuilt > 3 do
        table.remove(lastBuilt, #lastBuilt)
    end
    
    player:setStorageValue(99002, table.concat(lastBuilt, ","))

    player:sendTextMessage(MESSAGE_INFO_DESCR, "Construido: " .. entry.name)
end

function HOUSE_BUILDER.deconstruct(player)
    local pos = HOUSE_BUILDER.getFrontPosition(player)
    local tile = Tile(pos)

    if not tile then
        player:sendCancelMessage("Nao ha nada para desconstruir aqui.")
        return
    end

    local itemToDeconstruct = nil
    
    for i = tile:getItemCount() - 1, 0, -1 do
        -- CORREÇÃO: Usando tile:getTopItem(i)
        local item = tile:getTopItem(i)
        
        if item and HOUSE_BUILDER.ITEM_TO_ENTRY[item.itemid] then
            itemToDeconstruct = item
            break
        end
    end

    -- Se não encontrou no stack, verifica o item de chão (pode ser piso)
    if not itemToDeconstruct then
        local groundItem = tile:getGround()
        if groundItem and HOUSE_BUILDER.ITEM_TO_ENTRY[groundItem.itemid] then
            itemToDeconstruct = groundItem
        end
    end

    if not itemToDeconstruct then
        player:sendCancelMessage("O item a sua frente nao e um item de construcao valido para desconstruir.")
        return
    end
    
    local entry = HOUSE_BUILDER.ITEM_TO_ENTRY[itemToDeconstruct.itemid]
    
    if not entry then
        player:sendCancelMessage("Erro: Nao foi possivel carregar a receita do item. Nao pode ser desconstruido.")
        return
    end

    local returnedItems = {}
    local totalReturned = 0
    local freeCapacity = player:getCapacity() - player:getUsedCapacity()
    
    for _, req in ipairs(entry.cost) do
        local requiredID, requiredCount = req[1], req[2]
        local itemType = ItemType(requiredID)
        local itemWeight = itemType and itemType:getWeight() or 0
        local returnCount = math.ceil(requiredCount / 2)
        
        if returnCount > 0 then
            local requiredWeight = itemWeight * returnCount
            
            if requiredWeight > freeCapacity then
                returnCount = math.floor(freeCapacity / itemWeight)
                freeCapacity = 0
            else
                freeCapacity = freeCapacity - requiredWeight
            end

            local itemName = itemType and itemType:getName() or "Item Desconhecido"
            
            if returnCount > 0 then
                player:addItem(requiredID, returnCount) 
                table.insert(returnedItems, itemName .. " x" .. returnCount)
                totalReturned = totalReturned + returnCount
            end
        end
    end

    if totalReturned == 0 then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Desconstruido: " .. entry.name .. ". Nenhum material foi recuperado.")
    else
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Desconstruido: " .. entry.name .. ". Materiais recuperados: " .. table.concat(returnedItems, ", ") .. ".")
    end

    itemToDeconstruct:remove()
    pos:sendMagicEffect(CONST_ME_POFF)
    
    return true
end