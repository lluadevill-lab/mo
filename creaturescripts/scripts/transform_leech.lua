local LEECH_PERCENTAGE = 0.10 -- 10% de cura
local LEACHING_LOOKTYPES = {27, 3, 308} -- Wolf, War Wolf, Werewolf

-- Função auxiliar simples para checar tabela
local function hasValue(tab, val)
    for _, v in ipairs(tab) do
        if v == val then return true end
    end
    return false
end

-- Tente usar onTargetCombat (roda no atacante)
function onTargetCombat(creature, target)
    return RETURNVALUE_NOERROR
end

-- Se seu servidor for TFS 1.2/1.3 padrão, a função que pega o dano pode ser esta:
function onHealthChange(creature, attacker, primaryDamage, secondaryDamage, origin)
    -- Se registrado no MONSTRO, 'creature' é o monstro e 'attacker' é você.
    -- Se registrado no PLAYER (login.lua), 'creature' é você (não serve pra leech de ataque).
    
    -- Vamos focar na lógica que você pediu: Recalcular e curar.
    if not attacker or not attacker:isPlayer() then
        return primaryDamage, secondaryDamage, origin
    end

    if primaryDamage <= 0 then
        return primaryDamage, secondaryDamage, origin
    end

    local outfit = attacker:getOutfit()
    if hasValue(LEACHING_LOOKTYPES, outfit.lookType) then
        local healAmount = math.ceil(primaryDamage * LEECH_PERCENTAGE)
        
        if healAmount > 0 then
            -- Aplica a cura usando addHealth (método direto e seguro para TFS 1.2)
            attacker:addHealth(healAmount)
            attacker:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
            -- Envia apenas para o jogador para não spamar a tela de todo mundo
            attacker:sendTextMessage(MESSAGE_EXPERIENCE, "+"..healAmount, attacker:getPosition(), healAmount, TEXTCOLOR_GREEN)
        end
    end

    return primaryDamage, secondaryDamage, origin
end