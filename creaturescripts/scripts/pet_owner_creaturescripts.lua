-- CREATURESCRIPT: PET OWNER HANDLER
-- Gerencia ciclo de vida dos pets no login/logout/morte

function onLogin(player)
    for _, event in pairs({"PetOwnerLogout", "PetOwnerDeath"}) do
        player:registerEvent(event)
    end
    player:openChannel(PETS.CHANNELID)

    -- Garante registro do modal
    player:registerEvent("PetModalHandler")

    local petUid = player:getPetUid()
    if petUid > 0 then
        local pet = Creature(petUid)
        if not pet or not pet:isCreature() then
            player:setPetUid(PETS.CONSTANS.STATUS_OK)
        end
    end

    return true
end


function onLogout(player)
    -- Remove pet ativo se existir
    local petUid = player:getPetUid()
    if petUid > 0 then
        local pet = Creature(petUid)
        if pet and pet:isCreature() then
            pet:remove()
        end
    end
    player:setPetUid(PETS.CONSTANS.STATUS_OK)
    return true
end

function onPrepareDeath(creature, killer)
    -- Quando o jogador morre, mata o pet vinculado
    local petUid = creature:getPetUid()
    if petUid > 0 then
        local pet = Creature(petUid)
        if pet and pet:isCreature() then
            pet:remove()
        end
    end
    creature:setPetUid(PETS.CONSTANS.STATUS_OK)
    return true
end
