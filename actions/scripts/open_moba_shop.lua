function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if OpenMobaShop then
        -- Passamos a posição do item clicado
        OpenMobaShop(player, fromPosition)
    else
        player:sendCancelMessage("A loja ainda nao foi carregada. De /reload creaturescripts")
    end
    return true
end