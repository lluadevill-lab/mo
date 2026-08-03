-- === SISTEMA DE LIBERACAO DE DESTINOS === --
local STORAGE_CAVERNA   = 51000
local STORAGE_PRAIA     = 51001
local STORAGE_MONTANHA  = 51002

function onUse(cid, item, fromPosition, target, toPosition, isHotkey)
    local player = Player(cid)

    -- Detecta qual altar o player esta usando
    local uid = item.uid
    local destinoStorage = nil
    local destinoNome = ""

    if uid == 29998 then
        destinoStorage = STORAGE_CAVERNA
        destinoNome = "Caverna"
    elseif uid == 29999 then
        destinoStorage = STORAGE_PRAIA
        destinoNome = "Praia"
    elseif uid == 29997 then
        destinoStorage = STORAGE_MONTANHA
        destinoNome = "Montanha"
    end

    -- Se o UID nao estiver configurado
    if not destinoStorage then
        player:sendCancelMessage("Erro: este altar nao esta configurado.")
        return true
    end

    -- PRIMEIRA VEZ -> somente desbloqueia (sem abrir janela)
    if player:getStorageValue(destinoStorage) ~= 1 then
        player:setStorageValue(destinoStorage, 1)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Destino desbloqueado: " .. destinoNome .. "!")
        return true
    end

    -- Já liberado -> abrir a janela
    player:registerEvent("tpw")

    local modal = ModalWindow(1901, "Viagem rapida", "Escolha o destino:")

    -- Adiciona somente destinos liberados
    if player:getStorageValue(STORAGE_CAVERNA) == 1 then
        modal:addChoice(1, "Caverna")
    end
    if player:getStorageValue(STORAGE_PRAIA) == 1 then
        modal:addChoice(2, "Praia")
    end
    if player:getStorageValue(STORAGE_MONTANHA) == 1 then
        modal:addChoice(3, "Montanha")
    end

    if modal:getChoiceCount() == 0 then
        modal:setMessage("Voce ainda nao descobriu nenhum destino.")
    end

    modal:addButton(3, "Select")
    modal:setDefaultEnterButton(3)
    modal:addButton(4, "Cancel")
    modal:setDefaultEscapeButton(4)

    modal:sendToPlayer(player)
    return true
end
