COOKING = {
    UTENSILS = {
        [2561] = {
            recipes = {
                { ingredients = {2666}, time = 10, result = 13297 },
                { ingredients = {2667, 8838}, time = 10, result = 10001 }
            }
        }
    },

    FIRES = {
        [1424] = true,
        [1423] = true
    },

    ACTIVE = {}
}

local function posKey(pos)
    return pos.x .. "_" .. pos.y .. "_" .. pos.z
end

function COOKING.startCooking(utensil)
    local key = posKey(utensil:getPosition())
    if COOKING.ACTIVE[key] then return end

    local data = COOKING.UTENSILS[utensil:getId()]
    if not data then return end

    local items = utensil:getItems()
    if not items or #items == 0 then return end

    for _, recipe in ipairs(data.recipes) do
        local ok = true
        for _, req in ipairs(recipe.ingredients) do
            local found = false
            for _, it in ipairs(items) do
                if it:getId() == req then
                    found = true
                    break
                end
            end
            if not found then ok = false break end
        end

        if ok then
            COOKING.ACTIVE[key] = {
                start = os.time(),
                time = recipe.time,
                result = recipe.result,
                ingredients = recipe.ingredients
            }
            return
        end
    end
end
