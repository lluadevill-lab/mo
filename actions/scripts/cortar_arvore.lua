local config = {
	-- IDs das Árvores que viram o toco (6432)
	trees_to_stump = {2725,2701, 2702, 2703, 2704, 2705, 2706, 2707, 2708, 2709, 2710, 2712, 2717, 2718, 2720, 2722, 2697, 2784, 2770, 8139, 2698, 7020, 7022, 7023, },
    
    -- IDs que devem ser DESTRUÍDOS (inclui as cheias e vazias frutíferas + outras)
    trees_to_destroy = {4006, 5094, 5096, 5157, 2785, -- <-- ARVORES CHEIAS
                        4008, 5092, 2726, 5156, 2786 -- <-- ARVORES VAZIAS/OUTRAS
                        },
	
	-- A tabela 't' é mantida para chance de evento (loot/dano/etc)
	t = {
		[{1, 100}] = {tree = 2701}, 
		[{101, 200}] = {tree = 2702}, 
		[{201, 300}] = {tree = 2703}, 
		[{301, 400}] = {tree = 2704}, 
		[{401, 500}] = {tree = 2705}, 
		[{501, 600}] = {tree = 2706}, 
		[{601, 700}] = {tree = 2707}, 
		[{701, 800}] = {tree = 2708}, 
		[{801, 900}] = {tree = 2709}, 
		[{901, 1000}] = {tree = 2710}, 
		[{1001, 1100}] = {tree = 2712}, 
		[{1101, 1200}] = {tree = 2717}, 
		[{1201, 1300}] = {tree = 2718}, 
		[{1301, 1400}] = {tree = 2720}, 
		[{1401, 1500}] = {tree = 2722} 
		},
	
	-- Requerimentos ZERADOS para teste
	level = 0,
	skill = SKILL_AXE,
	skillReq = 0,
	soul = 0,
	
	effect = CONST_ME_BLOCKHIT,
	addTries = 3,
	branches = 6432, -- ID do toco
	msgType = MESSAGE_EVENT_ADVANCE,
	
	-- Tempo de Respawn: 15 segundos (0.25 minutos)
	minutes = 5 
}

-- Tabela de Eventos (LOOT/DANO/ETC)
local t = {
	[{1, 500}] = {msg = "Voce cortou a arvore e pegou um pouco de madeira", item = 5901, amountmin = 3, amountmax = 6}, 
	[{501, 750}] = {msg = "Voce danificou seu machado e ele quebrou!", destroy = true},
	[{751, 1550}] = {msg = "Voce cortou a arvore mas a madeira nao estava boa."},
	[{1551, 1650}] = {msg = "A arvore tinha um ninho de vespas nela!", summon = "Wasp"}, 
	[{1651, 1750}] = {msg = "Voce se machucou ao cortar a arvore", damage = {3, 30}}, 
	[{1751, 2000}] = {msg = "Voce cortou a arvore e pegou um pouco de madeira", item = 5901, amountmin = 4, amountmax = 7}, 
	[{2001, 2250}] = {msg = "Uma aranha caiu no seu ombro.", summon = "Spider"}, 
	[{2251, 2500}] = {msg = "Voce encontrou um ninho na arvore.", item = 2695, amountmin = 1, amountmax = 3},
	[{2501, 2750}] = {msg = "TESTE", item = 0, amountmin = 10, amountmax = 50},
	[{2751, 3000}] = {msg = "Um rato pulou em voce!", summon = "Rat"}
}

-- Tabela para definir o loot garantido (fruta + madeira) das arvores que DESTRUEM
local fixedLoot = {
    -- MAPA DE ARVORES FRUTÍFERAS (CHEIAS e VAZIAS)
    -- ID_CHEIA: Loot com Fruta e Madeira
    [4006] = {fruit = 2675, minF = 3, maxF = 6, minW = 2, maxW = 5, emptyId = 4008}, 
    [5094] = {fruit = 2676, minF = 3, maxF = 6, minW = 2, maxW = 5, emptyId = 5092}, 
    [5096] = {fruit = 2678, minF = 1, maxF = 3, minW = 1, maxW = 4, emptyId = 2726}, 
    [5157] = {fruit = 5097, minF = 4, maxF = 8, minW = 3, maxW = 6, emptyId = 5156}, 
    
    -- ID_VAZIA: Loot APENAS com Madeira (o item 'fruit' é null)
    [4008] = {minW = 2, maxW = 5}, 
    [5092] = {minW = 2, maxW = 5}, 
    [2726] = {minW = 1, maxW = 4}, 
    [5156] = {minW = 3, maxW = 6},
    
    -- Outras Árvores Destrutíveis (Exemplo: Arvore de Ovos)
    [2786] = {fruit = 2695, minF = 1, maxF = 2, minW = 1, maxW = 3}
}


-- FUNCAO DE RESPAWN
function newTrees(parameter)
    local pos = parameter.position
    local originalTreeId = parameter.originalTreeId
    local branchId = config.branches

    local branch = getThingfromPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 2})
	
    if not branch or branch.itemid ~= branchId then
        for i = 1, 255 do
            branch = getThingfromPos({x = pos.x, y = pos.y, z = pos.z, stackpos = i})
            if branch and branch.itemid == branchId then
                break 
            elseif not branch.itemid or i == 255 then
                return true 
            end
        end
    end

    if branch and branch.itemid == branchId then
		doRemoveItem(branch.uid) 
		doCreateItem(originalTreeId, 1, pos) 
	end
end	

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local originalTreeId = itemEx.itemid

    local all_trees = table.join(config.trees_to_stump, config.trees_to_destroy)

	if not isInArray(all_trees, originalTreeId) or getPlayerLevel(cid) < config.level or getPlayerSkill(cid, config.skill) < config.skillReq or getPlayerSoul(cid) < config.soul then
        return doPlayerSendCancel(cid, "Ou esta arvore nao pode ser cortada ou voce nao tem experiencia, skill ou soul suficiente para cortar esta arvore.")
    end

    local v, amount = math.random(3000), 1
    for i, k in pairs(t) do
        if v >= i[1] and v <= i[2] then
            
            if k.destroy then
                doRemoveItem(item.uid)
            end
            
            if k.summon then
                doSummonCreature(k.summon, toPosition)
            end
            
            if k.damage then
                local damage = math.random(k.damage[1], k.damage[2])
                doCreatureAddHealth(cid, -damage)
                doSendMagicEffect(getThingPos(cid), CONST_ME_DRAWBLOOD)
            end
            
            if k.item then
                if k.amountmin and k.amountmax then
                    amount = math.random(k.amountmin, k.amountmax)
                elseif k.amountmax then 
                    amount = math.random(k.amountmax)
                end
                doPlayerAddItem(cid, k.item, amount) 
            end
            
            if k.msg then
                doPlayerSendTextMessage(cid, config.msgType, k.msg)
            end
            
            -- LÓGICA DE TRANSFORMAÇÃO E LOOT
            if isInArray(config.trees_to_stump, originalTreeId) then
                -- Se a arvore deve virar toco (com respawn)
                local respawnMs = config.minutes * 60 * 1000
                addEvent(newTrees, respawnMs, {position = toPosition, cid = cid, originalTreeId = originalTreeId})	
                doTransformItem(itemEx.uid, config.branches)
            elseif isInArray(config.trees_to_destroy, originalTreeId) then
                -- Se a arvore deve ser destruida (sem respawn)
                
                local loot = fixedLoot[originalTreeId]
                
                if loot then
                    local wood_id = 5901
                    
                    -- Lógica de ADICIONAR FRUTA (só se o ID da fruta estiver mapeado)
                    if loot.fruit then
                        local fruit_count = math.random(loot.minF, loot.maxF)
                        doPlayerAddItem(cid, loot.fruit, fruit_count) -- ADICIONA AO INVENTÁRIO
                        
                        -- Mensagem específica para frutas
                        doPlayerSendTextMessage(cid, config.msgType, "Voce destruiu a arvore e coletou frutos e madeira.")
                    else
                        -- Mensagem para apenas madeira
                         doPlayerSendTextMessage(cid, config.msgType, "Voce destruiu a arvore e coletou madeira.")
                    end
                    
                    -- ADICIONAR MADEIRA (sempre)
                    local wood_count = math.random(loot.minW, loot.maxW)
                    doPlayerAddItem(cid, wood_id, wood_count) -- ADICIONA AO INVENTÁRIO
                end
                
                -- Se for uma árvore frutífera (cheia ou vazia), agendar o respawn da árvore CHEIA
                local fruit_tree_config = fixedLoot[originalTreeId]
                if fruit_tree_config and fruit_tree_config.emptyId then
                    -- Se a arvore cortada for a VAZIA (4008, 5092, etc), usamos o ID CHEIO (4006, 5094) para respawn
                    local fullTreeId = originalTreeId
                    for full, conf in pairs(fixedLoot) do
                        if conf.emptyId == originalTreeId then
                            fullTreeId = full
                            break
                        end
                    end
                    
                    local respawnMs = 60 * 60 * 1000 -- 1 hora (60 minutos) de respawn
                    addEvent(doCreateItem, respawnMs, fullTreeId, 1, toPosition)
                end
                
                doRemoveItem(itemEx.uid)
            end
            
            -- Finaliza a acao
            doPlayerAddSoul(cid, -config.soul)
            doSendMagicEffect(toPosition, k.destroy and CONST_ME_HITAREA or config.effect)	
            return doPlayerAddSkillTry(cid, config.skill, config.addTries)
        end
    end

    return true
end

-- OBS: Funcao auxiliar para juntar tabelas
function table.join(table1, table2)
    local result = {}
    for i, v in ipairs(table1) do
        result[#result + 1] = v
    end
    for i, v in ipairs(table2) do
        result[#result + 1] = v
    end
    return result
end