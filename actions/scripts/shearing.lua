local config = {
    -- Configuração de Cooldown em segundos (1 minuto)
    cooldown = 60,
    -- Storage Base Key (Soma-se a coordenada para criar uma Key única por Tile)
    storage_cooldown_base = 1000000, 
    
    -- Configuração de Itens (Quantidade fixa em 3)
    wool_item = {id = 11236, amount = 3},         -- Item da Sheep
    black_wool_item = {id = 12404, amount = 3},   -- Item da Black Sheep

    -- Efeito mágico ao skinnar
    effect = CONST_ME_HITAREA
}

local skinnable_creatures = {
    ["Sheep"] = config.wool_item,
    ["Black Sheep"] = config.black_wool_item
}

-- Função para gerar uma Storage Key única baseada na posição do Tile
function getPositionStorageKey(pos)
    -- Cria um valor único a partir de X, Y e Z para ser a storage key
    -- Garante que o número não seja muito grande, adaptando-o
    return config.storage_cooldown_base + (pos.x * 1000) + pos.y + (pos.z * 1000000)
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- 1. Verifica se o alvo é uma criatura
    if not isCreature(target) then
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can only skin creatures.")
        return true
    end

    local creatureName = getCreatureName(target)
    
    if skinnable_creatures[creatureName] then
        local tPos = getCreaturePosition(target)
        local itemData = skinnable_creatures[creatureName]
        local cid = player.uid
        
        -- VARIÁVEIS DE COOLDOWN POR POSIÇÃO (Tile da Ovelha)
        local cooldownKey = getPositionStorageKey(tPos)
        
        -- Atenção: O cooldown é aplicado no JOGADOR, mas a chave é única por tile.
        local lastUsed = getPlayerStorageValue(cid, cooldownKey)
        local currentTime = os.time()
        
        if lastUsed > 0 and (currentTime < lastUsed + config.cooldown) then
            local remainingTime = (lastUsed + config.cooldown) - currentTime
            player:sendCancelMessage("Voce deve aguardar " .. remainingTime .. " segundos para tosquiar essa " .. creatureName:lower() .. " outra vez.")
            return true
        end

        -- 2. Aplica o novo Cooldown (Storage Key única para a posição)
        setPlayerStorageValue(cid, cooldownKey, currentTime)
        
        -- 3. Concede o item
        player:addItem(itemData.id, itemData.amount)
        
        -- 4. Aplica efeito (a criatura não é removida)
        doSendMagicEffect(tPos, config.effect)
        
        -- 5. Mensagem de sucesso
        local itemName = getItemNameById and getItemNameById(itemData.id) or "wool"
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Voce tosquiou uma " .. creatureName:lower() .. " e coletou " .. itemData.amount .. " " .. itemName .. ".")
        
    else
        -- Criatura não configurada para skinning
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "You cannot skin this creature.")
    end
    
    return true
end