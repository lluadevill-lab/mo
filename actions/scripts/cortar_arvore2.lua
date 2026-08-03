local woodId = 5901 -- ID da Madeira
local axeId = 2386 -- ID do Machado

-- Tabela que mapeia o ID da ÁRVORE para a QUANTIDADE MÍNIMA e MÁXIMA de madeira.
local treeDrops = {
    [2709] = {min = 1, max = 3}, -- Árvore 4000 dropará entre 3 e 5 madeiras
    [4008] = {min = 3, max = 8}, -- Árvore 4001 dropará entre 5 e 8 madeiras
    [2697] = {min = 5, max = 10}, -- Árvore 4002 dropará entre 2 e 4 madeiras
    -- ADICIONE AQUI TODOS OS IDs DAS SUAS ÁRVORES E SUAS QUANTIDADES
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Verifica se o item usado é o machado E se o alvo (a árvore) está na nossa lista de drops
    if item.itemid ~= axeId or not treeDrops[target.itemid] then
        return false
    end

    local treeData = treeDrops[target.itemid]
    local treePosition = target:getPosition()

    -- Gera uma quantidade aleatória de madeira usando os valores definidos para esta árvore
    local woodCount = math.random(treeData.min, treeData.max)
    
    -- REMOVE A ÁRVORE
    doRemoveItem(target.uid)
    
    -- Cria a madeira na posição da árvore
    Game.createItem(woodId, woodCount, treePosition)

    return true
end