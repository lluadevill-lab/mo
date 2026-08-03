local MARKER_ON = 22869
local MARKER_OFF = 22868

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local pos = item:getPosition()
    
    -- MODO: ATIVAR (Transforma o item desativado no ativado e registra)
    if item:getId() == MARKER_OFF then
        item:transform(MARKER_ON)
        
        -- Garante que não haja duplicatas antes de inserir
        db.query(string.format("DELETE FROM `barn_markers` WHERE `x` = %d AND `y` = %d AND `z` = %d", pos.x, pos.y, pos.z))
        db.query(string.format("INSERT INTO `barn_markers` (`x`, `y`, `z`) VALUES (%d, %d, %d)", pos.x, pos.y, pos.z))
        
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Celeiro ATIVADO. Area 10x10 foi salva.")
        pos:sendMagicEffect(CONST_ME_MAGIC_GREEN)
        
    -- MODO: DESATIVAR (Transforma no desativado e apaga tudo da DB)
    elseif item:getId() == MARKER_ON then
        item:transform(MARKER_OFF)
        
        -- Remove o marcador da lista de monitoramento
        db.query(string.format("DELETE FROM `barn_markers` WHERE `x` = %d AND `y` = %d AND `z` = %d", pos.x, pos.y, pos.z))
        
        -- Limpa a memória de itens e monstros (incluindo andares superiores)
        db.query(string.format("DELETE FROM `barn_env` WHERE `marker_x` = %d AND `marker_y` = %d AND `marker_z` = %d", pos.x, pos.y, pos.z))
        db.query(string.format("DELETE FROM `barn_system` WHERE `pos_x` BETWEEN %d AND %d AND `pos_y` BETWEEN %d AND %d AND `pos_z` <= %d", pos.x-5, pos.x+5, pos.y-5, pos.y+5, pos.z))
        
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Celeiro DESATIVADO. Area 10x10 foi esquecida.")
        pos:sendMagicEffect(CONST_ME_POISON)
    end
    
    return true
end