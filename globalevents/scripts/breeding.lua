-- data/globalevents/scripts/breeding.lua

dofile('data/lib/breeding.lua')

local processed = {}
local BarnSystem = BarnSystem or {}

-- =====================================================
-- FUNÇÕES AUXILIARES (mantidas)
-- =====================================================

local function countNearbyBabies(female)
    local pos = female:getPosition()
    local specs = Game.getSpectators(pos, false, false, 2, 2, 2, 2)
    local count = 0

    local babyPrefix = female:getName():lower() .. " jovem" 

    for _, c in ipairs(specs) do
        if c:isMonster() then
            local name = c:getName():lower()
            if name:sub(1, #babyPrefix) == babyPrefix then
                count = count + 1
            end
        end
    end
    return count
end

local function getFreeAdjacentPosition(pos)
    local dirs = {
        {1,0},{-1,0},{0,1},{0,-1},
        {1,1},{-1,-1},{1,-1},{-1,1}
    }

    for _, d in ipairs(dirs) do
        local p = Position(pos.x + d[1], pos.y + d[2], pos.z)
        local tile = Tile(p)
        if tile and tile:getGround() and not tile:getTopCreature() then
            return p
        end
    end
    return pos
end

local function doBirth(femaleId, maleId) -- Adicionado maleId
    local female = Creature(femaleId)
    local male = Creature(maleId)
    if not female or not male then 
        BREED_STATE[femaleId] = nil
        return 
    end

    local cfg = BREEDABLE[female:getName():lower()]
    local spawnPos = getFreeAdjacentPosition(female:getPosition())
    local baby = Game.createMonster(cfg.baby, spawnPos, true, true)

    if baby then
        setMonsterGender(baby:getId(), math.random(1,2))
        inheritStats(female, male, baby) -- Agora envia os dois
        spawnPos:sendMagicEffect(CONST_ME_HOLYAREA)
    end

    female:removeCondition(CONDITION_PREGNANT)
    BREED_STATE[femaleId] = {
        cooldownUntil = os.time() + BREEDING.NEAR_BIRTH_TIME
    }
end

-- =====================================================
-- BREEDING
-- =====================================================
function processBreeding(female)
    if not female or not female:isMonster() then return end
    if not isBreedable(female) then return end
    if getMonsterGender(female:getId()) ~= 2 then return end

    local uid = female:getId()
    local now = os.time()
    local state = BREED_STATE[uid]

    if state then
        if state.pregnantUntil and now < state.pregnantUntil then
            female:addCondition(CONDITION_PREGNANT)
            return
        elseif state.pregnantUntil and now >= state.pregnantUntil then
            doBirth(uid, state.fatherId)
            return
        elseif state.cooldownUntil and now < state.cooldownUntil then
            return
        elseif state.cooldownUntil and now >= state.cooldownUntil then
            BREED_STATE[uid] = nil
        end
    end

    if countNearbyBabies(female) >= BREEDING.MAX_NEARBY then
        return
    end

    local pos = female:getPosition()
    local specs = Game.getSpectators(pos, false, false,
        BREEDING.RANGE, BREEDING.RANGE,
        BREEDING.RANGE, BREEDING.RANGE
    )

    for _, male in ipairs(specs) do
        if male:isMonster()
        and isBreedable(male)
        and male:getName():lower() == female:getName():lower()
        and getMonsterGender(male:getId()) == 1 then

            if female:getCondition(CONDITION_INFIGHT)
            or male:getCondition(CONDITION_INFIGHT) then
                return
            end

            if math.random(100) <= BREEDING.PREGNANCY_CHANCE then
    BREED_STATE[uid] = {
        pregnantUntil = now + BREEDING.GESTATION_TIME,
        fatherId = male:getId() -- SALVA O PAI AQUI
                }
                female:getPosition():sendMagicEffect(CONST_ME_HEARTS)
                male:getPosition():sendMagicEffect(CONST_ME_HEARTS)
                female:addCondition(CONDITION_PREGNANT)
                
                return
            end
        end
    end
end

-- =====================================================
-- GLOBAL EVENT (CORRIGIDO E INTEGRADO)
-- =====================================================
function onThink(interval)
    -- Limpa processados para esta iteração
    local processed = {}

    -- 1. Verifica **TODAS** as criaturas dentro dos celeiros registrados
    -- Usamos o cache de zonas do BarnSystem para iterar apenas áreas relevantes.
    if BarnSystem and BarnSystem.activeZones then
        for _, zoneData in pairs(BarnSystem.activeZones) do -- <---- AQUI USAMOS O BARNSYSTEM
            local creaturesInZone = BarnSystem:getAnimalsInZone(zoneData)
            
            -- Itera fêmeas e machos dentro do celeiro (só precisamos das fêmeas)
            for _, female in ipairs(creaturesInZone.females) do
                local uid = female:getId()
                
                if not processed[uid] then
                    processed[uid] = true
                    processBreeding(female)
                end
            end
            
            -- Marcar machos como processados para não checar duas vezes no loop 2
            for _, male in ipairs(creaturesInZone.males) do
                processed[male:getId()] = true
            end
        end
    end
    
    -- 2. Verifica outros monstros no campo de visão de jogadores (Lógica original mantida)
    for _, player in ipairs(Game.getPlayers()) do
        local specs = Game.getSpectators(
            player:getPosition(),
            false, false,
            15, 15, 15, 15
        )

        for _, monster in ipairs(specs) do
            if monster:isMonster() then
                local uid = monster:getId()
                
                -- Se não foi processado no celeiro E é uma fêmea breedable, processa
                if not processed[uid] and getMonsterGender(monster:getId()) == 2 and isBreedable(monster) then
                    processed[uid] = true
                    processBreeding(monster)
                end
            end
        end
    end
    
    return true
end