function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not SKILL_UPGRADE then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Erro: Lib nao carregada.")
        return true
    end
    
    player:sendSkillUpgradeWindow()
    return true
end