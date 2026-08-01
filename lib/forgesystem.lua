rawset(_G, '_FORGESYSTEM', {
    forgeContainerIds = {2555,1988}, -- ACEITA VÁRIOS IDs: {2595, 1987, 2000}
    useMagicEffect = true,
    useSkill = true,
    storages = {
        level = 99900,
        tries = 99901
    },
    prompt = {
        invalidRecipe = "This recipe is not valid. The correct ingredients must be placed in the container.",
        needSkill = "You need skill level %L to make this recipe.",
        createdItem = "You have created %a %N."
    }
})

rawset(_G, '_FORGERECIPES', {

    -- CATEGORIA: INGREDIENTES
    ["Ingredientes"] = {
        [2120] = { items = {{11245, 2}}, skill = 0 },
        [5909] = { items = {{11236, 1}}, skill = 0 }
    },

    -- CATEGORIA: FERRAMENTAS
    ["Ferramentas"] = {
        [2050] = { items = {{5909, 1}, {5901, 1}}, skill = 0 },
        [2580] = { items = {{5901, 2}, {2120, 2}}, skill = 0 },
        [2552] = { items = {{5901, 2}, {1293, 1}}, skill = 0 },
        [5710] = { items = {{5901, 2}, {1293, 2}}, skill = 0 },
        [2553] = { items = {{5901, 1}, {1293, 3}}, skill = 0 },
        [4874] = { items = {{5901, 1}, {2225, 3}}, skill = 0 }
    },

    -- CATEGORIA: ACESSORIOS
    ["Acessorios"] = {
        [1987] = { items = {{2120, 1}, {5878, 1}}, skill = 0 },
        [1988] = { items = {{2120, 1}, {5878, 3}}, skill = 0 }
    },

    -- CATEGORIA: VESTUARIO
    ["Vestuario"] = {
        [2467] = { items = {{5878, 5}}, skill = 0 },
        [2649] = { items = {{5878, 4}}, skill = 0 },
        [2643] = { items = {{5878, 2}}, skill = 0 },
        [2461] = { items = {{5878, 3}}, skill = 0 }
    },

    -- CATEGORIA: ESPADAS E FACAS
    ["Espadas e Facas"] = {
        [2403] = { items = {{2225, 2}}, skill = 0 },
        [2420] = { items = {{2225, 4}}, skill = 0 },
        [13829] = { items = {{5901, 3}}, skill = 0 },
        [2379] = { items = {{2225, 3}}, skill = 0 },
        [2411] = { items = {{2379, 1}, {2006, 1}}, skill = 0 },
        [2449] = { items = {{2230, 2}, {5901, 1}}, skill = 0 }
    },

    -- CATEGORIA: MACHADOS
    ["Machados"] = {
        [2386] = { items = {{5901, 1}, {1293, 2}}, skill = 0 },
        [8601] = { items = {{5901, 1}, {2225, 2}}, skill = 0 },
        [2428] = { items = {{2230, 3}, {5901, 1}}, skill = 0 }
    },

    -- CATEGORIA: PORRETES
    ["Porretes"] = {
        [2382] = { items = {{5901, 1}, {1293, 1}}, skill = 0 },
        [2448] = { items = {{5901, 2}, {2225, 1}}, skill = 0 }
    },

    -- CATEGORIA: ESCUDOS
    ["Escudos"] = {
        [2512] = { items = {{5901, 10}}, skill = 0 },
        [2526] = { items = {{5901, 10}, {2225, 1}}, skill = 0 },
        [2541] = { items = {{2230, 10}}, skill = 0 },
        [2530] = { items = {{25378, 2}}, skill = 0 }
    },

    -- CATEGORIA: ARMAS DE DISTANCIA
    ["Armas de Distancia"] = {
        [2389] = { items = {{5901, 2}}, skill = 0 },
        [2456] = { items = {{5901, 2}, {2120, 1}}, skill = 0 },
        [2544] = { items = {{5901, 1}, {19742, 1}}, skill = 0 },
        [2545] = { items = {{2544, 1}, {2006, 1}}, skill = 0 }
    }
})

-- Compatibilidade
if getItemNameById == nil then
    function getItemNameById(itemId)
        local item = ItemType(itemId)
        return (item and item:getName()) and item:getName() or "Unknown Item (" .. itemId .. ")"
    end
end

if getItemInfo == nil then
    function getItemInfo(itemId)
        local item = ItemType(itemId)
        return { article = (item and item:getArticle()) or 'a' }
    end
end

----------********************----------
----        GENERAL FUNCTIONS     ----
----------********************----------

function table.copy(original)
    local copy = {}
    for k, v in pairs(original) do
        copy[k] = v
    end
    return copy
end

-- MULTI-CONTAINER SUPORTE AQUI
local function findForgeContainer(position)
    for _, id in ipairs(_FORGESYSTEM.forgeContainerIds) do
        local item = getTileItemById(position, id)
        if item and item.uid > 0 then
            return item
        end
    end
    return nil
end

function RecipeFromPosition(position)
    local obj = nil
    local maxItemsRequired = 0

    local forgeContainer = findForgeContainer(position)
    if not forgeContainer then
        return nil
    end

    -- Mapeia itens no container
    local availableItems = {}
    local size = getContainerSize(forgeContainer.uid)

    for i = 0, size - 1 do
        local item = getContainerItem(forgeContainer.uid, i)
        if item.itemid > 0 then
            local amount = math.max(1, item.type)
            availableItems[item.itemid] = (availableItems[item.itemid] or 0) + amount
        end
    end

    -- Verifica receitas
    for _, category in pairs(_FORGERECIPES) do
        for resultId, data in pairs(category) do
            local ok = true
            local total = 0
            local temp = table.copy(availableItems)
            local recipeItems = {}

            for _, req in ipairs(data.items) do
                local id, need = req[1], req[2]
                if (temp[id] or 0) < need then
                    ok = false
                    break
                end
                temp[id] = temp[id] - need
                total = total + need
                table.insert(recipeItems, {id, need})
            end

            if ok and (obj == nil or total > maxItemsRequired) then
                obj = Recipe:new()
                obj:setResult(resultId)
                obj:setItems(recipeItems)
                obj:setSkill(data.skill)
                maxItemsRequired = total
            end
        end
    end

    if obj then
        obj:setContainerUid(forgeContainer.uid)
    end
    return obj
end

function getForgeLevel(cid)
    local v = getPlayerStorageValue(cid, _FORGESYSTEM.storages.level)
    return (v <= 0 and 1 or v)
end

function setForgeLevel(cid, v)
    setPlayerStorageValue(cid, _FORGESYSTEM.storages.level, v)
end

function getForgeTries(cid)
    return getPlayerStorageValue(cid, _FORGESYSTEM.storages.tries)
end

function addForgeTry(cid)
    local lvl = getForgeLevel(cid)
    local tries = getForgeTries(cid)

    if tries + 1 >= (lvl + (lvl + 1) * 2) * 3 then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You have advanced from level ".. lvl .." to level ".. lvl + 1 .." in Forging")
        setForgeLevel(cid, lvl + 1)
        setPlayerStorageValue(cid, _FORGESYSTEM.storages.tries, 0)
    else
        setPlayerStorageValue(cid, _FORGESYSTEM.storages.tries, tries + 1)
    end
end

----------********************----------
----          MAIN FUNCTIONS      ----
----------********************----------

Recipe = {
    itemid = 0,
    items = {},
    skill = 0,
    containerUid = 0
}

function Recipe:new(obj)
    return setmetatable(obj or {}, { __index = self })
end

function Recipe:setResult(id) self.itemid = id end
function Recipe:setItems(t) self.items = t end
function Recipe:setSkill(v) self.skill = v end
function Recipe:setContainerUid(uid) self.containerUid = uid end

-- Remoção interna
local function removeItemsFromContainer(uid, id, count)
    local left = count
    for i = getContainerSize(uid) - 1, 0, -1 do
        if left <= 0 then break end
        local it = getContainerItem(uid, i)
        if it.itemid == id then
            local amount = math.max(1, it.type)
            local remove = math.min(left, amount)
            if doRemoveItem(it.uid, remove) then
                left = left - remove
            end
        end
    end
    return left == 0
end

function Recipe:forge(cid, pos)
    if self.containerUid == 0 then
        return false
    end

    if getForgeLevel(cid) >= self.skill or not _FORGESYSTEM.useSkill then

        -- Remove ingredientes
        for _, req in ipairs(self.items) do
            removeItemsFromContainer(self.containerUid, req[1], req[2])
        end

        if _FORGESYSTEM.useMagicEffect then
            doSendMagicEffect(pos, CONST_ME_MAGIC_GREEN)
        end

        doPlayerAddItem(cid, self.itemid, 1)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_DEFAULT,
            (_FORGESYSTEM.prompt.createdItem
                :gsub("%%N", getItemNameById(self.itemid))
                :gsub("%%a", getItemInfo(self.itemid).article))
        )

    else
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_DEFAULT,
            (_FORGESYSTEM.prompt.needSkill:gsub("%%L", self.skill)))
        if _FORGESYSTEM.useMagicEffect then
            doSendMagicEffect(pos, CONST_ME_POFF)
        end
    end

    if _FORGESYSTEM.useSkill and getForgeLevel(cid) >= self.skill then
        addForgeTry(cid)
    end
    return true
end
