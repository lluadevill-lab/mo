local pos1 = {x =1438, y =924, z =7} -- Praia
local pos2 = {x =1423, y =884, z =7} -- Caverna
local pos3 = {x =1438, y =884, z =5} -- Montanha

-- Storages dos destinos liberados
local STORAGE_CAVERNA   = 51000
local STORAGE_PRAIA     = 51001
local STORAGE_MONTANHA  = 51002

function onModalWindow(cid, modalWindowId, buttonId, choiceId)
    if modalWindowId ~= 1901 then
        return false
    end

    -- Botão cancelar
    if buttonId == 4 then
        return true
    end

    -- Caverna
    if choiceId == 1 then
        if getPlayerStorageValue(cid, STORAGE_CAVERNA) ~= 1 then
            doPlayerSendCancel(cid, "Voce ainda nao descobriu este destino.")
            return true
        end

        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voce chegou em: Caverna")
        doTeleportThing(cid, pos2, true)
        doSendMagicEffect(pos2, CONST_ME_TELEPORT)
        return true
    end

    -- Praia
    if choiceId == 2 then
        if getPlayerStorageValue(cid, STORAGE_PRAIA) ~= 1 then
            doPlayerSendCancel(cid, "Voce ainda nao descobriu este destino.")
            return true
        end

        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voce chegou em: Praia")
        doTeleportThing(cid, pos1, true)
        doSendMagicEffect(pos1, CONST_ME_TELEPORT)
        return true
    end

    -- Montanha
    if choiceId == 3 then
        if getPlayerStorageValue(cid, STORAGE_MONTANHA) ~= 1 then
            doPlayerSendCancel(cid, "Voce ainda nao descobriu este destino.")
            return true
        end

        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voce chegou em: Montanha")
        doTeleportThing(cid, pos3, true)
        doSendMagicEffect(pos3, CONST_ME_TELEPORT)
        return true
    end

    return true
end
