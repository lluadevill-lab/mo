local upgradeableTypes = {
    WEAPON_SWORD,
    WEAPON_CLUB,
    WEAPON_AXE,
    WEAPON_DISTANCE,
    WEAPON_WAND,
    WEAPON_ROD,
    ARMOR,
    SHIELD,
    HELMET,
    LEGS,
    BOOTS
}

local function isUpgradeable(item)
    local it = ItemType(item:getId())
    for _, t in ipairs(upgradeableTypes) do
        if it:getWeaponType() == t or it:getArmor() > 0 then
            return true
        end
    end
    return false
end

local function getUpgradeLevel(item)
    return item:getAttribute(ITEM_ATTRIBUTE_DESCRIPTION):match("%+(%d+)") or 0
end

local function setUpgradeLevel(item, level)
    local it = ItemType(item:getId())
    local baseDesc = it:getName()
    item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, baseDesc .. " +" .. level)
end

local function applyUpgrade(item)
    local level = tonumber(getUpgradeLevel(item))
    level = level + 1

    local it = ItemType(item:getId())

    -- AUMENTA ATRIBUTOS
    local newAtk  = it:getAttack() + level
    local newDef  = it:getDefense() + level
    local newArmor = it:getArmor() + level

    item:setAttribute(ITEM_ATTRIBUTE_ATTACK, newAtk)
    item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, newDef)
    item:setAttribute(ITEM_ATTRIBUTE_ARMOR, newArmor)

    setUpgradeLevel(item, level)
end

function onUse(player, item, fromPos, target, toPos)
    if not target or not target:isItem() then
        player:sendCancelMessage("Você deve usar o upgrade em um item.")
        return true
    end

    if not isUpgradeable(target) then
        player:sendCancelMessage("You can't refine this item.")
        return true
    end

    applyUpgrade(target)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Item refinado com sucesso!")
    item:remove(1)
    return true
end
