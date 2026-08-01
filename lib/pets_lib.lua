PETS = {
    PREFIX = "PET_",
    CHANNELID = 4,

    CONFIG = {
        introduction = "Use !petcatch para domar animais. Se ele desmaiar, use !petrevive (Custa soul points). Alguns pets exigem algo especial para doma-los, alguns nao podem ser domados e outros evoluem. Diga !commands para uma lista de comandos disponiveis.",
        sameSpeed = false,

        healSoulCost = 0.1,
        healSoulBase = 10,

        healOnLevelUp = true,
        standardHpAdd = 50,
        expMultipler = 5,
        shareExpMultipler = 1.5,
        maxLevel = 30,

        reviveSoulBaseCost = 50,
        reviveSoulLevelCost = 0.2
    },

    SYSTEM = {
        EVOLUTION = true,
        MOUNTS = true,
        TELEPORT = true,
        PLAYER_SHARE_EXPERIENCE = false,
        DUELS_ONLY = false
    },


    IDENTIFICATION = {
        [1] = {
            name = "Cat",
            health = 100,
            evolve = {
                to = 3,
                at = 10
            },
            check = true
        },
        [2] = {
            name = "Dog",
            health = 100,
            evolve = {
                to = 4,
                at = 10
            },
            check = true
        },
        [3] = {
            name = "Tiger",
            health = 300,
            check = false,
            info = "Evolves from Cat."
        },
        [4] = {
            name = "Lion",
            health = 300,
            mountId = 40,
            check = false,
            info = "Evolves from Dog."
        },
        [5] = {
            name = "Husky",
            health = 150,
            check = function(player) return player:getPremiumDays() > 0 end,
            info = "Requires a premium account."
        },
        [6] = {
            name = "Lobo",
            health = 200,
            evolve = {
                to = 7,
                at = 4
            },
            check = function(player) return player:getLevel() >= 10 end,
            info = "Requires level 10."
        },
        [7] = {
            name = "War Wolf",
            health = 500,
            evolve = {
                to = 8,
                at = 55
            },
            check = false,
            info = "Evolves from Wolf."
        },
        [8] = {
            name = "Werewolf",
            health = 1000,
            check = false,
            info = "Evolves from War Wolf."
        },
        [9] = {
            name = "Urso",
            health = 600,
            mountId = 3,
            check = function(player) return player:isDruid() and player:getLevel() >= 10 end,
            info = "Only available to druids above level 10."
        },
        [10] = {
            name = "Panda",
            health = 300,
            mountId = 19,
            check = function(player) return player:getLevel() >= 10 end,
            info = "Only available to druids above level 10."
        },
        [11] = {
            name = "Chicken",
            health = 50,
            check = true
        },
        [12] = {
            name = "Sheep",
            health = 50,
            check = true
        },
        [13] = {
            name = "Seagull",
            health = 100,
            check = function(player) return player:getPremiumDays() > 0 end,
            info = "Requires a premium account."
        },
        [14] = {
            name = "Arara",
            health = 100,
        },
        [15] = {
            name = "Penguin",
            health = 100,
            check = function(player) return player:getPremiumDays() > 0 end,
            info = "Requires a premium account."
        },
        [16] = {
            name = "Elephant",
            health = 300,
            check = function(player) return player:getPremiumDays() > 0 and player:getLevel() >= 10 end,
            contain = 5,
            info = "Only available to Premium accounts above level 10."
        },
        [17] = {
            name = "Dragon Hatchling",
            health = 300,
            evolve = {
                to = 18,
                at = 20
            },
            check = function(player) return player:getPremiumDays() > 0 and player:getLevel() >= 25 and player:isSorcerer() end,
            info = "Only available to Premium Sorcerers above level 25."
        },
        [18] = {
            name = "Dragon",
            health = 1000,
            check = false,
            info = "Evolves from Dragon Hatchling."
        },
        [19] = {
            name = "Black Sheep",
            health = 200,
            check = false,
            info = "Teste."
        }
    },

STORAGE = {
        TYPE = 10000,
        UID = 10001,
        LOSTHEALTH = 10002,
        MAXHEALTH = 10003,
        EXPERIENCE = 10004,
        LEVEL = 10005,
        -- Novos Storages de IVs e Rank
        IV_HEALTH = 10006,
        IV_ATTACK = 10007,
        IV_SPEED = 10008,
        IV_DEFENSE = 10009,
        IV_RESISTANCE = 10010,
        IV_EXP = 10011,
        IV_VITALITY = 10012,
        RANK = 10013
    },

    CONSTANS = {
        STATUS_OK = 0,
        STATUS_DOESNT_EXIST = -1,
        STATUS_DEAD = -2,
        STATUS_MOUNT = -3
    }
}

--/ config
function Player.petSystemMessage(self, txt, talkType)
    local playerId = self:getId()
    talkType = (talkType == nil) and TALKTYPE_CHANNEL_O or talkType

    local function eventMessage(playerId, text, talkType)
        local player = Player(playerId)
        if not player then
            return false
        end
        player:sendChannelMessage('[PET-SYSTEM]', text, talkType, PETS.CHANNELID)
    end
    addEvent(eventMessage, 150, playerId, txt, talkType)
    return true
end

-- get
function Player.getPetExperience(self)
    return self:getStorageValue(PETS.STORAGE.EXPERIENCE)
end

function Player.getPetLevel(self)
    return self:getStorageValue(PETS.STORAGE.LEVEL)
end

function Player.getPetType(self)
    return self:getStorageValue(PETS.STORAGE.TYPE)
end

function Player.getPetUid(self)
    return self:getStorageValue(PETS.STORAGE.UID)
end

function Player.getPetMaxHealth(self)
    return self:getStorageValue(PETS.STORAGE.MAXHEALTH)
end

function Player.getPetLostHealth(self)
    return self:getStorageValue(PETS.STORAGE.LOSTHEALTH)
end

function Player.getPetMountId(self)
    local petType = self:getPetType()
    if not PETS.IDENTIFICATION[petType] then return nil end
    local mountId = PETS.IDENTIFICATION[petType].mountId
    return mountId
end

-- set
function Player.setPetExperience(self, experience)
    return self:setStorageValue(PETS.STORAGE.EXPERIENCE, experience)
end

function Player.setPetLevel(self, petLevel)
    return self:setStorageValue(PETS.STORAGE.LEVEL, petLevel)
end

function Player.setPetType(self, petType)
    return self:setStorageValue(PETS.STORAGE.TYPE, petType)
end

function Player.setPetUid(self, petUid)
    return self:setStorageValue(PETS.STORAGE.UID, petUid)
end

function Player.setPetMaxHealth(self, health)
    return self:setStorageValue(PETS.STORAGE.MAXHEALTH, health)
end

function Player.setPetLostHealth(self, health)
    return self:setStorageValue(PETS.STORAGE.LOSTHEALTH, health)
end

-- other
function Player.doAddPet(self, petType)
    local pet = Creature(self:getPetUid())
    if pet then
        return false
    end

    self:setPetUid(PETS.CONSTANS.STATUS_OK)
    self:setPetExperience(0)
    self:setPetLevel(1)
    self:setPetType(petType)

    -- Seta o HP Base do Pet
    local baseHealth = PETS.IDENTIFICATION[petType].health
    self:setPetMaxHealth(baseHealth)
    self:setPetLostHealth(0)

    -- SÓ ZERA IVS E RANK SE FOREM NOVOS (-1)
    -- Se o catch já setou, o valor não será -1 e o if será ignorado
    if self:getStorageValue(PETS.STORAGE.IV_HEALTH) == -1 then
        for _, storage in pairs({10006, 10007, 10008, 10009, 10010, 10011, 10012}) do
            self:setStorageValue(storage, 0)
        end
        -- Define Rank padrão como string se estiver vazio
        local currentRank = self:getStorageValue(PETS.STORAGE.RANK)
        if type(currentRank) == "number" or currentRank == "" then
            self:setStorageValue(PETS.STORAGE.RANK, "Comum")
        end
    end

    -- Sistema de Montaria
    if PETS.SYSTEM.MOUNTS then
        local mountId = self:getPetMountId()
        if mountId and mountId ~= 0 then
            self:addMount(mountId)
        end
    end
    
    return true
end

function Player.doResetPet(self)
    for _, i in pairs(PETS.STORAGE) do
        self:setStorageValue(i, -1)
    end
    return true
end

function Player.doRemovePet(self)
    local petUid = self:getPetUid()
    local pet = Creature(petUid)

    if not pet or not pet:isCreature() then
        if petUid > 0 then
            self:setPetUid(PETS.CONSTANS.STATUS_OK)
        end
        return true
    end
    
    -- Salvamos o dano perdido (Diferença entre MaxHP atual e Vida atual)
    self:setPetLostHealth(pet:getMaxHealth() - pet:getHealth())

    pet:remove()

    if PETS.SYSTEM.MOUNTS then
        local mountId = self:getPetMountId()
        if mountId ~= nil then
            self:addMount(mountId)
        end
    end
    return true
end

function Player.doKillPet(self, removeBody)
    if removeBody then
        self:doRemovePet()
    end
    self:setPetUid(PETS.CONSTANS.STATUS_DEAD)
    self:setPetLostHealth(0)

    if PETS.SYSTEM.MOUNTS then
        local mountId = self:getPetMountId()
        if mountId ~= nil then
            self:removeMount(mountId)
        end
    end
    return true
end

-- Em pets_lib.lua, substitua pet:setHealth(currentHP) por:

function Player.summonPet(self, position)
    local petUid = self:getPetUid()
    local pet = Creature(petUid)
    if pet and pet:isCreature() then
        return false
    end

    if (Tile(position)):hasFlag(TILESTATE_PROTECTIONZONE) then
        return false
    end

    local petType = self:getPetType()
    local petName = PETS.IDENTIFICATION[petType].name
    local pet = Game.createMonster(PETS.PREFIX .. petName, position)
    
    if pet then
        position:sendMagicEffect(CONST_ME_TELEPORT)
        pet:setMaster(self)
        
        -- 1. CÁLCULO DE STATUS
        local info = PETS.IDENTIFICATION[petType]
        local baseHP = info and info.health or 100
        local level = math.max(1, self:getPetLevel())
        local ivHealth = math.max(0, self:getStorageValue(PETS.STORAGE.IV_HEALTH))
        
        local ranks = {"Comum", "Incomum", "Raro", "Elite", "Lendario"}
        local rankVal = self:getStorageValue(PETS.STORAGE.RANK)
        local rankName = "Comum"
        if type(rankVal) == "number" and rankVal > 0 then
            rankName = ranks[rankVal] or "Comum"
        elseif type(rankVal) == "string" and rankVal ~= "" then
            rankName = rankVal
        end

        local rankMults = {["Comum"] = 1.0, ["Incomum"] = 1.2, ["Raro"] = 1.5, ["Elite"] = 2.0, ["Lendario"] = 3.0}
        local hpMult = (rankMults[rankName] or 1.0) + (level * 0.03) + (ivHealth / 100)
        local finalMaxHealth = math.floor(baseHP * hpMult)
        
        pet:setMaxHealth(finalMaxHealth)
        
        -- 2. APLICAÇÃO DE VIDA ATUAL
        local lost = self:getPetLostHealth()
        pet:addHealth(finalMaxHealth)
        if lost > 0 then
            pet:addHealth(-math.min(lost, finalMaxHealth - 1))
        end

        -- 3. REGISTRO OBRIGATÓRIO NA TABELA GLOBAL (DNA CHECKER)
        if not _G.MonsterGenetics then _G.MonsterGenetics = {} end
        local rankXP = {["Comum"] = 1.0, ["Incomum"] = 1.1, ["Raro"] = 1.25, ["Elite"] = 1.5, ["Lendario"] = 2.0}
        
        _G.MonsterGenetics[pet:getId()] = {
            lvl = level,
            rankName = rankName,
            xpMult = rankXP[rankName] or 1.0,
            ivs = {
                vida = ivHealth,
                ataque = math.max(0, self:getStorageValue(PETS.STORAGE.IV_ATTACK)),
                velocidade = math.max(0, self:getStorageValue(PETS.STORAGE.IV_SPEED)),
                defesa = math.max(0, self:getStorageValue(PETS.STORAGE.IV_DEFENSE)),
                resistencia = math.max(0, self:getStorageValue(PETS.STORAGE.IV_RESISTANCE)),
                exp = math.max(0, self:getStorageValue(PETS.STORAGE.IV_EXP)),
                vitalidade = math.max(0, self:getStorageValue(PETS.STORAGE.IV_VITALITY))
            }
        }

        -- 4. FINALIZAÇÃO
        self:setPetUid(pet:getId())
        pet:setSkull(SKULL_GREEN)
        
        local ivSpeed = math.max(0, self:getStorageValue(PETS.STORAGE.IV_SPEED))
        local speedBonus = PETS.CONFIG.sameSpeed and (self:getBaseSpeed() - pet:getBaseSpeed()) or (ivSpeed * 2)
        pet:changeSpeed(speedBonus)

        for _, eventName in pairs({"PetDeath", "PetKill", "PetIVsImpact", "PetsAutoAttack"}) do
            pet:registerEvent(eventName)
        end

        return pet
    end
    return false
end

function getExpNeeded(level)
    return ( (50 *level^3) -(150 *level^2) +(400 *level) )/3 *PETS.CONFIG.expMultipler
end

function Player.addPetExp(self, amount)
    local petUid = self:getPetUid()
    local pet = Creature(petUid)
    if not pet then return false end

    local petType = self:getPetType()
    if self:getPetLevel() >= PETS.CONFIG.maxLevel then return false end

    -- BÔNUS DE IV EXP
    local ivExp = math.max(0, self:getStorageValue(PETS.STORAGE.IV_EXP))
    amount = math.floor(amount * (1 + (ivExp / 100)))

    local totalExp = self:getPetExperience() + amount
    self:setPetExperience(totalExp)

    -- LOOP PARA SUBIR MÚLTIPLOS NÍVEIS
    while totalExp >= getExpNeeded(self:getPetLevel() + 1) and self:getPetLevel() < PETS.CONFIG.maxLevel do
        local currentLvl = self:getPetLevel()
        local nextLvl = currentLvl + 1
        
        -- Aumento de HP Base (usa valor específico do pet ou padrão da config)
        local hpGain = (PETS.IDENTIFICATION[petType].hpAdd or PETS.CONFIG.standardHpAdd)
        local newBaseMax = self:getPetMaxHealth() + hpGain
        self:setPetMaxHealth(newBaseMax)
        
        self:setPetLevel(nextLvl)
        self:petSystemMessage("Seu pet " .. PETS.IDENTIFICATION[petType].name .. " subiu pro level " .. nextLvl .. ".")

        -- Recalcula HP Final com IV de Vida
        local ivHealth = math.max(0, self:getStorageValue(PETS.STORAGE.IV_HEALTH))
        local newFinalMax = math.floor(newBaseMax * (1 + (ivHealth / 100)))
        pet:setMaxHealth(newFinalMax)

        if PETS.CONFIG.healOnLevelUp then
            pet:addHealth(newFinalMax)
        end

        -- Lógica de Evolução
        local petData = PETS.IDENTIFICATION[petType]
        if PETS.SYSTEM.EVOLUTION and petData.evolve and (nextLvl >= petData.evolve.at) then
            local evolveTo = petData.evolve.to
            local evolveData = PETS.IDENTIFICATION[evolveTo]
            local position = pet:getPosition()
            
            self:doRemovePet()
            self:setPetType(evolveTo)
            self:setPetMaxHealth(evolveData.health)
            self:setPetLostHealth(0)
            
            self:petSystemMessage("Your pet " .. petData.name .. " evoluiu para " .. evolveData.name .. ".")
            self:summonPet(position)
            
            -- Atualiza variáveis para o próximo ciclo do while (se houver)
            petType = evolveTo
            pet = Creature(self:getPetUid()) 
            if not pet then break end
        end
    end

    return true
end

function Player.canGetPet(self, petId)
    if self:getGroup():getId() >= 3 then
        return true
    end

    if type(PETS.IDENTIFICATION[petId].check) == "function" then
        return PETS.IDENTIFICATION[petId].check(self)
    end
    return PETS.IDENTIFICATION[petId].check
end

-- is Pet
function Player.isPet(self) return false end
function Npc.isPet(self) return false end
function Monster.isPet(self)
    local owner = self:getMaster()
    if owner and owner:isPlayer() and owner:getPetUid() == self:getId() then
        return true
    end
    return false
end

-- additional functions
function Position.getSurroundings(self)
  local return_array = {}
  local coordinates = {
    {x = self.x +1, y = self.y, z = self.z},
    {x = self.x -1, y = self.y, z = self.z},
    {x = self.x +1, y = self.y +1, z = self.z},
    {x = self.x, y = self.y +1, z = self.z},
    {x = self.x -1, y = self.y +1, z = self.z},
    {x = self.x +1, y = self.y -1, z = self.z},
    {x = self.x, y = self.y -1, z = self.z},
    {x = self.x -1, y = self.y -1, z = self.z}
  }

  for _, coordinate in pairs(coordinates) do
    table.insert(return_array, Position(coordinate))
  end
  return return_array
end

-- PET tools
function Monster.dig(self)
  if not self:isPet() then return false end
  local return_value = false
  local position = self:getPosition()
  local surroundings = position:getSurroundings()
  local HOLE_LIST = {468, 481, 483, 7932}

  local function _tmp_dig_in_tile(creature, tile, pos)
    if not tile or tile:getCreatureCount() ~= 0 or tile:getItemCount() ~= 0 then return false end
    local ground = tile:getGround()
    if not ground then return false end
    local groundId = ground:getId()
    if not isInArray(HOLE_LIST, groundId) then return false end
    ground:transform(groundId + 1)
    ground:decay()
    pos:sendMagicEffect(CONST_ME_POFF)
    return true
  end

  for _, next_position in pairs(surroundings) do
    if _tmp_dig_in_tile(self, Tile(next_position), next_position) then
      return_value = true
    end
  end
  return return_value
end

function applyPetGenetics(player, pet)
    if not player or not pet then return end
    
    local ranks = {"Comum", "Incomum", "Raro", "Elite", "Lendario"}
    local rankVal = player:getStorageValue(PETS.STORAGE.RANK)
    local rankName = "Comum"
    
    if type(rankVal) == "number" and rankVal > 0 then
        rankName = ranks[rankVal] or "Comum"
    elseif type(rankVal) == "string" and rankVal ~= "" then
        rankName = rankVal
    end

    local level = math.max(1, player:getPetLevel())
    
    -- Tabela de multiplicadores de XP para o Checker usar
    local rankXP = {["Comum"] = 1.0, ["Incomum"] = 1.1, ["Raro"] = 1.25, ["Elite"] = 1.5, ["Lendario"] = 2.0}

    -- Popula a tabela global para o item IV Checker ler
    if not _G.MonsterGenetics then _G.MonsterGenetics = {} end
    _G.MonsterGenetics[pet:getId()] = {
        lvl = level,
        rankName = rankName,
        xpMult = rankXP[rankName] or 1.0,
        ivs = {
            vida = math.max(0, player:getStorageValue(PETS.STORAGE.IV_HEALTH)),
            ataque = math.max(0, player:getStorageValue(PETS.STORAGE.IV_ATTACK)),
            velocidade = math.max(0, player:getStorageValue(PETS.STORAGE.IV_SPEED)),
            defesa = math.max(0, player:getStorageValue(PETS.STORAGE.IV_DEFENSE)),
            resistencia = math.max(0, player:getStorageValue(PETS.STORAGE.IV_RESISTANCE)),
            exp = math.max(0, player:getStorageValue(PETS.STORAGE.IV_EXP)),
            vitalidade = math.max(0, player:getStorageValue(PETS.STORAGE.IV_VITALITY))
        }
    }
end