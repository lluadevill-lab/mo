MONSTER_GENDER = {} -- global

function setMonsterGender(uid, gender)
    MONSTER_GENDER[uid] = gender -- 1 = male, 2 = female, nil/0 = genderless
end

function getMonsterGender(uid)
    return MONSTER_GENDER[uid] or 0
end

function removeMonsterGender(uid)
    MONSTER_GENDER[uid] = nil
end
