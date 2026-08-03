function onUse(player, item, fromPos, target, toPos)
    if not isInArray(COOKING.KITCHENS, item:getId()) then
        return false
    end

    player:openContainer(item, item)

    -- registra início
    COOKING.ACTIVE[item:getUniqueId()] = {
        uid = item:getUniqueId(),
        id = item:getId(),
        pos = item:getPosition(),
        start = os.time()
    }

    return true
end
