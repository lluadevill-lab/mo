SKILL_UPGRADE = {
    OPCODE = 105,
    STORAGE = {
        POINTS = 62491,
        ADVANCE = 62492,
        SPEED_BONUS = 62504
    },
    POINTS_PER_LEVEL = 50
}

SKILL_UPGRADE.SKILLS = {
    [1] = {
        name = 'Health',
        base_cost = 5,
        gain = 15,
        get = function(player) return player:getMaxHealth() end,
        apply = function(player, gain)
            player:setMaxHealth(player:getMaxHealth() + gain)
            player:addHealth(gain)
            return gain
        end,
        getCost = function(player, info)
            return info.base_cost
        end
    },
    [2] = {
        name = 'Mana',
        base_cost = 5,
        gain = 15,
        get = function(player) return player:getMaxMana() end,
        apply = function(player, gain)
            player:setMaxMana(player:getMaxMana() + gain)
            player:addMana(gain)
            return gain
        end,
        getCost = function(player, info)
            return info.base_cost
        end
    },
    [3] = {
        name = 'Speed',
        base_cost = 10,
        cost_per_level = 2,
        gain = 5,
        get = function(player) 
            local bonus = player:getStorageValue(SKILL_UPGRADE.STORAGE.SPEED_BONUS)
            return bonus > 0 and bonus or 0
        end,
        apply = function(player, gain)
            local current = player:getStorageValue(SKILL_UPGRADE.STORAGE.SPEED_BONUS)
            if current < 0 then current = 0 end
            player:setStorageValue(SKILL_UPGRADE.STORAGE.SPEED_BONUS, current + gain)
            player:changeSpeed(gain)
            return gain
        end,
        getCost = function(player, info)
            local currentBonus = player:getStorageValue(SKILL_UPGRADE.STORAGE.SPEED_BONUS)
            if currentBonus < 0 then currentBonus = 0 end
            local upgrades = math.floor(currentBonus / 5)
            return info.base_cost + (upgrades * (info.cost_per_level or 0))
        end
    },
    [4] = {
        name = 'Magic',
        base_cost = 10,
        cost_per_level = 5,
        gain = 1,
        get = function(player) return player:getBaseMagicLevel() end,
        apply = function(player, gain)
            player:addMagicLevels(gain)
            return gain
        end,
        getCost = function(player, info)
            return info.base_cost + (player:getBaseMagicLevel() * (info.cost_per_level or 0))
        end
    },
    [5] = {
        name = 'Club',
        base_cost = 10,
        cost_per_level = 3,
        min_level = 10,
        gain = 1,
        get = function(player) return player:getEffectiveSkillLevel(SKILL_CLUB) end,
        apply = function(player, gain)
            player:addCombatSkillLevels(SKILL_CLUB, gain)
            return gain
        end,
        getCost = function(player, info)
            local lvl = player:getEffectiveSkillLevel(SKILL_CLUB)
            return info.base_cost + (math.max(0, lvl - (info.min_level or 0)) * (info.cost_per_level or 0))
        end
    },
    [6] = {
        name = 'Sword',
        base_cost = 10,
        cost_per_level = 3,
        min_level = 10,
        gain = 1,
        get = function(player) return player:getEffectiveSkillLevel(SKILL_SWORD) end,
        apply = function(player, gain)
            player:addCombatSkillLevels(SKILL_SWORD, gain)
            return gain
        end,
        getCost = function(player, info)
            local lvl = player:getEffectiveSkillLevel(SKILL_SWORD)
            return info.base_cost + (math.max(0, lvl - (info.min_level or 0)) * (info.cost_per_level or 0))
        end
    },
    [7] = {
        name = 'Axe',
        base_cost = 10,
        cost_per_level = 3,
        min_level = 10,
        gain = 1,
        get = function(player) return player:getEffectiveSkillLevel(SKILL_AXE) end,
        apply = function(player, gain)
            player:addCombatSkillLevels(SKILL_AXE, gain)
            return gain
        end,
        getCost = function(player, info)
            local lvl = player:getEffectiveSkillLevel(SKILL_AXE)
            return info.base_cost + (math.max(0, lvl - (info.min_level or 0)) * (info.cost_per_level or 0))
        end
    },
    [8] = {
        name = 'Distance',
        base_cost = 10,
        cost_per_level = 3,
        min_level = 10,
        gain = 1,
        get = function(player) return player:getEffectiveSkillLevel(SKILL_DISTANCE) end,
        apply = function(player, gain)
            player:addCombatSkillLevels(SKILL_DISTANCE, gain)
            return gain
        end,
        getCost = function(player, info)
            local lvl = player:getEffectiveSkillLevel(SKILL_DISTANCE)
            return info.base_cost + (math.max(0, lvl - (info.min_level or 0)) * (info.cost_per_level or 0))
        end
    },
    [9] = {
        name = 'Shielding',
        base_cost = 10,
        cost_per_level = 3,
        min_level = 10,
        gain = 1,
        get = function(player) return player:getEffectiveSkillLevel(SKILL_SHIELD) end,
        apply = function(player, gain)
            player:addCombatSkillLevels(SKILL_SHIELD, gain)
            return gain
        end,
        getCost = function(player, info)
            local lvl = player:getEffectiveSkillLevel(SKILL_SHIELD)
            return info.base_cost + (math.max(0, lvl - (info.min_level or 0)) * (info.cost_per_level or 0))
        end
    }
}

SKILL_UPGRADE.ATTRIBUTES = {
    [1] = {
        name = 'Life Leech Chance',
        base_cost = 5,
        cost_per_level = 2,
        gain = 1,
        max = 100,
        column = 'life_leech_chance',
        get = function(player)
            return player:getCustomSpecialSkill('life_leech_chance')
        end,
        apply = function(player, gain)
            local current = player:getCustomSpecialSkill('life_leech_chance')
            local newVal = math.min(current + gain, 100)
            player:setCustomSpecialSkill('life_leech_chance', newVal)
            player:updateSpecialSkillsToPlayer()
            return gain
        end,
        getCost = function(player, info)
            return info.base_cost + (player:getCustomSpecialSkill('life_leech_chance') * info.cost_per_level)
        end
    },
    [2] = {
        name = 'Life Leech Amount',
        base_cost = 5,
        cost_per_level = 2,
        gain = 1,
        max = 100,
        column = 'life_leech_amount',
        get = function(player)
            return player:getCustomSpecialSkill('life_leech_amount')
        end,
        apply = function(player, gain)
            local current = player:getCustomSpecialSkill('life_leech_amount')
            local newVal = math.min(current + gain, 100)
            player:setCustomSpecialSkill('life_leech_amount', newVal)
            player:updateSpecialSkillsToPlayer()
            return gain
        end,
        getCost = function(player, info)
            return info.base_cost + (player:getCustomSpecialSkill('life_leech_amount') * info.cost_per_level)
        end
    },
    [3] = {
        name = 'Mana Leech Chance',
        base_cost = 5,
        cost_per_level = 2,
        gain = 1,
        max = 100,
        column = 'mana_leech_chance',
        get = function(player)
            return player:getCustomSpecialSkill('mana_leech_chance')
        end,
        apply = function(player, gain)
            local current = player:getCustomSpecialSkill('mana_leech_chance')
            local newVal = math.min(current + gain, 100)
            player:setCustomSpecialSkill('mana_leech_chance', newVal)
            player:updateSpecialSkillsToPlayer()
            return gain
        end,
        getCost = function(player, info)
            return info.base_cost + (player:getCustomSpecialSkill('mana_leech_chance') * info.cost_per_level)
        end
    },
    [4] = {
        name = 'Mana Leech Amount',
        base_cost = 5,
        cost_per_level = 2,
        gain = 1,
        max = 100,
        column = 'mana_leech_amount',
        get = function(player)
            return player:getCustomSpecialSkill('mana_leech_amount')
        end,
        apply = function(player, gain)
            local current = player:getCustomSpecialSkill('mana_leech_amount')
            local newVal = math.min(current + gain, 100)
            player:setCustomSpecialSkill('mana_leech_amount', newVal)
            player:updateSpecialSkillsToPlayer()
            return gain
        end,
        getCost = function(player, info)
            return info.base_cost + (player:getCustomSpecialSkill('mana_leech_amount') * info.cost_per_level)
        end
    },
    [5] = {
        name = 'Critical Chance',
        base_cost = 10,
        cost_per_level = 5,
        gain = 1,
        max = 100,
        column = 'critical_chance',
        get = function(player)
            return player:getCustomSpecialSkill('critical_chance')
        end,
        apply = function(player, gain)
            local current = player:getCustomSpecialSkill('critical_chance')
            local newVal = math.min(current + gain, 100)
            player:setCustomSpecialSkill('critical_chance', newVal)
            player:updateSpecialSkillsToPlayer()
            return gain
        end,
        getCost = function(player, info)
            return info.base_cost + (player:getCustomSpecialSkill('critical_chance') * info.cost_per_level)
        end
    },
    [6] = {
        name = 'Critical Damage',
        base_cost = 10,
        cost_per_level = 5,
        gain = 5,
        max = 200,
        column = 'critical_damage',
        get = function(player)
            return player:getCustomSpecialSkill('critical_damage')
        end,
        apply = function(player, gain)
            local current = player:getCustomSpecialSkill('critical_damage')
            local newVal = math.min(current + gain, 200)
            player:setCustomSpecialSkill('critical_damage', newVal)
            player:updateSpecialSkillsToPlayer()
            return gain
        end,
        getCost = function(player, info)
            return info.base_cost + (math.floor(player:getCustomSpecialSkill('critical_damage') / 5) * info.cost_per_level)
        end
    }
}

-- ============================================
-- FUNÇÕES DE PONTOS
-- ============================================

function Player:getSkillPoints()
    local pts = self:getStorageValue(SKILL_UPGRADE.STORAGE.POINTS)
    return pts > 0 and pts or 0
end

function Player:setSkillPoints(amount)
    return self:setStorageValue(SKILL_UPGRADE.STORAGE.POINTS, math.max(0, amount))
end

function Player:addSkillPoints(amount)
    return self:setSkillPoints(self:getSkillPoints() + amount)
end

-- ============================================
-- FUNÇÕES DE SKILLS DE COMBATE
-- ============================================

function Player:addCombatSkillLevels(skill, count)
    count = math.max(1, count or 1)
    for i = 1, count do
        local currentLevel = self:getEffectiveSkillLevel(skill)
        local xp = math.ceil(self:getVocation():getRequiredSkillTries(skill, currentLevel + 1) / configManager.getNumber(configKeys.RATE_SKILL))
        self:addSkillTries(skill, xp + 1)
    end
    return true
end

function Player:addMagicLevels(count)
    count = math.max(1, count or 1)
    for i = 1, count do
        local xp = math.ceil(self:getVocation():getRequiredManaSpent(self:getBaseMagicLevel() + 1) / configManager.getNumber(configKeys.RATE_MAGIC))
        self:addManaSpent(xp + 1)
    end
    return true
end

-- ============================================
-- FUNÇÕES DE SPECIAL SKILLS (TABELA CUSTOM)
-- ============================================

function Player:ensureSpecialSkillsRow()
    local resultId = db.storeQuery("SELECT `player_id` FROM `player_special_skills` WHERE `player_id` = " .. self:getGuid())
    if resultId then
        result.free(resultId)
        return true
    end
    db.query("INSERT INTO `player_special_skills` (`player_id`) VALUES (" .. self:getGuid() .. ")")
    return true
end

function Player:getCustomSpecialSkill(columnName)
    self:ensureSpecialSkillsRow()
    local resultId = db.storeQuery("SELECT `" .. columnName .. "` FROM `player_special_skills` WHERE `player_id` = " .. self:getGuid())
    if not resultId then
        return 0
    end
    local value = result.getNumber(resultId, columnName)
    result.free(resultId)
    return value
end

function Player:setCustomSpecialSkill(columnName, value)
    self:ensureSpecialSkillsRow()
    db.query("UPDATE `player_special_skills` SET `" .. columnName .. "` = " .. value .. " WHERE `player_id` = " .. self:getGuid())
    return true
end

function Player:updateSpecialSkillsToPlayer()
    local critChance = self:getCustomSpecialSkill('critical_chance')
    local critDamage = self:getCustomSpecialSkill('critical_damage')
    local lifeLeechChance = self:getCustomSpecialSkill('life_leech_chance')
    local lifeLeechAmount = self:getCustomSpecialSkill('life_leech_amount')
    local manaLeechChance = self:getCustomSpecialSkill('mana_leech_chance')
    local manaLeechAmount = self:getCustomSpecialSkill('mana_leech_amount')
    
    -- Atualiza tabela players (para o client ver)
    db.query(string.format([[
        UPDATE `players` SET 
            `skill_critical_hit_chance` = %d,
            `skill_critical_hit_damage` = %d,
            `skill_life_leech_chance` = %d,
            `skill_life_leech_amount` = %d,
            `skill_mana_leech_chance` = %d,
            `skill_mana_leech_amount` = %d
        WHERE `id` = %d
    ]], critChance, critDamage, lifeLeechChance, lifeLeechAmount, manaLeechChance, manaLeechAmount, self:getGuid()))
    
    -- Remove condition antiga
    self:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, 100)
    
    -- Se não tem nada, não aplica condition
    if critChance == 0 and critDamage == 0 and lifeLeechChance == 0 and lifeLeechAmount == 0 and manaLeechChance == 0 and manaLeechAmount == 0 then
        return true
    end
    
    -- Cria condition
    local condition = Condition(CONDITION_ATTRIBUTES)
    condition:setParameter(CONDITION_PARAM_TICKS, -1)
    condition:setParameter(CONDITION_PARAM_SUBID, 100)
    
    if critChance > 0 then
        condition:setParameter(CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE, critChance)
    end
    if critDamage > 0 then
        condition:setParameter(CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE, critDamage)
    end
    if lifeLeechChance > 0 then
        condition:setParameter(CONDITION_PARAM_SKILL_LIFE_LEECH_CHANCE, lifeLeechChance)
    end
    if lifeLeechAmount > 0 then
        condition:setParameter(CONDITION_PARAM_SKILL_LIFE_LEECH_AMOUNT, lifeLeechAmount)
    end
    if manaLeechChance > 0 then
        condition:setParameter(CONDITION_PARAM_SKILL_MANA_LEECH_CHANCE, manaLeechChance)
    end
    if manaLeechAmount > 0 then
        condition:setParameter(CONDITION_PARAM_SKILL_MANA_LEECH_AMOUNT, manaLeechAmount)
    end
    
    self:addCondition(condition)
    
    return true
end

function Player:loadSpecialSkillsOnLogin()
    -- Carrega da tabela custom e aplica
    self:updateSpecialSkillsToPlayer()
    
    -- Speed bonus
    local speedBonus = self:getStorageValue(SKILL_UPGRADE.STORAGE.SPEED_BONUS)
    if speedBonus > 0 then
        self:changeSpeed(speedBonus)
    end
    
    return true
end

-- ============================================
-- ABRIR JANELA
-- ============================================

function Player:sendSkillUpgradeWindow()
    local skillsParts = {}
    for id, info in ipairs(SKILL_UPGRADE.SKILLS) do
        local value = info.get(self)
        local cost = info.getCost(self, info)
        table.insert(skillsParts, '{"id":' .. id .. ',"name":"' .. info.name .. '","value":' .. value .. ',"cost":' .. cost .. ',"max":0}')
    end
    
    local attrParts = {}
    for id, info in ipairs(SKILL_UPGRADE.ATTRIBUTES) do
        local currentVal = info.get(self)
        local maxVal = info.max or 999
        local cost = info.getCost(self, info)
        local isMaxed = currentVal >= maxVal
        local displayName = info.name .. " (" .. currentVal .. "/" .. maxVal .. "%)"
        table.insert(attrParts, '{"id":' .. id .. ',"name":"' .. displayName .. '","value":' .. currentVal .. ',"cost":' .. cost .. ',"max":' .. maxVal .. ',"isMaxed":' .. (isMaxed and 'true' or 'false') .. '}')
    end
    
    local response = '{"action":"OPEN","points":' .. self:getSkillPoints() .. ',"skills":[' .. table.concat(skillsParts, ',') .. '],"attributes":[' .. table.concat(attrParts, ',') .. ']}'
    self:sendExtendedOpcode(SKILL_UPGRADE.OPCODE, response)
    return true
end