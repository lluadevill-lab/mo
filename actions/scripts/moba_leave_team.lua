function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item.itemid ~= 24118 then
        return false
    end

    player:setStorageValue(MOBA.STORAGE_TEAM, -1)
    player:setSkull(SKULL_NONE)

    player:unregisterEvent("MobaPrepareDeath")
    player:unregisterEvent("MobaHealthChange")
    player:unregisterEvent("MobaManaChange")
    player:unregisterEvent("MobaKillReward")

    local exitPos = Position(1422, 1071, 7)
    player:teleportTo(exitPos)
    exitPos:sendMagicEffect(CONST_ME_TELEPORT)

    player:sendTextMessage(
        MESSAGE_STATUS_SMALL,
        "Voce saiu do time."
    )

    return true
end
