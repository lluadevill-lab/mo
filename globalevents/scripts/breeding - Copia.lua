-- data/globalevents/scripts/breeding.lua

dofile('data/lib/breeding.lua')

local processed = {}

local function countNearbyBabies(female)
    local pos = female:getPosition()
    local specs = Game.getSpectators(pos, false, false, 2, 2, 2, 2)
    local count = 0

    -- Inclui a própria fêmea, caso tenha "Urso Jovem", "Lobo Jovem", etc
    local babyPrefix = female:getName():lower() .. " jovem"
    if female:getName():lower():sub(1, #babyPrefix) == babyPrefix then
        count = count + 1
    end

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
        {1,0}, {-1,0}, {0,1}, {0,-1},
        {1,1}, {-1,-1}, {1,-1}, {-1,1}
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

function processBreeding(female)
    if not isBreedable(female) then return end
    if getMonsterGender(female:getId()) ~= 2 then return end

    local uid = female:getId()
    local now = os.time()
    local state = BREED_STATE[uid]

    if state and state.pregnantUntil then
        if now >= state.pregnantUntil then
            birth(female)
        end
        return
    end

    if state and state.cooldownUntil then
        if now < state.cooldownUntil then
            return
        else
            BREED_STATE[uid] = nil
        end
    end

    -- conta filhotes proximos incluindo o próprio tile
    if countNearbyBabies(female) >= BREEDING.MAX_NEARBY then
        return
    end

    local pos = female:getPosition()
    local specs = Game.getSpectators(
        pos,
        false, false,
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
                    pregnantUntil = now + BREEDING.GESTATION_TIME
                }
                -- animação na mãe e pai
                female:getPosition():sendMagicEffect(CONST_ME_HEARTS)
                male:getPosition():sendMagicEffect(CONST_ME_HEARTS)
                return
            end
        end
    end
end

function birth(female)
    local uid = female:getId()
    local cfg = BREEDABLE[female:getName():lower()]
    if not cfg then
        BREED_STATE[uid] = nil
        return
    end

    local pos = female:getPosition()
    local spawnPos = getFreeAdjacentPosition(pos)

    local baby = Game.createMonster(cfg.baby, spawnPos, true, true)
    if not baby then
        BREED_STATE[uid] = nil
        return
    end

    setMonsterGender(baby:getId(), math.random(1, 2))
    inheritStats(female, baby)

    spawnPos:sendMagicEffect(CONST_ME_HOLYAREA)

    BREED_STATE[uid] = {
        cooldownUntil = os.time() + BREEDING.NEAR_BIRTH_TIME
    }
end

function onThink(interval)
    processed = {}

    for _, player in ipairs(Game.getPlayers()) do
        local specs = Game.getSpectators(
            player:getPosition(),
            false, false,
            15, 15, 15, 15
        )

        for _, monster in ipairs(specs) do
            if monster:isMonster() then
                local uid = monster:getId()
                if not processed[uid] then
                    processed[uid] = true
                    processBreeding(monster)
                end
            end
        end
    end
    return true
end