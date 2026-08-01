AdvancedSounds = {}

AdvancedSounds.OPCODE = 55

local function send(player, tbl)
    local jsonData = json.encode(tbl)
    player:sendExtendedOpcode(AdvancedSounds.OPCODE, jsonData)
end

function AdvancedSounds.playSoundAtPosition(sound, pos, radius, volume)
    radius = radius or 10
    volume = volume or 50

    local players = Game.getPlayers()
    for _, p in ipairs(players) do
        local ppos = p:getPosition()
        if ppos.z == pos.z and getDistanceBetween(ppos, pos) <= radius then
            send(p, {
                cmd = "play_pos",
                sound = sound,
                x = pos.x,
                y = pos.y,
                z = pos.z,
                radius = radius,
                volume = volume
            })
        end
    end
end

function AdvancedSounds.playForPlayer(player, sound, volume)
    volume = volume or 50

    send(player, {
        cmd = "play",
        sound = sound,
        volume = volume
    })
end

function AdvancedSounds.playForPlayers(players, sound, volume)
    volume = volume or 50
    for _, p in ipairs(players) do
        send(p, {
            cmd = "play",
            sound = sound,
            volume = volume
        })
    end
end

function AdvancedSounds.broadcast(sound, volume)
    volume = volume or 50
    local players = Game.getPlayers()
    for _, p in ipairs(players) do
        send(p, {
            cmd = "play",
            sound = sound,
            volume = volume
        })
    end
end

return AdvancedSounds
