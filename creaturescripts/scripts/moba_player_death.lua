function onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
    if not MOBA.matchActive then return true end
    
    -- Se quem matou foi um jogador
    if killer and killer:isPlayer() and killer:getId() ~= player:getId() then
        local reward = MOBA.REWARDS.PLAYER_KILL
        
        killer:addItem(2148, reward) -- Gold Coin
        killer:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Voce matou " .. player:getName() .. "! +" .. reward .. " gold!")
        
        -- Efeito visual
        killer:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
    end
    
    -- Reseta skull ao morrer? Opcional
    -- player:setSkull(SKULL_NONE)
    
    return true
end