local fruitTrees = {
    -- ID_Arvore_Cheia = {empty = ID_Arvore_Vazia, fruit = ID_Fruta, count = Quantidade, name = Nome_Fruta, respawn = Tempo_Respawn_MS}
    
    [4006] = {empty = 4008, fruit = 2675, count = 4, name = "Orange", respawn = 180000},  
    [5094] = {empty = 5092, fruit = 2676, count = 6, name = "Banana", respawn = 180000},
    [5096] = {empty = 2726, fruit = 2678, count = 2, name = "Coconut", respawn = 180000}, 
    [5157] = {empty = 5156, fruit = 5097, count = 4, name = "Mango", respawn = 180000},
    [2785] = {empty = 2786, fruit = 2677, count = 12, name = "Blueberry", respawn = 180000}
    
}

-- Funcao de Respawn
function respawnTree(treePosition, treeItem, targetItemId)
    local tile = Tile(treePosition)
    local itemToTransform = nil

    if tile then
        -- Tenta encontrar o item vazio pelo ID, garantindo que seja o item no tile
        itemToTransform = tile:getItemById(treeItem)
    end
    
    if itemToTransform then
        -- Transforma a arvore vazia (treeItem) de volta para a arvore cheia (targetItemId)
        itemToTransform:transform(targetItemId)
    end
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local fullTreeId = item.itemid
    local config = fruitTrees[fullTreeId]
    
    -- Verifica se o item usado e uma arvore frutifera configurada
    if not config then
        return false
    end
    
    -- Transforma a arvore cheia para a arvore vazia (2726)
    item:transform(config.empty)
    
    -- ADICIONA O FRUTO NA MOCHILA DO JOGADOR
    player:addItem(config.fruit, config.count)
    
    -- Mensagem de colheita
    player:sendCancelMessage("Voce colheu " .. config.count .. " " .. config.name .. "(s).")
    
    -- Adiciona o evento para reverter a transformacao
    addEvent(respawnTree, config.respawn, fromPosition, config.empty, fullTreeId)

    return true
end