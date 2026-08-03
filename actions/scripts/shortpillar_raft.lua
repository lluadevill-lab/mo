-- data/actions/scripts/teleport_actions.lua

local teleports = {
    [16969] = {x = 724, y = 916, z = 7},
    [16968] = {x = 724, y = 898, z = 7}
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local dest = teleports[item.actionid]
    if not dest then
        return false
    end

    player:teleportTo(Position(dest.x, dest.y, dest.z))
    player:getPosition():sendMagicEffect(CONST_ME_LOSEENERGY)
    return true
end
