function onAdvance(player, skill, oldLevel, newLevel)
    -- Só processa level (não magic level ou outras skills)
    if skill ~= SKILL_LEVEL then
        return true
    end
    
    -- Calcula quantos níveis subiu
    local levelsGained = newLevel - oldLevel
    
    if levelsGained <= 0 then
        return true
    end
    
    -- Calcula pontos a receber
    local pointsToAdd = levelsGained * SKILL_UPGRADE.POINTS_PER_LEVEL
    
    -- Adiciona os pontos
    player:addSkillPoints(pointsToAdd)
    
    -- Notifica o jogador
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voce ganhou " .. pointsToAdd .. " pontos de habilidade! (Total: " .. player:getSkillPoints() .. ")")
    
    -- Efeito visual
    player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    
    return true
end