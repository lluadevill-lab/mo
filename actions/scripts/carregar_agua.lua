-- data/actions/scripts/fill_flask.lua

local emptyFlask = 2032
local fullFlask  = 12289

local waterIds = {
    [493] = true,   -- shallow water
    [4608] = true,  -- deep water
    [4609] = true,
    [4610] = true,
    [4611] = true
}

function onUse(player, item, fromPos, target, toPos, isHotkey)
    local tile = Tile(toPos)
    if not tile then
        return false
    end

    local ground = tile:getGround()
    if not ground then
        return false
    end

    if not waterIds[ground:getId()] then
        return false
    end

    item:remove()
    player:addItem(fullFlask, 1)
    toPos:sendMagicEffect(CONST_ME_LOSEENERGY)

    return true
end
