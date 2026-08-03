function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local pos = player:getPosition()
    local dest = Position(pos.x, pos.y, pos.z - 1)

    local tile = Tile(dest)
    if not tile or tile:hasFlag(TILESTATE_BLOCKSOLID) then
        player:say("Impossivel emergir aqui.", TALKTYPE_MONSTER_SAY)
        return true
    end

    player:teleportTo(dest, true)
    dest:sendMagicEffect(CONST_ME_WATERSPLASH)
    return true
end
