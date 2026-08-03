-- martelo.lua
local VALID_TARGETS = {
    [1025] = true,
    [1026] = true,
    [1027] = true,
    [1029] = true,
}

local EFFECT = CONST_ME_GROUNDSHAKE

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not target or not target:isItem() then
        return false
    end

    if not VALID_TARGETS[target.itemid] then
        return false
    end

    local targetId = target.itemid
    local pos = target:getPosition()

    target:remove(1)
    pos:sendMagicEffect(EFFECT)
    player:addItem(targetId, 1)

    return true
end
