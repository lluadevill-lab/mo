local OPCODE_SOUND = 50
local CAMPFIRE_ID = 1423
local RANGE = 2

function onThink(interval)
    for _, player in ipairs(Game.getPlayers()) do
        local pos = player:getPosition()

        for dx = -RANGE, RANGE do
            for dy = -RANGE, RANGE do
                local p = Position(pos.x + dx, pos.y + dy, pos.z)
                local tile = Tile(p)
                if tile then
                    local item = tile:getItemById(CAMPFIRE_ID)
                    if item then
                        player:sendExtendedOpcode(
                            OPCODE_SOUND,
                            string.format(
                                "campfire|%d|%d|%d",
                                p.x, p.y, p.z
                            )
                        )
                        goto nextPlayer
                    end
                end
            end
        end
        ::nextPlayer::
    end
    return true
end
