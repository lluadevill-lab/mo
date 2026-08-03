function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item.itemid == 5786 then
        player:openChannel(4)
    end
    return true
end
