local OPCODE_MOBA = 108
local COOLDOWN_STORAGE_BASE = 60100

--[[
    ESTRUTURA OBRIGATÓRIA DA TABELA:
    {
        type = "rune" ou "spell",
        itemId = ID do item que desbloqueia,
        runeId = ID da runa (OBRIGATÓRIO SE type="rune"),
        ...
    }
]]

local CLASS_SKILLS = {
    -- Sorcerer (Voc 1 e 5)
    [1] = {
        {
            type = "spell",
            itemId = 2160,
            storage = 0,
            words = "exori vis",
            runeId = 0,
            useType = "target",
            name = "Energy Strike",
            cooldown = 0,
            icon = "sorcerer_1"
        },
        {
            type = "spell",
            itemId = 2160,
            storage = 0,
            words = "exevo flam hur",
            runeId = 0,
            useType = "self",
            name = "Fire Wave",
            cooldown = 0,
            icon = "sorcerer_2"
        },
        {
            type = "rune",
            itemId = 2311,
            storage = 0,
            words = "",
            runeId = 2311,          -- GARANTA QUE ESTE CAMPO EXISTE
            useType = "target",
            name = "HMM",
            cooldown = 0,
            icon = "sorcerer_3"
        },
        {
            type = "rune",
            itemId = 2268,
            storage = 0,
            words = "",
            runeId = 2268,          -- GARANTA QUE ESTE CAMPO EXISTE
            useType = "target",
            name = "SD",
            cooldown = 0,
            icon = "sorcerer_4"
        }
    }
    
    -- (Adicione as outras vocações se precisar)
}

-- Mapeia promoções para a vocação base 1
CLASS_SKILLS[5] = CLASS_SKILLS[1]
CLASS_SKILLS[0] = CLASS_SKILLS[1] -- Para testes

---------------------------------------------------------

local function getPlayerSkills(player)
    local voc = player:getVocation():getId()
    return CLASS_SKILLS[voc] or CLASS_SKILLS[0]
end

local function isSkillAvailable(player, skill)
    if skill.type == "rune" then
        return player:getItemCount(skill.runeId) > 0
    end
    
    if skill.itemId > 0 and player:getItemCount(skill.itemId) > 0 then
        return true
    end
    
    return false
end

local function getCooldownRemaining(player, slotNum)
    local cooldownStorage = COOLDOWN_STORAGE_BASE + slotNum
    local cooldownEnd = player:getStorageValue(cooldownStorage)
    local now = os.mtime()
    
    if cooldownEnd and cooldownEnd > 0 then
        return math.max(0, cooldownEnd - now)
    end
    return 0
end

local function sendUpdate(player)
    local skills = getPlayerSkills(player)
    if not skills then return end
    
    local data = "UPDATE:"
    
    for i = 1, 4 do
        local skill = skills[i]
        if skill then
            local available = isSkillAvailable(player, skill)
            local remainingCd = getCooldownRemaining(player, i)
            local rId = skill.runeId or 0
            
            -- CORREÇÃO: Se words for vazio, envia "_" para não quebrar o split do cliente
            local safeWords = (skill.words and skill.words ~= "") and skill.words or "_"
            
            print(string.format("[MOBA SERVER] Slot %d: %s (Words: %s, RuneID: %d)", i, skill.name, safeWords, rId))
            
            -- Formato: slot|name|icon|type|available|words|runeId|useType|cooldown|remainingCd|
            data = data .. string.format("%d|%s|%s|%s|%d|%s|%d|%s|%d|%d|",
                i,
                skill.name,
                skill.icon,
                skill.type,
                available and 1 or 0,
                safeWords,              -- Usando a string segura
                rId,
                skill.useType or "target",
                skill.cooldown or 0,
                remainingCd
            )
        end
    end
    
    player:sendExtendedOpcode(OPCODE_MOBA, data)
end

function onExtendedOpcode(player, opcode, buffer)
    if opcode ~= OPCODE_MOBA then return false end
    
    if buffer == "REQUEST" then
        sendUpdate(player)
    end
    
    return true
end

function onLogin(player)
    player:registerEvent("MobaOpcode")
    addEvent(function()
        local p = Player(player:getName())
        if p then sendUpdate(p) end
    end, 1500)
    return true
end