function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Envia o comando para o OTClient tocar o som
    -- O script rc_effects.lua vai procurar em 'effects/fire.ogg'
    playClientSound(player, "fire.ogg", 100) -- 100 é o volume

    -- Efeito visual só para confirmar que clicou (opcional)
    player:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Som de fogo ativado!")
    
    return true
end