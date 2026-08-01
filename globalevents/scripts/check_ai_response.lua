function onThink(interval)
    local filePath = "data/ai_system/output.txt"
    
    -- Tenta abrir o arquivo para leitura
    local file = io.open(filePath, "r")
    if not file then return true end
    
    local content = file:read("*a") -- Lê tudo
    file:close()

    -- Se estiver vazio, não faz nada
    if content == "" then return true end

    -- Limpa o arquivo após ler (para não repetir a fala)
    local cleanFile = io.open(filePath, "w")
    cleanFile:write("")
    cleanFile:close()

    -- Processa as linhas
    for line in content:gmatch("[^\r\n]+") do
        -- Separa o Nome do Player da Resposta
        local separator = line:find("|")
        if separator then
            local pName = line:sub(1, separator - 1)
            local answer = line:sub(separator + 1)
            
            local player = Player(pName) -- Para TFS 1.x
            -- Se for TFS 0.4 use: local player = getPlayerByName(pName)
            
            if player then
                -- Faz o player falar a resposta ou mostra na tela
                -- player:say(answer, TALKTYPE_MONSTER_SAY) -- O player fala
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Oraculo: " .. answer)
                player:getPosition():sendMagicEffect(CONST_ME_SOUND_PURPLE)
            end
        end
    end

    return true
end