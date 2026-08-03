-- slot.lua (versão segura para TFS 1.2)
-- Requer: creaturescripts.xml com <event type="login" name="SlotLogin" script="slot.lua"/>

local MAX_PERCENT = 100
local CHECK_DELAY = 2000

-- pre-cria conditions (1..100) uma vez
local conditionHP, conditionMP, conditionML, conditionCLUB, conditionSHI, conditionDIST = {},{},{},{},{},{}
for i = 1, 100 do
    -- HP
    conditionHP[i] = createConditionObject(CONDITION_ATTRIBUTES)
    setConditionParam(conditionHP[i], CONDITION_PARAM_TICKS, -1)
    setConditionParam(conditionHP[i], CONDITION_PARAM_STAT_MAXHEALTHPERCENT, 100 + i)
    setConditionParam(conditionHP[i], CONDITION_PARAM_BUFF, true)
    setConditionParam(conditionHP[i], CONDITION_PARAM_SUBID, 50)

    -- MP
    conditionMP[i] = createConditionObject(CONDITION_ATTRIBUTES)
    setConditionParam(conditionMP[i], CONDITION_PARAM_TICKS, -1)
    setConditionParam(conditionMP[i], CONDITION_PARAM_STAT_MAXMANAPERCENT, 100 + i)
    setConditionParam(conditionMP[i], CONDITION_PARAM_BUFF, true)
    setConditionParam(conditionMP[i], CONDITION_PARAM_SUBID, 51)

    -- ML
    conditionML[i] = createConditionObject(CONDITION_ATTRIBUTES)
    setConditionParam(conditionML[i], CONDITION_PARAM_TICKS, -1)
    setConditionParam(conditionML[i], CONDITION_PARAM_STAT_MAGICLEVELPERCENT, 100 + i)
    setConditionParam(conditionML[i], CONDITION_PARAM_BUFF, true)
    setConditionParam(conditionML[i], CONDITION_PARAM_SUBID, 52)

    -- club/sword/axe
    conditionCLUB[i] = createConditionObject(CONDITION_ATTRIBUTES)
    setConditionParam(conditionCLUB[i], CONDITION_PARAM_TICKS, -1)
    setConditionParam(conditionCLUB[i], CONDITION_PARAM_SKILL_CLUBPERCENT, 100 + i)
    setConditionParam(conditionCLUB[i], CONDITION_PARAM_SKILL_SWORDPERCENT, 100 + i)
    setConditionParam(conditionCLUB[i], CONDITION_PARAM_SKILL_AXEPERCENT, 100 + i)
    setConditionParam(conditionCLUB[i], CONDITION_PARAM_BUFF, true)
    setConditionParam(conditionCLUB[i], CONDITION_PARAM_SUBID, 53)

    -- shield
    conditionSHI[i] = createConditionObject(CONDITION_ATTRIBUTES)
    setConditionParam(conditionSHI[i], CONDITION_PARAM_TICKS, -1)
    setConditionParam(conditionSHI[i], CONDITION_PARAM_SKILL_SHIELDPERCENT, 100 + i)
    setConditionParam(conditionSHI[i], CONDITION_PARAM_BUFF, true)
    setConditionParam(conditionSHI[i], CONDITION_PARAM_SUBID, 54)

    -- dist
    conditionDIST[i] = createConditionObject(CONDITION_ATTRIBUTES)
    setConditionParam(conditionDIST[i], CONDITION_PARAM_TICKS, -1)
    setConditionParam(conditionDIST[i], CONDITION_PARAM_SKILL_DISTANCEPERCENT, 100 + i)
    setConditionParam(conditionDIST[i], CONDITION_PARAM_BUFF, true)
    setConditionParam(conditionDIST[i], CONDITION_PARAM_SUBID, 55)
end

-- extrai conteúdo do primeiro [ ... ] (usado para ler slot em item name)
local function extractFirstBracket(text)
    if not text then return nil end
    local inside = text:match("%[(.-)%]")
    return inside
end

-- retorna slotType, sinal, quantidade a partir de uma tag tipo: hp.+2%
local function parseSlotTag(tag)
    if not tag then return nil end
    -- formato esperado: name.xx+yy% ou hp.+2%
    local stat, sign, qty = tag:match("(.-)%.([%+%-])(%d+)%%")
    if stat and sign and qty then
        return stat, sign, tonumber(qty)
    end
    return nil
end

-- carrega os nomes dos itens equipados nas posições 1..9 (player slots)
local function loadSet(player)
    local t = {}
    for slot = 1, 9 do
        t[slot] = ""
        local it = player:getSlotItem(slot)
        if it and it:isContainer() == false then
            t[slot] = it:getName()
        end
    end
    return t
end

-- Verifica se valor existe no array (simples)
local function isInArray(arr, val)
    if not arr then return false end
    for _, v in pairs(arr) do
        if v == val then return true end
    end
    return false
end

-- checa slot 5 e 6 (head, necklace, etc) -- adaptado para não usar items.xml
local function checkSlotType(player, slot)
    -- se quiser regras específicas por slot, implemente aqui.
    -- por enquanto, aceita tudo (compatível com a maioria dos servers)
    return true
end

-- função que aplica/removem conditions baseado nos slots atuais
local function equip(player, changedItem, changedSlot)
    if not player or not player:isPlayer() then return true end

    local currentHP = player:getHealth()
    local currentMP = player:getMana()

    local totals = {} -- tabela totals[stat] = valor
    for i = 1, 9 do
        if i ~= changedSlot then
            local it = player:getSlotItem(i)
            if it and it:getId() ~= 0 and checkSlotType(player, i) then
                -- percorre todas as tags do nome do item
                for tag in it:getName():gmatch("%[(.-)%]") do
                    local stat, sign, qty = parseSlotTag(tag)
                    if stat and qty then
                        totals[stat] = (totals[stat] or 0) + qty
                        if totals[stat] > MAX_PERCENT then totals[stat] = MAX_PERCENT end
                    end
                end
            end
        end
    end

    -- aplica conditions e ações
    local present = {}
    for stat, val in pairs(totals) do
        present[stat] = true
        if stat == "hp" then
            doAddCondition(player:getId(), conditionHP[tonumber(val)])
            -- recalc HP: cur = currentHP; restore to max percent
            player:addHealth(player:getMaxHealth() - player:getHealth())
        elseif stat == "mp" then
            doAddCondition(player:getId(), conditionMP[tonumber(val)])
            player:addMana(player:getMaxMana() - player:getMana())
        elseif stat == "ml" then
            doAddCondition(player:getId(), conditionML[tonumber(val)])
        elseif stat == "cas" then
            doAddCondition(player:getId(), conditionCLUB[tonumber(val)])
        elseif stat == "shield" then
            doAddCondition(player:getId(), conditionSHI[tonumber(val)])
        elseif stat == "dist" then
            doAddCondition(player:getId(), conditionDIST[tonumber(val)])
        end
    end

    -- remove conditions não presentes
    local subStart = 50
    for i = 50, 55 do
        if not (present["hp"] and i == 50) and not (present["mp"] and i == 51)
           and not (present["ml"] and i == 52) and not (present["cas"] and i == 53)
           and not (present["shield"] and i == 54) and not (present["dist"] and i == 55) then
            doRemoveCondition(player:getId(), CONDITION_ATTRIBUTES, i)
        end
    end

    -- feedback para o jogador: opcional
    -- local s = ""
    -- for stat,val in pairs(totals) do s = s .. val .. "% more of " .. stat .. "\n" end
    -- if s ~= "" then player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have:\n" .. s) end

    return true
end

-- função chk: verifica se o equipamento mudou e reaplica
local function chk(playerId, lastSet)
    local player = Player(playerId)
    if not player or not player:isPlayer() then return end
    local newSet = loadSet(player)
    local different = false
    for i = 1, #newSet do
        if newSet[i] ~= (lastSet and lastSet[i]) then
            different = true
            break
        end
    end
    if different then
        equip(player, nil, nil)
    end
    -- reagenda
    addEvent(chk, CHECK_DELAY, playerId, newSet)
end

-- onLogin event
function onLogin(player)
    if not player or not player:isPlayer() then return false end
    -- aplica no login
    equip(player, nil, nil)
    -- agenda chk com a set atual
    local t = loadSet(player)
    addEvent(chk, CHECK_DELAY, player:getId(), t)
    return true
end
