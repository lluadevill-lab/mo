-- Constante deve ser a mesma do cliente
local OPCODE_SOUND_EFFECT = 51

function playClientSound(player, filename, volume)
    -- Verifica se é um player válido
    if not player or not isPlayer(player) then return false end
    
    -- Se o servidor for TFS 1.x+ usa player:sendExtendedOpcode
    -- Se for 0.4 usa doSendPlayerExtendedOpcode
    
    local buffer = filename
    if volume then
        buffer = buffer .. ":" .. volume
    end

    -- Envia o pacote
    -- Adapte a função abaixo conforme a versão do seu TFS
    if player.sendExtendedOpcode then
        player:sendExtendedOpcode(OPCODE_SOUND_EFFECT, buffer) -- TFS 1.x / Canary
    else
        doSendPlayerExtendedOpcode(player, OPCODE_SOUND_EFFECT, buffer) -- TFS 0.3 / 0.4
    end
    
    return true
end