dofile("data/lib/house_builder.lua")

function onUse(player, item, fromPosition, itemEx, toPosition, isHotkey)
    if not HOUSE_BUILDER then
        player:sendCancelMessage("Erro: A biblioteca HOUSE_BUILDER nao foi carregada.")
        return false
    end
    
    HOUSE_BUILDER.showMainWindow(player)
    return false
end