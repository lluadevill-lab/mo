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
    local pet = Creature(self:getStorageValue(PETS.STORAGE.UID))
    if pet then
        return false
    end

    self:setPetUid(PETS.CONSTANS.STATUS_OK)
    self:setPetExperience(0)
    self:setPetLevel(1)
    self:setPetType(petType)

    -- Seta o HP Base
    self:setPetMaxHealth(PETS.IDENTIFICATION[petType].health)
    self:setPetLostHealth(0)

    -- Se não houver IVs definidos (ex: pet inicial), zera eles
    if self:getStorageValue(PETS.STORAGE.IV_HEALTH) == -1 then
        for _, storage in pairs({10006, 10007, 10008, 10009, 10010, 10011, 10012}) do
            self:setStorageValue(storage, 0)
        end
    end

    if PETS.SYSTEM.MOUNTS then
        local mountId = self:getPetMountId()
        if mountId ~= nil and mountId ~= 0 then
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

function Player.summonPet(self, position)
    local petUid = self:getPetUid()
    local pet = Creature(petUid)
    if pet and pet:isCreature() then
        return false
    end

    if (Tile(position)):hasFlag(TILESTATE_PROTECTIONZONE) then
      return false
    end

    if PETS.SYSTEM.MOUNTS then
        local mountId = self:getPetMountId()
        local currentOutfit = self:getOutfit()
        local currentMount = currentOutfit.lookMount
        if mountId ~= nil and currentMount ~= nil and currentMount ~= 0 and currentMount == mountId then
            return false
        end
    end

    local pet = Game.createMonster(PETS.PREFIX .. (PETS.IDENTIFICATION[self:getPetType()].name), position)
    if pet then
        position:sendMagicEffect(CONST_ME_TELEPORT)
        pet:setMaster(self)
        
        -- APLICAÇÃO DE IV VIDA
        local baseMaxHealth = self:getPetMaxHealth()
        local ivHealth = math.max(0, self:getStorageValue(PETS.STORAGE.IV_HEALTH))
        local finalMaxHealth = math.floor(baseMaxHealth * (1 + (ivHealth / 100)))
        
        pet:setMaxHealth(finalMaxHealth)
        pet:addHealth(finalMaxHealth)
        
        -- Aplica vida perdida salva
        local lost = self:getPetLostHealth()
        if lost > 0 then
            pet:addHealth(-lost)
        end

        self:setPetUid( pet:getId() )
        pet:setSkull(SKULL_GREEN)
        
        -- APLICAÇÃO DE IV SPEED
        local ivSpeed = math.max(0, self:getStorageValue(PETS.STORAGE.IV_SPEED))
        local speedBonus = PETS.CONFIG.sameSpeed and (self:getBaseSpeed() - pet:getBaseSpeed()) or (ivSpeed * 2)
        pet:changeSpeed(speedBonus)

        -- Registro de Eventos (Incluindo PetIVsImpact)
        for _, eventName in pairs({"PetDeath", "PetKill", "PetIVsImpact"}) do
            pet:registerEvent(eventName)
        end

        if PETS.SYSTEM.TELEPORT then
            pet:registerEvent("PetTeleport")
        end

        if PETS.SYSTEM.DUELS_ONLY then
            pet:registerEvent("PetHealthChange")
        end

        if PETS.SYSTEM.MOUNTS then
            local mountId = self:getPetMountId()
            if mountId ~= nil then
                self:removeMount(mountId)
            end
        end

        return pet
    end

    local petMonsterType = MonsterType(PETS.PREFIX .. (PETS.IDENTIFICATION[self:getPetType()].name))
    if not petMonsterType then
        print('[PET-SYSTEM] Cant find monster type: ' .. PETS.PREFIX .. (PETS.IDENTIFICATION[self:getPetType()].name) )
    end
    return false
end

function getExpNeeded(level)
    return ( (50 *level^3) -(150 *level^2) +(400 *level) )/3 *PETS.CONFIG.expMultipler
end

function Player.addPetExp(self, amount)
    local pet = Creature(self:getPetUid())
    if not pet then
        return false
    end

    if self:getPetLevel() >= PETS.CONFIG.maxLevel then
        return false
    end

    -- BÔNUS DE IV EXP
    local ivExp = math.max(0, self:getStorageValue(PETS.STORAGE.IV_EXP))
    if ivExp > 0 then
        amount = math.floor(amount * (1 + (ivExp / 100)))
    end

    local totalExp = self:getPetExperience() + amount
    self:setPetExperience(totalExp)
    local petLevel, petType = self:getPetLevel(), self:getPetType()

    if totalExp >= getExpNeeded(petLevel + 1) then
        -- Quando upa, o storage de base HP aumenta
        local hpGain = (PETS.IDENTIFICATION[petType].hpAdd or PETS.CONFIG.standardHpAdd)
        local newBaseMax = self:getPetMaxHealth() + hpGain
        self:setPetMaxHealth(newBaseMax)
        
        self:setPetLevel(petLevel +1)
        self:petSystemMessage("Your pet "..PETS.IDENTIFICATION[petType].name.." has advanced to level "..(petLevel +1)..".")

        -- Atualiza o HP atual do pet no mundo com o novo bônus de IV recalculado
        local ivHealth = math.max(0, self:getStorageValue(PETS.STORAGE.IV_HEALTH))
        local newFinalMax = math.floor(newBaseMax * (1 + (ivHealth / 100)))
        pet:setMaxHealth(newFinalMax)

        if PETS.CONFIG.healOnLevelUp then
            pet:addHealth(newFinalMax)
        end

        -- Evolução
        if PETS.SYSTEM.EVOLUTION and (PETS.IDENTIFICATION[petType]).evolve and ((PETS.IDENTIFICATION[petType]).evolve.at <= (petLevel +1)) then
            local position = pet:getPosition()
            self:doRemovePet()
            self:setPetType( (PETS.IDENTIFICATION[petType]).evolve.to)
            self:setPetMaxHealth( (PETS.IDENTIFICATION[(PETS.IDENTIFICATION[petType]).evolve.to]).health )
            self:setPetLostHealth(0)
            self:petSystemMessage("Your pet "..(PETS.IDENTIFICATION[petType]).name.." has evolved to a "..((PETS.IDENTIFICATION[(PETS.IDENTIFICATION[petType]).evolve.to]).name)..".")
            self:summonPet(position)
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
ends