function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local dest = Position(toPosition.x, toPosition.y, toPosition.z + 1)

    local tile = Tile(dest)
    if not tile then
        return true
    end

    if tile:hasFlag(TILESTATE_BLOCKSOLID) then
        player:say("Impossivel mergulhar aqui.", TALKTYPE_MONSTER_SAY)
        return true
    end

    player:teleportTo(dest, true)
    
    player:addCondition(condition)
    
    dest:sendMagicEffect(CONST_ME_BUBBLES)
    return true
end