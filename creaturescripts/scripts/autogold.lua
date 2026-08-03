local GOLD_ITEM_ID = 2148

local MINION_VALUES = {
    ["dwarf"] = {assist = 10, last_hit = 50}, 
    ["dwarf soldier"] = {assist = 20, last_hit = 100},
    ["dwarf geomancer"] = {assist = 80, last_hit = 160},
    ["siege minion"] = {assist = 100, last_hit = 200},
    ["super minion"] = {assist = 150, last_hit = 300}
}

local function giveGold(player, amount, rewardType)
    if amount <= 0 then return end
    
    local inbox = player:getSlotItem(CONST_SLOT_STORE_INBOX)
    if inbox then 
        inbox:addItem(GOLD_ITEM_ID, amount) 
    else 
        player:addItem(GOLD_ITEM_ID, amount) 
    end
    
    if playClientSound then 
        playClientSound(player, "gold.ogg", 100) 
    end
    
    if rewardType == "LAST HIT" then
        player:say("LAST HIT! +"..amount, TALKTYPE_MONSTER_SAY)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
    else
        player:say("ASSIST +"..amount, TALKTYPE_MONSTER_YELL)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end
    
    player:sendTextMessage(MESSAGE_INFO_DESCR, "+ " .. amount .. " G (" .. rewardType .. ").")
end

function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
    if not creature:isMonster() then return true end
    if not MOBA or not MOBA.matchActive then return true end
    
    local cid = creature:getId()
    local minionName = creature:getName():lower()
    local minionSkull = creature:getSkull()
    
    if minionSkull == SKULL_NONE then return true end
    
    -- Busca valores de recompensa
    local values = MINION_VALUES[minionName]
    if not values then
        for key, val in pairs(MINION_VALUES) do
            if string.find(minionName, key) then 
                values = val
                break 
            end
        end
    end
    if not values then return true end

    -- === RECUPERA QUEM DEU O LAST HIT ===
    -- Se for ID > 0 = Player matou
    -- Se for 0 = Torre/Minion matou
    -- Se for nil = Não detectado (dá assist pra todos)
    local fatalKillerId = MOBA.FatalKillers and MOBA.FatalKillers[cid]
    
    -- Limpa
    if MOBA.FatalKillers then 
        MOBA.FatalKillers[cid] = nil 
    end

    -- === DISTRIBUIÇÃO DE RECOMPENSAS ===
    local damageMap = creature:getDamageMap()
    
    for attackerId, damage in pairs(damageMap) do
        local attacker = Player(attackerId)
        
        if attacker then
            local attackerSkull = attacker:getSkull()
            
            -- Só paga se for inimigo do minion
            if attackerSkull ~= SKULL_NONE and attackerSkull ~= minionSkull then
                
                -- fatalKillerId > 0 = Um player matou
                -- fatalKillerId == 0 = Torre/Minion matou
                -- fatalKillerId == nil = Não detectado
                
                if fatalKillerId and fatalKillerId > 0 and attacker:getId() == fatalKillerId then
                    -- Este player deu o golpe final
                    giveGold(attacker, values.last_hit, "LAST HIT")
                else
                    -- Torre/Minion matou, ou outro player matou
                    giveGold(attacker, values.assist, "ASSIST")
                end
            end
        end
    end

    return true
end