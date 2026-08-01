--[[
      Ultimate House Builder System
      Biblioteca Central para Construção de Casas
]]--

---------- CONFIGURAÇÃO GLOBAL ----------
rawset(_G, '_HOUSEBUILDER', {
    prompt = {
        needSkill = "Você precisa de nível de Construção %L para fazer este item.",
        createdItem = "Você criou %a %N.",
        invalidRecipe = "Receita inválida ou materiais insuficientes.",
        noSpace = "Não há espaço livre na sua frente para colocar o item."
    },
    skillStorage = 99910, -- Storage para o nível de Construção (Build Level)
    useSkill = true
})

---------- ITENS E RECEITAS ----------
-- IconId é o ItemId que será exibido no ícone da interface.
rawset(_G, '_HOUSEBUILDER_RECIPES', {
    
    -- Placeholder IDs (Ajuste para os IDs reais do seu servidor)
    -- Madeira (Wood): 5901, Pedra (Stone): 2225, Prego (Nail): 7183, Tijolo (Brick): 1785
    
    ["Paredes"] = {
        [1786] = { -- Exemplo: Parede de Tijolo
            name = "Parede de Tijolos Forte",
            iconId = 1786,
            items = {{1785, 4}, {2225, 2}}, -- 4 Tijolos, 2 Pedras
            skill = 0 
        },
        [5902] = { -- Exemplo: Parede de Madeira
            name = "Parede de Madeira Simples",
            iconId = 5902,
            items = {{5901, 8}, {7183, 5}}, -- 8 Madeira, 5 Prego
            skill = 0
        }
    },

    ["Piso"] = {
        [2055] = { -- Exemplo: Piso de Madeira Clara
            name = "Chão de Madeira (Claro)",
            iconId = 2055,
            items = {{5901, 10}}, -- 10 Madeira
            skill = 0
        },
        [184] = { -- Exemplo: Piso de Pedra Polida
            name = "Chão de Pedra Polida",
            iconId = 184,
            items = {{2225, 12}}, -- 12 Pedras
            skill = 5
        }
    },

    ["Porta"] = {
        [3560] = { -- Exemplo: Porta de Madeira
            name = "Porta de Carvalho",
            iconId = 3560,
            items = {{5901, 15}, {7183, 10}}, -- 15 Madeira, 10 Prego
            skill = 10
        },
        [3556] = { -- Exemplo: Porta de Prisão
            name = "Porta de Ferro (Grade)",
            iconId = 3556,
            items = {{2225, 10}, {7183, 15}}, -- 10 Pedra, 15 Prego
            skill = 15
        }
    },

    ["Decoracao"] = {
        [2084] = { -- Exemplo: Cadeira
            name = "Cadeira Rústica",
            iconId = 2084,
            items = {{5901, 3}},
            skill = 0
        },
        [2704] = { -- Exemplo: Mesa
            name = "Mesa Grande de Jantar",
            iconId = 2704,
            items = {{5901, 10}},
            skill = 0
        }
    }
})

---------- FUNÇÕES DE COMPATIBILIDADE (Não altere) ----------
if getItemNameById == nil then
    function getItemNameById(itemId)
        local item = ItemType(itemId)
        return (item and item:getName()) and item:getName() or "Unknown Item (" .. itemId .. ")"
    end
end

if getItemInfo == nil then
    function getItemInfo(itemId)
        local item = ItemType(itemId)
        local info = { article = (item and item:getArticle()) or 'a' }
        return info
    end
end

---------- FUNÇÕES DE SKILL ----------
function getBuildLevel(player)
    local val = player:getStorageValue(_HOUSEBUILDER.skillStorage)
    return (val <= 0 and 1 or val)
end

function addBuildTry(player)
    -- Lógica de skill simplificada
    local level = getBuildLevel(player)
    local triesStorage = _HOUSEBUILDER.skillStorage + 1
    local tries = player:getStorageValue(triesStorage)
    
    local triesNeeded = level * 10 
    
    if tries + 1 >= triesNeeded then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você avançou para o nível ".. level + 1 .." de Construção!")
        player:setStorageValue(_HOUSEBUILDER.skillStorage, level + 1)
        player:setStorageValue(triesStorage, 0)
    else
        player:setStorageValue(triesStorage, tries + 1)
    end
end

---------- FUNÇÕES PRINCIPAIS ----------

-- Abre a interface de criação.
function HouseBuilderOpen(player)
    local categories = {}
    local recipes = {}
    
    -- Prepara dados para showCreationWindow
    for categoryName, categoryRecipes in pairs(_HOUSEBUILDER_RECIPES) do
        table.insert(categories, categoryName)
        for itemId, recipeData in pairs(categoryRecipes) do
            -- Estrutura: {itemid, iconid, name, ingredients = {{id, count}, ...}, skill}
            local recipe = {
                itemid = itemId,
                iconid = recipeData.iconId,
                name = recipeData.name,
                ingredients = recipeData.items,
                skill = recipeData.skill or 0
            }
            if not recipes[categoryName] then
                recipes[categoryName] = {}
            end
            table.insert(recipes[categoryName], recipe)
        end
    end

    -- Cria a janela
    player:showCreationWindow("Ultimate House Builder", categories, recipes, "HouseBuilderForge")
    return true
end

-- Tenta criar o item
function HouseBuilderForge(player, categoryName, resultItemId)
    local recipeData = nil
    
    -- 1. Encontra a receita
    local category = _HOUSEBUILDER_RECIPES[categoryName]
    if category then
        recipeData = category[resultItemId]
    end

    if not recipeData then
        player:sendCancelMessage(_HOUSEBUILDER.prompt.invalidRecipe)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local requiredSkill = recipeData.skill or 0
    local buildLevel = getBuildLevel(player)

    -- 2. Verifica Nível de Skill
    if _HOUSEBUILDER.useSkill and buildLevel < requiredSkill then
        player:sendCancelMessage(_HOUSEBUILDER.prompt.needSkill:gsub("%%L", requiredSkill))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
    
    -- 3. Verifica Materiais no Player
    local itemsToConsume = recipeData.items
    local canCraft = true
    
    for _, itemInfo in ipairs(itemsToConsume) do
        local requiredId = itemInfo[1]
        local requiredCount = itemInfo[2]
        if player:getItemCount(requiredId) < requiredCount then
            canCraft = false
            break
        end
    end
    
    if not canCraft then
        player:sendCancelMessage(_HOUSEBUILDER.prompt.invalidRecipe)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    -- 4. Define Posição de Criação (Frente do Jogador)
    local playerPos = player:getPosition()
    local targetPos = playerPos:getNextPosition(player:getDirection())
    local targetTile = Tile(targetPos)

    -- Verifica se o Tile está livre
    if targetTile and (targetTile:getGround() and targetTile:getGround():isBlocking()) or (targetTile:hasBlockingItem() or targetTile:hasCreature()) then
        -- Permite colocar sobre itens não-blocking (como decorações, desde que a parede/piso seja a primeira coisa)
        if ItemType(resultItemId):isBlockSolid() and targetTile:hasBlockingItem() then
            player:sendCancelMessage(_HOUSEBUILDER.prompt.noSpace)
            return false
        end
        if targetTile:hasCreature() then
             player:sendCancelMessage(_HOUSEBUILDER.prompt.noSpace)
             return false
        end
    end

    -- 5. Consome Materiais
    for _, itemInfo in ipairs(itemsToConsume) do
        local requiredId = itemInfo[1]
        local requiredCount = itemInfo[2]
        player:removeItem(requiredId, requiredCount)
    end
    
    -- 6. Cria o Item no Local
    Game.createItem(resultItemId, 1, targetPos)

    -- 7. Feedback e Skill
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, (_HOUSEBUILDER.prompt.createdItem:gsub("%%N", getItemNameById(resultItemId)):gsub("%%a", getItemInfo(resultItemId).article)))
    playerPos:sendMagicEffect(CONST_ME_MAGIC_BLUE)
    
    if _HOUSEBUILDER.useSkill and buildLevel >= requiredSkill then
        addBuildTry(player)
    end 
    
    return true
end