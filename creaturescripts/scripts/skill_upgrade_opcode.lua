local OPCODE = 105

function onExtendedOpcode(player, opcode, buffer)
    if opcode ~= OPCODE then return false end
    
    local action = buffer:match('"action"%s*:%s*"([^"]+)"')
    local skillType = buffer:match('"type"%s*:%s*"([^"]+)"')
    local skillId = tonumber(buffer:match('"id"%s*:%s*(%d+)'))
    
    if action == "UPGRADE" and skillId then
        local configTable = skillType == "skills" and SKILL_UPGRADE.SKILLS or SKILL_UPGRADE.ATTRIBUTES
        local skillInfo = configTable and configTable[skillId]
        
        if not skillInfo then
            player:sendExtendedOpcode(OPCODE, '{"action":"ERROR","message":"Skill invalida."}')
            return true
        end
        
        -- Verifica se já está no máximo
        if skillInfo.max and skillInfo.max > 0 then
            local currentVal = skillInfo.get(player)
            if currentVal >= skillInfo.max then
                player:sendExtendedOpcode(OPCODE, '{"action":"ERROR","message":"' .. skillInfo.name .. ' já está no máximo!"}')
                return true
            end
        end
        
        local cost = skillInfo.getCost(player, skillInfo)
        if player:getSkillPoints() < cost then
            player:sendExtendedOpcode(OPCODE, '{"action":"ERROR","message":"Pontos insuficientes!"}')
            return true
        end
        
        local gain = skillInfo.apply(player, skillInfo.gain)
        player:setSkillPoints(player:getSkillPoints() - cost)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
        
        -- Reenvia a janela atualizada
        player:sendSkillUpgradeWindow()
    end
    
    return true
end