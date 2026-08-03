local conf = {
    maxSlotCount = 2,
    ignoredIds = {}
}

local function choose(list)
    return list[math.random(#list)]
end

local function getPer()
    local n = 1
    for i = 1, 10 do
        n = n + math.random(0, 10)
        if n < 8 * i then
            break
        end
    end
    return n
end

local function getSlotCount(name)
    local c = 0
    for _ in name:gmatch("%[(.-)%]") do
        c = c + 1
    end
    return c
end

local validStats = {"hp", "mp", "ml", "cas", "shield", "dist"}

function onUse(player, item, fromPosition, target, toPosition)
    if not target or not target:isItem() then
        return false
    end

    local it = Item(target.uid)
    local itType = it:getType()

    -- não permitir stackável
    if itType:isStackable() then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can't open a slot on this item.")
        return true
    end

    -- checar se faz sentido aplicar slot
    local wType = itType:getWeaponType()
    if wType == WEAPON_NONE and itType:getArmor() == 0 then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can't open a slot on this item.")
        return true
    end

    -- checar ignorados
    if table.contains(conf.ignoredIds, it:getId()) then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can't open a slot on this item.")
        return true
    end

    local name = it:getName()
    local count = getSlotCount(name)

    if count >= conf.maxSlotCount then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "This item already has the maximum number of slots.")
        return true
    end

    -- gerar stat
    local stat = choose(validStats)
    local per = getPer()

    -- efeitos
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    player:say(stat .. " +" .. per .. "%", TALKTYPE_MONSTER_SAY)

    -- renomear item
    it:setAttribute(ITEM_ATTRIBUTE_NAME, name .. " [+" .. per .. "% de " .. stat .. "]")

    -- consumir item usado
    item:remove(1)

    return true
end
