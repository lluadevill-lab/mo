--[[
      Ultimate House Builder Opener
      Abre a janela de criação ao usar um item.
]]--

-- O ID do item que deve abrir a interface
local HOUSE_BUILDER_ID = 8822

-- Tenta carregar a biblioteca diretamente (CORREÇÃO)
-- Se estiver em data/lib/housebuilder.lua, use o caminho abaixo
dofile("data/lib/housebuilder.lua")

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Certifique-se de que a função foi carregada
    if not _G.HouseBuilderOpen then
        player:sendCancelMessage("Erro: A função de construção não está disponível. Verifique 'data/lib/housebuilder.lua'.")
        return false
    end

    -- Chama a função principal da biblioteca
    HouseBuilderOpen(player)
    
    return true
end