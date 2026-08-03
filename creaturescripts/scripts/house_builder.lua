local OPCODE_HB = 55
local ERASE_ID = 99999

function string.split(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function onExtendedOpcode(player, opcode, buffer)
    if opcode ~= OPCODE_HB then return end

    -- 1. MODO PICKER
    if buffer:sub(1, 5) == "PICK:" then
        local data = string.split(buffer:sub(6), ",")
        if #data >= 3 then
            local x = tonumber(data[1])
            local y = tonumber(data[2])
            local z = tonumber(data[3])
            local pos = Position(x, y, z)
            local tile = Tile(pos)
            
            if tile then
                local pickedId = nil
                local things = tile:getItems()
                -- Pega o item do topo (ignorando o chão por enquanto)
                if things then
                    for i = 1, #things do -- Itera normalmente (do topo da stack no server)
                        local item = things[i]
                        if item:getId() > 100 then 
                            pickedId = item:getId()
                            -- Não damos break para garantir que pegamos o último adicionado se a ordem estiver inversa
                        end
                    end
                end
                
                if not pickedId and tile:getGround() then
                    pickedId = tile:getGround():getId()
                end
                
                if pickedId then
                    player:sendExtendedOpcode(OPCODE_HB, "PICKED:" .. pickedId)
                end
            end
        end
        return
    end

    -- 2. BUILD / ERASE
    local itemId = nil
    local pos = nil

    if not buffer:find(",") then
        itemId = tonumber(buffer)
        local pPos = player:getPosition()
        local dir = player:getDirection()
        if dir == 0 then pPos.y = pPos.y - 1
        elseif dir == 1 then pPos.x = pPos.x + 1
        elseif dir == 2 then pPos.y = pPos.y + 1
        elseif dir == 3 then pPos.x = pPos.x - 1
        end
        pos = pPos
    else
        local data = string.split(buffer, ",")
        if #data >= 4 then
            itemId = tonumber(data[1])
            local x = tonumber(data[2])
            local y = tonumber(data[3])
            local z = tonumber(data[4])
            if x and y and z then
                pos = Position(x, y, z)
                if player:getPosition():getDistance(pos) > 14 then return end
            end
        end
    end

    if itemId and pos then
        if itemId == ERASE_ID then
            doErase(pos)
        else
            createItemAt(player, itemId, pos)
        end
    end
end

function doErase(pos)
    local tile = Tile(pos)
    if not tile then return end
    
    local items = tile:getItems()
    local ground = tile:getGround()
    
    if not items then return end
    
    -- PASSAGEM 1: Apaga decorações (Móveis, itens, quadros)
    for i = 1, #items do
        local item = items[i]
        local it = ItemType(item:getId())
        if it:isMovable() or (it.isHangable and it:isHangable()) or not it:isBlocking() then
            item:remove()
            pos:sendMagicEffect(CONST_ME_POFF)
            return
        end
    end
    
    -- PASSAGEM 2: Apaga estruturas (Paredes)
    for i = 1, #items do
        local item = items[i]
        if not ground or item:getUniqueId() ~= ground:getUniqueId() then
            if not item:isCreature() then
                item:remove()
                pos:sendMagicEffect(CONST_ME_POFF)
                return
            end
        end
    end
end

function createItemAt(player, itemId, pos)
    local tile = Tile(pos)
    if not tile then return end
    local newItemType = ItemType(itemId)
    if not newItemType then return end
    
    local isWall = false
    if newItemType:isMovable() == false then
        if newItemType:isBlocking() then
             if newItemType.isHangable and newItemType:isHangable() then isWall = false else isWall = true end
        end
    end
    
    if isWall then
         local items = tile:getItems()
         local ground = tile:getGround()
         if items then
            for i = 1, #items do
                local item = items[i]
                local it = ItemType(item:getId())
                if it:isMovable() == false and it:isBlocking() then
                    local isGround = false
                    if ground and item:getUniqueId() == ground:getUniqueId() then isGround = true end
                    if not isGround then item:remove() end
                end
            end
         end
    end
    Game.createItem(itemId, 1, pos)
end