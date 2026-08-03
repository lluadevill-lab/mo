local stone_id = 1422
local stone_lit_id = 1423
local fire_field_id = 1424
local tinder_id = 13943

-- novo par
local from_id = 1427
local to_id = 1428

local fire_effect = CONST_ME_FIREATTACK
local search_range = 1
local max_charges = 3

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item:getId() ~= tinder_id then
        return true
    end

    local charges = item:getAttribute(ITEM_ATTRIBUTE_CHARGES)
    if not charges or charges <= 0 then
        charges = max_charges
        item:setAttribute(ITEM_ATTRIBUTE_CHARGES, charges)
    end

    if charges <= 0 then
        player:say("Seu silex desgastou.", TALKTYPE_MONSTER_SAY)
        return true
    end

    local player_pos = player:getPosition()
    local found_stone = nil
    local found_stone_item = nil
    local found_transform = nil

    for x = -search_range, search_range do
        for y = -search_range, search_range do
            local pos = Position(player_pos.x + x, player_pos.y + y, player_pos.z)
            local tile = Tile(pos)
            if tile then
                local items = tile:getItems()
                if items then
                    local hasFire = false
                    for _, it in ipairs(items) do
                        local id = it:getId()
                        if id == fire_field_id then
                            hasFire = true
                        elseif id == stone_id then
                            found_stone = pos
                            found_stone_item = it
                        elseif id == from_id then
                            found_transform = { item = it }
                        end
                    end
                    if hasFire then
                        found_stone = nil
                        found_stone_item = nil
                    end
                end
            end
        end
    end

    -- transformar 1427 -> 1428
    if found_transform then
        found_transform.item:transform(to_id)
        playClientSound(player, "fire.ogg", 100)
        return true
    end

    if not found_stone or not found_stone_item then
        player:say("Se aproxime de uma fogueira.", TALKTYPE_MONSTER_SAY)
        return true
    end

    player_pos:sendDistanceEffect(found_stone, fire_effect)

    found_stone_item:remove(1)
    Game.createItem(stone_lit_id, 1, found_stone)
    Game.createItem(fire_field_id, 1, found_stone)

    found_stone:sendMagicEffect(CONST_ME_FIREAREA)
    playClientSound(player, "fire.ogg", 100)

    charges = charges - 1
    item:setAttribute(ITEM_ATTRIBUTE_CHARGES, charges)

    if charges == 0 then
        player:say("Seu silex quebrou.", TALKTYPE_MONSTER_SAY)
        item:remove(1)
    end

    return true
end
