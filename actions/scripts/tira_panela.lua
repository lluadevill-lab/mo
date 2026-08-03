-- data/actions/scripts/troca_1427.lua

local targetId = 1427
local rewardId = 2562
local replaceId = 1421

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item.itemid ~= targetId then
        return false
    end

    local pos = item:getPosition()
    item:remove()
    Game.createItem(replaceId, 1, pos)
    player:addItem(rewardId, 1)
    return true
end
