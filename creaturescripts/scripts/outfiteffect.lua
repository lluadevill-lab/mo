local events = {}

function onLogin(cid)
    -- Garante que o evento seja registrado em todas as sessões
    registerCreatureEvent(cid, "EffectOutLogin")

    -- Se o evento "onOutfit" não for registrado via XML, use esta linha:
    -- registerPlayerEvent(cid, "OutfitEffects")

    -- Chama a função onOutfit manualmente para iniciar o efeito ao logar
    local currentOutfit = getCreatureOutfit(cid)
    onOutfit(cid, currentOutfit, currentOutfit)

    return doCreatureChangeOutfit(cid,{lookType = currentOutfit.lookType, lookHead =  currentOutfit.lookHead, lookBody = currentOutfit.lookBody, lookLegs = currentOutfit.lookLegs, lookFeet = currentOutfit.lookFeet, lookAddons = currentOutfit.lookAddons})
end

function onOutfit(cid, old, current)
    local effect = {
        [136] = 3, [128] = 3, -- citizen
        [270] = 27,[273] = 27, -- jester
        [156] = 61,[152] = 61, -- assassin
        [147] = 44,[143] = 44, -- barbarian
        [148] = 45,[144] = 45, -- druid
        [157] = 68,[153] = 68, -- beggar
        [149] = 36,[145] = 36, -- wizard
        [279] = 17,[278] = 17, -- brotherwood
        [137] = 39,[129] = 39, -- hunter
        [141] = 66,[133] = 66, -- summoner
        [142] = 34,[134] = 34, -- warrior
        [155] = 31,[151] = 31, -- pirate
        [158] = 46,[154] = 46, -- shaman
        [288] = 6,[289] = 6 -- demonhunter
    }

    local o,c= effect[old.lookType],effect[current.lookType]

    if getPlayerAccess(cid) > 2 then return true end

    -- Para o evento se não tem mais efeito ou se a outfit antiga tinha e a nova não
    if (not c or old.lookAddons == 3 and o) then
        if events[getPlayerGUID(cid)] then
            stopEvent(events[getPlayerGUID(cid)])
            events[getPlayerGUID(cid)] = nil
        end
    end

    -- Inicia o evento se a nova outfit tem addon 3 e tem um efeito
    if current.lookAddons == 3 and c then
        function WalkEffect(cid, c, pos)
            if not isCreature(cid) then 
                if events[getPlayerGUID(cid)] then 
                    events[getPlayerGUID(cid)] = nil 
                end
                return LUA_ERROR
            end 

            local frompos = getThingPos(cid)
            
            -- Verifica se a posição mudou
            if frompos.x ~= pos.x or frompos.y ~= pos.y or frompos.z ~= pos.z then
                doSendMagicEffect(frompos, c)
            end

            events[getPlayerGUID(cid)] = addEvent(WalkEffect, 100, cid, c, frompos)
            return true
        end

        WalkEffect(cid, c, {x=0, y=0, z=0})
    end
    
    return true
end