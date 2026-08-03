local AS = AdvancedSounds

function onUse(player, item, ...)
    local pos = item:getPosition()

    AS.playSoundAtPosition("open_wood_door.ogg", pos, 10, 40)

    return Door.onUse(player, item, ...)
end
