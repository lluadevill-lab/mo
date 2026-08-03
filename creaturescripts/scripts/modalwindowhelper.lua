-- data/creaturescripts/scripts/modalwindowhelper.lua (CORRIGIDO: Navegação multi-nível)

local MODAL_RECIPELIST_DETAILS_ID = 255502 -- Nível 3 (Novo ID)
local MODAL_RECIPES_ID = 255501
local MODAL_CATEGORIES_ID = 255500

-- Funcao auxiliar (mantida para compatibilidade, retorna ao nivel 1)
function reopenRecipeList(player)
    addEvent(function()
        local p = Player(player:getId())
        if p and showRecipeCategories then
            showRecipeCategories(p) 
        end
    end, 500)
end
rawset(_G, 'reopenRecipeList', reopenRecipeList)


-- FUNÇÃO GLOBAL PARA EXIBIR OS DETALHES DA RECEITA (Nível 3)
function handleRecipeDetails(player, choiceId, modalWindow)
    
    -- Verifica se a modalWindow (Nível 2) continha as informações de contexto necessárias
    if not modalWindow or not modalWindow.recipeMap or not modalWindow.currentCategory then
        player:sendCancelMessage("Erro: Nao foi possivel recuperar o contexto da categoria.") 
        return true
    end
    
    local recipeId = modalWindow.recipeMap[choiceId]
    local currentCategory = modalWindow.currentCategory -- Nome da categoria para voltar ao Nível 2

    if not recipeId or recipeId == 0 then
        player:sendCancelMessage("Escolha invalida.")
        return true
    end

    -- Procura a receita na estrutura aninhada por categoria (FIX)
    local recipe = nil
    for _, recipes in pairs(_FORGERECIPES) do
        if recipes[recipeId] then
            recipe = recipes[recipeId]
            break
        end
    end

    if not recipe then
        player:sendCancelMessage("Receita invalida.")
        return true
    end

    local recipeName = getItemNameById(recipeId)
    local requiredSkill = recipe.skill or 0

    -- Monta a string de ingredientes
    local ingredientsText = "\nIngredientes Necessarios:\n"
    for _, itemData in pairs(recipe.items) do
        local ingredientId = itemData[1]
        local ingredientCount = itemData[2]
        local ingredientName = getItemNameById(ingredientId)
        ingredientsText = ingredientsText .. string.format("\n- %d %s", ingredientCount, ingredientName)
    end
    
    -- Adiciona informacoes de skill
    if _FORGESYSTEM.useSkill then
        local currentSkill = getForgeLevel(player)
        local status = currentSkill >= requiredSkill and "Voce PODE fazer este item." or "Voce PRECISA de skill " .. requiredSkill .. " para fazer este item."
        ingredientsText = ingredientsText .. "\n\nSkill de Forja Necessaria: " .. requiredSkill .. "\nStatus: " .. status
    end


    local detailWindow = ModalWindow({
        id = MODAL_RECIPELIST_DETAILS_ID, 
        title = "Detalhes da Receita: " .. recipeName, 
        message = ingredientsText
    })

    detailWindow:addButton("Voltar") 
    -- Callback do botão Voltar (retorna ao Nível 2)
    detailWindow:setDefaultCallback(function()
        if showRecipesInCategory then
            showRecipesInCategory(player, currentCategory) -- Retorna para a lista de receitas da categoria
        else
            showRecipeCategories(player) -- Fallback para lista de categorias
        end
    end)
    
    detailWindow:create()
    detailWindow:sendToPlayer(player)
    return true
end
rawset(_G, 'handleRecipeDetails', handleRecipeDetails)


-- A função onModalWindow não precisa de mudanças, ela apenas executa o callback definido
-- nos botões das funções acima.
function onModalWindow(player, modalWindowId, buttonId, choiceId)
    local modalWindow
    for _, window in ipairs(modalWindows.windows) do
        if window.id == modalWindowId then
            modalWindow = window
            break
        end
    end

    if not modalWindow then
            return true
    end

    local playerId = player:getId()
    if not modalWindow.players[playerId] then
            return true
    end
    modalWindow.players[playerId] = nil

    local choice = modalWindow.choices[choiceId]

    for _, button in ipairs(modalWindow.buttons) do
        if button.id == buttonId then
                local callback = button.callback or modalWindow.defaultCallback
                if callback then
                        callback(button, choice)
                        break
                end
        end
    end

    return true
end