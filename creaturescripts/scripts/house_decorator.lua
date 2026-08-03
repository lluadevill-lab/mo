local OPCODE_DECORATOR = 57
local STORAGE_BASE = 100000
local ITEMS_PER_PAGE = 8 

-- id  = Server ID (O item que é criado no chão)
-- img = Client ID (A imagem que aparece na interface)

local CATALOG = {
    { name = "Paredes", items = {
{ id = 5261, img = 5260, name = "Parede Madeira", price = 100 },
{ id = 5262, img = 5261, name = "Parede Madeira", price = 100 },
{ id = 5263, img = 5262, name = "Parede Madeira", price = 100 },
{ id = 5265, img = 5264, name = "Parede Madeira", price = 100 },

{ id = 1025, img = 1270, name = "Parede Tijolo", price = 150 },
{ id = 1026, img = 1271, name = "Parede Tijolo", price = 150 },
{ id = 1027, img = 1272, name = "Parede Tijolo", price = 150 },
{ id = 1029, img = 1274, name = "Parede Tijolo", price = 150 },

{ id = 19494, img = 17214, name = "Parede Tijolo Claro", price = 200 },
{ id = 19496, img = 17216, name = "Parede Tijolo Claro", price = 200 },
{ id = 19378, img = 17098, name = "Parede Tijolo Claro", price = 200 },
{ id = 19502, img = 17222, name = "Parede Tijolo Claro", price = 200 },

{ id = 19376, img = 17096, name = "Parede Pedra Clara", price = 200 },
{ id = 19377, img = 17097, name = "Parede Pedra Clara", price = 200 },
{ id = 19378, img = 17098, name = "Parede Pedra Clara", price = 200 },
{ id = 19414, img = 17134, name = "Parede Pedra Clara", price = 200 },
    }},
    { name = "Portas e Janelas", items = {
{ id = 5284, img = 5283, name = "Porta Madeira", price = 100 },
{ id = 5286, img = 5285, name = "Porta Madeira", price = 100 },
{ id = 6473, img = 6472, name = "Janela Madeira", price = 100 },
{ id = 6472, img = 6471, name = "Janela Madeira", price = 100 },

{ id = 5107, img = 5106, name = "Porta Tijolo", price = 150 },
{ id = 5098, img = 5097, name = "Parede Tijolo", price = 150 },
{ id = 6443, img = 6442, name = "Janela Tijolo", price = 150 },
{ id = 6442, img = 6441, name = "Janela Tijolo", price = 150 },

{ id = 19990, img = 17710, name = "Porta Tijolo Claro", price = 200 },
{ id = 19983, img = 17703, name = "Porta Tijolo Claro", price = 200 },
{ id = 19808, img = 17528, name = "Janela Tijolo Claro", price = 200 },
{ id = 19809, img = 17529, name = "Janela Tijolo Claro", price = 200 },

{ id = 19850, img = 17570, name = "Porta Pedra Clara", price = 200 },
{ id = 19841, img = 17561, name = "Porta Pedra Clara", price = 200 },
{ id = 20183, img = 17903, name = "Janela Pedra Clara", price = 200 },
{ id = 20180, img = 17900, name = "Janela Pedra Clara", price = 200 },
    }},
    { name = "Pisos", items = {
        { id = 405, img = 408, name = "Piso de Madeira", price = 50 },
        { id = 9225, img = 8309, name = "Piso de Madeira Escura", price = 50 },
        { id = 458, img = 464, name = "Piso de Madeira Clara", price = 50 },
        { id = 18864, img = 16584, name = "Piso de Madeira Vermelha", price = 50 },
        { id = 22164, img = 19830, name = "Piso de Seixo", price = 100 },
        { id = 414, img = 417, name = "Piso de Mosaico", price = 100 },
        { id = 19825, img = 17545, name = "Piso de Ladrilhos", price = 500 },
        { id = 11947, img = 10991, name = "Piso de Marmore Azul", price = 500 },
    }},
    { name = "Moveis", items = {
        { id = 1614, img = 2314, name = "Mesa de Madeira", price = 300 },
        { id = 12789, img = 11802, name = "Cadeira de Madeira", price = 300 },
        { id = 19637, img = 17357, name = "Cabeceira de Madeira", price = 300 },
        { id = 19635, img = 17355, name = "Roupeiro de Madeira", price = 300 },
        { id = 12799, img = 11812, name = "Armario de Madeira", price = 300 },
        { id = 20239, img = 17959, name = "Relogio de Madeira", price = 300 },
        { id = 12796, img = 11809, name = "Bau de Madeira", price = 300 },
        { id = 20151, img = 17871, name = "Estante de Livros", price = 300 },
        
        { id = 1614, img = 2314, name = "Mesa", price = 300 },
        { id = 2095, img = 2095, name = "Birdcage", price = 500 },
        { id = 2099, img = 2099, name = "Globe", price = 600 },
        { id = 1878, img = 1878, name = "Cuckoo Clock", price = 800 },
        { id = 2109, img = 2109, name = "Model Ship", price = 500 },
        { id = 2558, img = 2558, name = "Telescope", price = 800 },
        { id = 2114, img = 2114, name = "Piggy Bank", price = 300 },
        { id = 5666, img = 5666, name = "Message in a Bottle", price = 200 },
        { id = 26076, img = 26076, name = "Bath Tub", price = 5000 },
        { id = 23697, img = 23697, name = "Dog House", price = 2000 },
        { id = 28945, img = 28945, name = "Chest of Abundance", price = 3000 },
        { id = 27679, img = 27679, name = "Alchemistic Bookstand", price = 1500 },
        { id = 27683, img = 27683, name = "Alchemistic Scales", price = 1000 },
        { id = 25720, img = 25720, name = "Reward Shrine", price = 10000 },
    }},
    { name = "Efeite de Parede", items = {
        { id = 13691, img = 12434, name = "Tocha", price = 200 },
        { id = 13688, img = 12431, name = "Tocha", price = 200 },
        { id = 15132, img = 13662, name = "Tocha Viva", price = 200 },
        { id = 15130, img = 13660, name = "Tocha Viva", price = 200 },
        { id = 9841, img = 8927, name = "Lampiao Eletrico", price = 200 },
        { id = 9839, img = 8925, name = "Lampiao Eletrico", price = 200 },
        { id = 9605, img = 8689, name = "Espelho de Parede", price = 200 },
        { id = 9583, img = 8667, name = "Espelho de Parede", price = 200 },
    }},
{ name = "Tapecarias", items = {
{ id = 1867, img = 2647, name = "Green Tapestry", price = 400 },
{ id = 1870, img = 2650, name = "Yellow Tapestry", price = 400 },
{ id = 1873, img = 2653, name = "Orange Tapestry", price = 400 },
{ id = 1876, img = 2656, name = "Red Tapestry", price = 400 },
{ id = 1879, img = 2659, name = "Blue Tapestry", price = 400 },
{ id = 1864, img = 2644, name = "Purple Tapestry", price = 400 },
{ id = 1887, img = 2667, name = "White Tapestry", price = 400 },
{ id = 5615, img = 5615, name = "Pirate Tapestry", price = 800 },
{ id = 9045, img = 9045, name = "Royal Tapestry", price = 1500 },
{ id = 9046, img = 9046, name = "Silky Tapestry", price = 1500 },
{ id = 8923, img = 8923, name = "Velvet Tapestry", price = 1500 },
{ id = 10347, img = 10347, name = "Dragon Tapestry", price = 2500 },
{ id = 20278, img = 20278, name = "Demonic Tapestry", price = 2500 },
{ id = 22731, img = 22731, name = "Rift Tapestry", price = 3000 },
{ id = 23723, img = 23723, name = "Golden Dragon Tapestry", price = 3000 },
{ id = 23724, img = 23724, name = "Sword Tapestry", price = 1500 },
{ id = 23725, img = 23725, name = "Brocade Tapestry", price = 1500 },
{ id = 23450, img = 23450, name = "All-Seeing Tapestry", price = 2500 },
{ id = 23449, img = 23449, name = "Menacing Tapestry", price = 2500 },
{ id = 23448, img = 23448, name = "Lordly Tapestry", price = 2500 },
{ id = 20350, img = 20350, name = "Cake Tapestry", price = 1000 },
{ id = 20315, img = 20315, name = "Snow Flake Tapestry", price = 1000 },
{ id = 20277, img = 20277, name = "Psychedelic Tapestry", price = 1500 },
{ id = 14675, img = 14675, name = "Tapestry of Honour", price = 2000 },
{ id = 12482, img = 12482, name = "Hieroglyph Banner", price = 1200 },
{ id = 12483, img = 12483, name = "Pharaoh Banner", price = 1200 },
    }},
{ name = "Natureza", items = {
{ id = 2271, img = 2986, name = "Christmas Tree", price = 1000 },
{ id = 6488, img = 6488, name = "Christmas Branch", price = 200 },
{ id = 6501, img = 6501, name = "Christmas Wreath", price = 400 },
{ id = 6502, img = 6502, name = "Christmas Garland", price = 400 },
{ id = 25216, img = 25216, name = "Blooming Cactus", price = 300 },
{ id = 25217, img = 25217, name = "Bitter-Smack Leaf", price = 300 },
{ id = 25218, img = 25218, name = "Pink Roses", price = 400 },
{ id = 25219, img = 25219, name = "Red Roses", price = 400 },
{ id = 25220, img = 25220, name = "Yellow Roses", price = 400 },
{ id = 28688, img = 28688, name = "Carnivorous Plant", price = 800 },
{ id = 28697, img = 28697, name = "Bellflower", price = 200 },
{ id = 28698, img = 28698, name = "Forget-Me-Not", price = 200 },
{ id = 28699, img = 28699, name = "Red Geranium", price = 200 },
}},
{ name = "Criaturas", items = {
{ id = 26173, img = 26173, name = "Demon Doll", price = 5000 },
{ id = 23442, img = 23442, name = "Baby Dragon", price = 3000 },
{ id = 28690, img = 28690, name = "Baby Rotworm", price = 2000 },
{ id = 28694, img = 28694, name = "Fennec", price = 2500 },
{ id = 12246, img = 12246, name = "Verocious Bat", price = 1500 },
{ id = 23451, img = 23451, name = "Cat in a Basket", price = 1200 },
{ id = 24432, img = 24432, name = "Parrot", price = 1500 },
{ id = 26078, img = 26078, name = "Spider in Terrarium", price = 800 },
{ id = 28928, img = 28928, name = "Stuffed Bear Display", price = 2000 },
{ id = 28930, img = 28930, name = "Stuffed Teddy Display", price = 2000 },
{ id = 23691, img = 23691, name = "Fish in a Tank", price = 1000 },
{ id = 5929, img = 5929, name = "Goldfish Bowl", price = 600 },
{ id = 5928, img = 5928, name = "Empty Goldfish Bowl", price = 300 },
{ id = 25213, img = 25213, name = "Chameleon", price = 1000 },
{ id = 8180, img = 8180, name = "Something Crawling", price = 2000 },
{ id = 20280, img = 20280, name = "Nightmare Beacon", price = 2000 },
}},
{ name = "Estatuas", items = {
{ id = 1446, img = 2025, name = "Stone Statue", price = 800 },
{ id = 1450, img = 2029, name = "Minotaur Statue", price = 1000 },
{ id = 1451, img = 2030, name = "Goblin Statue", price = 800 },
{ id = 4998, img = 5046, name = "Monkey Statue (See)", price = 1200 },
{ id = 5007, img = 5055, name = "Monkey Statue (Hear)", price = 1200 },
{ id = 5008, img = 5056, name = "Monkey Statue (Speak)", price = 1200 },
{ id = 5799, img = 5799, name = "Golden Figurine", price = 2000 },
{ id = 8148, img = 8148, name = "Golden Falcon", price = 5000 },
{ id = 9034, img = 9034, name = "Dracoyle Statue 1", price = 2500 },
{ id = 9035, img = 9035, name = "Dracoyle Statue 2", price = 2500 },
{ id = 8146, img = 8146, name = "Oracle Figurine", price = 5000 },
{ id = 9068, img = 9068, name = "Yalahari Figurine", price = 5000 },
{ id = 10424, img = 10424, name = "Clay Statue", price = 500 },
{ id = 10428, img = 10428, name = "Marble Statue", price = 1500 },
{ id = 10429, img = 10429, name = "Beautiful Marble Statue", price = 2000 },
{ id = 17723, img = 17723, name = "Filigree Statue", price = 3000 },
{ id = 7446, img = 7446, name = "Ice Mammoth", price = 3000 },
{ id = 7447, img = 7447, name = "Small Ice Statue", price = 1000 },
{ id = 10422, img = 10422, name = "Clay Lump", price = 200 },
{ id = 10423, img = 10423, name = "Rough Clay Statue", price = 300 },
{ id = 10425, img = 10425, name = "Pretty Clay Statue", price = 800 },
{ id = 10426, img = 10426, name = "Piece of Marble Rock", price = 500 },
{ id = 10427, img = 10427, name = "Rough Marble Statue", price = 800 },
}},
{ name = "Almofadas", items = {
{ id = 1685, img = 2393, name = "Heart Pillow", price = 250 },
{ id = 1686, img = 2394, name = "Blue Pillow", price = 200 },
{ id = 1687, img = 2395, name = "Red Pillow", price = 200 },
{ id = 1688, img = 2396, name = "Green Pillow", price = 200 },
{ id = 1689, img = 2397, name = "Yellow Pillow", price = 200 },
{ id = 1690, img = 2398, name = "Round Blue Pillow", price = 250 },
{ id = 1691, img = 2399, name = "Round Red Pillow", price = 250 },
{ id = 1692, img = 2400, name = "Round Purple Pillow", price = 250 },
{ id = 1693, img = 2401, name = "Round Turquoise Pillow", price = 250 },
{ id = 1678, img = 2386, name = "Small Purple Pillow", price = 150 },
{ id = 1679, img = 2387, name = "Small Green Pillow", price = 150 },
{ id = 1680, img = 2388, name = "Small Red Pillow", price = 150 },
{ id = 1681, img = 2389, name = "Small Blue Pillow", price = 150 },
{ id = 1682, img = 2390, name = "Small Orange Pillow", price = 150 },
{ id = 1683, img = 2391, name = "Small Turquoise Pillow", price = 150 },
{ id = 1684, img = 2392, name = "Small White Pillow", price = 150 },
}},
{ name = "Diversos", items = {
{ id = 2037, img = 2037, name = "Relogio", price = 800 },
{ id = 2346, img = 2346, name = "Joia", price = 1000 },
{ id = 2341, img = 3020, name = "Golden Fruits", price = 500 },
{ id = 24951, img = 24951, name = "Gilded Birthday Cup", price = 1000 },
{ id = 9616, img = 9616, name = "Bejeweled Telescope", price = 2000 },
{ id = 5805, img = 5805, name = "Golden Goblet", price = 2000 },
{ id = 5806, img = 5806, name = "Silver Goblet", price = 1000 },
{ id = 5807, img = 5807, name = "Bronze Goblet", price = 500 },
{ id = 22868, img = 22868, name = "Golden Goblet (Big)", price = 2500 },
{ id = 2977, img = 2977, name = "Pumpkinhead", price = 500 },
{ id = 6525, img = 6525, name = "Skeleton Decoration", price = 600 },
{ id = 9056, img = 9056, name = "Black Skull", price = 1000 },
{ id = 8532, img = 8532, name = "Blood Skull", price = 1000 },
{ id = 8032, img = 8032, name = "Spiderwebs", price = 100 },
{ id = 24438, img = 24438, name = "Starfish", price = 200 },
{ id = 11216, img = 903, name = "Badger Fur", price = 500 },
{ id = 14153, img = 14153, name = "Basket", price = 100 },
{ id = 6491, img = 6491, name = "Bat Decoration", price = 200 },
{ id = 2326, img = 3005, name = "Elven Brooch", price = 1500 },
{ id = 896, img = 896, name = "Firlefanz", price = 1000 },
{ id = 7958, img = 895, name = "Jester Staff", price = 1000 },
}},
}

-- CONFIGURAÇÃO E HELPERS
local ITEM_CATEGORY = {}
local IN_CATALOG = {}

for _, cat in ipairs(CATALOG) do
    for _, item in ipairs(cat.items) do
        ITEM_CATEGORY[item.id] = cat.name
        IN_CATALOG[item.id] = true
    end
end

local function getItemCount(player, id)
    local val = player:getStorageValue(STORAGE_BASE + id)
    return (val < 0) and 0 or val
end

local function setItemCount(player, id, count)
    player:setStorageValue(STORAGE_BASE + id, (count < 0) and 0 or count)
end

local function addItem(player, id, amount)
    local newTotal = getItemCount(player, id) + amount
    setItemCount(player, id, newTotal)
    return newTotal
end

local function removeItem(player, id, amount)
    local current = getItemCount(player, id)
    if current < amount then return false end
    setItemCount(player, id, current - amount)
    return true
end

local function getItemInfo(id)
    for _, cat in ipairs(CATALOG) do
        for _, item in ipairs(cat.items) do
            if item.id == id then return item end
        end
    end
end

local function canEditHouse(player, pos)
    local tile = Tile(pos)
    if not tile then return false, "Local invalido" end
    local house = tile:getHouse()
    if not house then return false, "Apenas em casas" end
    if house:getOwnerGuid() ~= player:getGuid() then return false, "Nao e sua casa" end
    return true
end

-- SISTEMA DE PAGINAS
local function getCategoryData(player, catIndex, page, mode)
    if catIndex < 1 or catIndex > #CATALOG then return nil end
    local category = CATALOG[catIndex]
    
    local allItems = category.items
    local validItems = {}
    
    if mode == "editor" then
        for _, item in ipairs(allItems) do
            if getItemCount(player, item.id) > 0 then
                table.insert(validItems, item)
            end
        end
    else
        validItems = allItems
    end
    
    local totalItems = #validItems
    local totalPages = math.ceil(totalItems / ITEMS_PER_PAGE)
    if totalPages < 1 then totalPages = 1 end
    
    if page < 1 then page = 1 end
    if page > totalPages then page = totalPages end
    
    local startIndex = (page - 1) * ITEMS_PER_PAGE + 1
    local endIndex = startIndex + ITEMS_PER_PAGE - 1
    
    local pageItems = {}
    for i = startIndex, endIndex do
        if validItems[i] then
            local itemData = validItems[i]
            table.insert(pageItems, {
                id = itemData.id,
                img = itemData.img, -- ENVIA O CLIENT ID MANUAL
                name = itemData.name,
                price = itemData.price,
                count = getItemCount(player, itemData.id)
            })
        end
    end
    
    return {
        catName = category.name,
        items = pageItems,
        page = page,
        totalPages = totalPages
    }
end

function onExtendedOpcode(player, opcode, buffer)
    if opcode ~= OPCODE_DECORATOR then return end

    if buffer == "OPEN" then
        local catNames = {}
        for _, cat in ipairs(CATALOG) do table.insert(catNames, cat.name) end
        
        local initialData = getCategoryData(player, 1, 1, "shop")
        
        player:sendExtendedOpcode(OPCODE_DECORATOR, json.encode({
            action = "OPEN",
            categories = catNames,
            balance = player:getMoney(),
            pageData = initialData
        }))
        return
    end

    if buffer:sub(1,5) == "PAGE:" then
        local mode, catIndex, pageNum = buffer:match("^PAGE:(%w+):(%d+):(%d+)")
        catIndex = tonumber(catIndex)
        pageNum = tonumber(pageNum)
        
        local data = getCategoryData(player, catIndex, pageNum, mode)
        if data then
            player:sendExtendedOpcode(OPCODE_DECORATOR, json.encode({
                action = "SHOW_PAGE",
                pageData = data,
                mode = mode,
                catIndex = catIndex
            }))
        end
        return
    end

    if buffer:sub(1,4) == "BUY:" then
        local id = tonumber(buffer:match("^BUY:(%d+)"))
        local item = getItemInfo(id)
        if not item then return end
        
        if player:removeMoney(item.price) then
            local total = addItem(player, id, 1)
            player:sendExtendedOpcode(OPCODE_DECORATOR, json.encode({
                action = "UPDATE_ITEM", id = id, count = total, balance = player:getMoney()
            }))
        else
            player:say("Sem dinheiro.", TALKTYPE_MONSTER_SAY)
        end
        return
    end

    if buffer:sub(1,6) == "BUILD:" then
        local id, x, y, z = buffer:match("^BUILD:(%d+),(%d+),(%d+),(%d+)")
        id, x, y, z = tonumber(id), tonumber(x), tonumber(y), tonumber(z)
        local pos = Position(x, y, z)

        local ok, msg = canEditHouse(player, pos)
        if not ok then
            player:say(msg, TALKTYPE_MONSTER_SAY)
            return
        end

        if not removeItem(player, id, 1) then
            player:say("Item acabou.", TALKTYPE_MONSTER_SAY)
            player:sendExtendedOpcode(OPCODE_DECORATOR, json.encode({action = "UPDATE_ITEM", id = id, count = 0}))
            return
        end

        local tile = Tile(pos)
        if not tile then
            addItem(player, id, 1)
            return
        end
        
        -- Lógica de substituição
        local category = ITEM_CATEGORY[id]
        local collected = {}
        
        if category == "Pisos" then
            local ground = tile:getGround()
            if ground then
                local groundId = ground:getId()
                if groundId ~= id then
                    if IN_CATALOG[groundId] then
                        local newTotal = addItem(player, groundId, 1)
                        table.insert(collected, {id = groundId, count = newTotal})
                    end
                    ground:remove()
                end
            end
        elseif category == "Paredes" then
            local items = tile:getItems()
            if items then
                for i = #items, 1, -1 do
                    local it = items[i]
                    local itId = it:getId()
                    local itType = ItemType(itId)
                    if itType and itType:isBlocking() and not itType:isMovable() then
                        if IN_CATALOG[itId] then
                            local newTotal = addItem(player, itId, 1)
                            table.insert(collected, {id = itId, count = newTotal})
                        end
                        it:remove()
                    end
                end
            end
        end
        
        Game.createItem(id, 1, pos)
        pos:sendMagicEffect(CONST_ME_POFF)
        
        local updates = {{id = id, count = getItemCount(player, id)}}
        for _, c in ipairs(collected) do table.insert(updates, c) end
        
        player:sendExtendedOpcode(OPCODE_DECORATOR, json.encode({
            action = "UPDATE_MULTI", items = updates
        }))
        return
    end

    if buffer:sub(1,6) == "ERASE:" then
        local x, y, z = buffer:match("^ERASE:(%d+),(%d+),(%d+)")
        local pos = Position(tonumber(x), tonumber(y), tonumber(z))

        local ok, msg = canEditHouse(player, pos)
        if not ok then
            player:say(msg, TALKTYPE_MONSTER_SAY)
            return
        end

        local tile = Tile(pos)
        if not tile then return end
        
        local items = tile:getItems()
        local ground = tile:getGround()
        local groundUid = ground and ground:getUniqueId() or 0
        local targetItem = nil
        
        if items then
            for i = #items, 1, -1 do
                local it = items[i]
                if it:getUniqueId() ~= groundUid then
                    local itType = ItemType(it:getId())
                    if itType and not (itType:isBlocking() and not itType:isMovable()) then
                        targetItem = it
                        goto found
                    end
                end
            end
            if not targetItem then
                for i = #items, 1, -1 do
                    local it = items[i]
                    if it:getUniqueId() ~= groundUid then
                        targetItem = it
                        goto found
                    end
                end
            end
        end
        
        ::found::
        if targetItem then
            local removedId = targetItem:getId()
            targetItem:remove()
            pos:sendMagicEffect(CONST_ME_POFF)
            if IN_CATALOG[removedId] then
                local total = addItem(player, removedId, 1)
                player:sendExtendedOpcode(OPCODE_DECORATOR, json.encode({
                    action = "UPDATE_ITEM", id = removedId, count = total
                }))
                player:say("Recuperado.", TALKTYPE_MONSTER_SAY)
            else
                player:say("Apagado.", TALKTYPE_MONSTER_SAY)
            end
        else
            player:say("Nada removivel.", TALKTYPE_MONSTER_SAY)
        end
        return
    end

    if buffer:sub(1,7) == "DELETE:" then
        local id = tonumber(buffer:match("^DELETE:(%d+)"))
        if not id then return end
        if getItemCount(player, id) > 0 then
            setItemCount(player, id, 0)
            player:sendExtendedOpcode(OPCODE_DECORATOR, json.encode({
                action = "UPDATE_ITEM", id = id, count = 0
            }))
            player:say("Descartado.", TALKTYPE_MONSTER_SAY)
        end
    end
end