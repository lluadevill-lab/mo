BREEDING = {
    CHECK_INTERVAL = 10,
    RANGE = 3,
    PREGNANCY_CHANCE = 80,
    GESTATION_TIME = 1 * 20,
    NEAR_BIRTH_TIME = 10,
    MAX_NEARBY = 3
}

BREEDABLE = {
    lobo = { baby = "pet_lobo jovem" },
    urso = { baby = "pet_urso jovem" },
    coelho = { baby = "pet_coelho jovem" },
    porco = { baby = "pet_porco jovem" },
    cervo = { baby = "pet_cervo jovem" },
}

BREED_STATE = {
    -- [uid] = {
    --   pregnantUntil = timestamp,
    --   cooldownUntil = timestamp
    -- }
}


function isBreedable(monster)
    if not monster or not monster:isMonster() then
        return false
    end
    return BREEDABLE[monster:getName():lower()] ~= nil
end

function inheritStats(mother, father, baby)
    if not mother or not father or not baby then return end
    local mGen = _G.MonsterGenetics[mother:getId()]
    local fGen = _G.MonsterGenetics[father:getId()]
    if not mGen or not fGen then return end

    -- 1. Herança de IVs (Mínimo é o MENOR IV dos pais)
    local babyIvs = {}
    local ivKeys = {"vida", "ataque", "defesa", "vitalidade", "velocidade", "resistencia", "exp"}
    for _, key in ipairs(ivKeys) do
        local minIv = math.min(mGen.ivs[key], fGen.ivs[key]) -- MENOR IV é a base
        babyIvs[key] = math.random(minIv, 31)
    end

    -- 2. Lógica de Ranks
    local ranks = {["Comum"] = 1, ["Incomum"] = 2, ["Raro"] = 3, ["Elite"] = 4, ["Lendario"] = 5}
    local revRanks = {"Comum", "Incomum", "Raro", "Elite", "Lendario"}
    local mR = ranks[mGen.rankName] or 1
    local fR = ranks[fGen.rankName] or 1
    
    local minRankIndex = 1
    if mR == fR then
        minRankIndex = math.max(1, mR - 1) -- Ranks iguais: garante o anterior
    else
        minRankIndex = math.max(1, math.floor((mR + fR) / 2) - 1) -- Diferentes: média - 1
    end

    -- Sorteio do Rank (de minRankIndex até 5) com peso para não virar só Lendário
    local finalRankIndex = minRankIndex
    local chance = math.random(1, 100)
    
    if chance <= 50 then finalRankIndex = minRankIndex -- 50% manter o "garantido"
    elseif chance <= 85 then finalRankIndex = math.min(5, minRankIndex + 1) -- 35% subir +1
    else finalRankIndex = math.min(5, minRankIndex + 2) -- 15% subir +2 (se possível)
    end

    local finalRankName = revRanks[finalRankIndex]

    -- 3. Registrar e Aplicar
    _G.MonsterGenetics[baby:getId()] = { lvl = 1, rankName = finalRankName, ivs = babyIvs }

    local rankMults = {["Comum"] = 1.0, ["Incomum"] = 1.2, ["Raro"] = 1.5, ["Elite"] = 2.0, ["Lendario"] = 3.0}
    local hpMult = (rankMults[finalRankName] or 1.0) + 0.03 + (babyIvs.vida / 100)
    
    baby:setMaxHealth(math.floor(baby:getMaxHealth() * hpMult))
    baby:addHealth(baby:getMaxHealth())
    baby:changeSpeed(babyIvs.velocidade * 2)
end