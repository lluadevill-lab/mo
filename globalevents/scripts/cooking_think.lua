local function containerHas(container, id)
    for _, item in ipairs(container:getItems() or {}) do
        if item:getId() == id then
            return true
        end
    end
    return false
end

local function containerCount(container, list)
    local count = 0
    for _, item in ipairs(container:getItems() or {}) do
        if isInArray(list, item:getId()) then
            count = count + 1
        end
    end
    return count
end

function onThink(interval)
    for uid, data in pairs(COOKING.ACTIVE) do
        local tile = Tile(data.pos)
        if not tile then
            COOKING.ACTIVE[uid] = nil
            goto continue
        end

        local container = tile:getItemById(data.id)
        if not container or not container:isContainer() then
            COOKING.ACTIVE[uid] = nil
            goto continue
        end

        for _, recipe in ipairs(COOKING.RECIPES) do
            -- check utensílio
            if not containerHas(container, recipe.utensil) then
                goto nextrecipe
            end

            -- check ingredientes
            if containerCount(container, recipe.ingredients.id) < #recipe.ingredients.id then
                goto nextrecipe
            end

            -- tempo
            if os.time() - data.start >= recipe.time then
                -- limpa ingredientes
                for _, item in ipairs(container:getItems() or {}) do
                    if isInArray(recipe.ingredients.id, item:getId()) then
                        item:remove()
                    end
                end

                -- remove utensílio só se quiser; aqui não remove
                -- cria resultado
                container:addItem(recipe.result, 1)

                container:getPosition():sendMagicEffect(CONST_ME_FIREAREA)

                -- reinicia timer só se quiser permitir múltiplos ciclos
                data.start = os.time()
            end

            ::nextrecipe::
        end

        ::continue::
    end

    return true
end
