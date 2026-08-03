-- data/actions/scripts/combinar_1422.lua

local baseId = 1422
local needOnTop = 2562
local useId = 12289
local resultId = 1427
local rewardId = 2032

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item.itemid ~= useId then
        return false
    end

    local tile = Tile(toPosition)
    if not tile then
        return false
    end

    local foundBase = nil
    local foundNeed = nil

    for _, it in ipairs(tile:getItems() or {}) do
        local id = it:getId()
        if id == baseId then
            foundBase = it
        elseif id == needOnTop then
            foundNeed = it
        end
    end

    if not foundBase or not foundNeed then
        return false
    end

    item:remove()
    foundNeed:remove()

    local pos = foundBase:getPosition()
    foundBase:remove()
    Game.createItem(resultId, 1, pos)

    player:addItem(rewardId, 1)
    pos:sendMagicEffect(CONST_ME_MAGIC_RED)

    return true
end
