PET_MEMORY = PET_MEMORY or {}

local S_IVS = {10006, 10007, 10008, 10009, 10010, 10011, 10012}
local S_RANK = 10013

function Player.getPetList(self)
    local k = self:getGuid()
    if not PET_MEMORY[k] then PET_MEMORY[k] = {} end
    return PET_MEMORY[k]
end

function Player.savePetList(self, list)
    PET_MEMORY[self:getGuid()] = list
end

function Player.saveCurrentPet(self)
    local currentType = self:getPetType()
    if currentType <= 0 then return end

    local pet = {
        type = currentType,
        level = self:getPetLevel(),
        exp = self:getPetExperience(),
        lost = self:getPetLostHealth(),
        rank = self:getStorageValue(S_RANK),
        ivs = {}
    }

    for _, storage in ipairs(S_IVS) do
        table.insert(pet.ivs, math.max(0, self:getStorageValue(storage)))
    end

    local list = self:getPetList()
    table.insert(list, 1, pet)
    self:savePetList(list)
    self:doResetPet()
end

-- CORRIGIDO: Troca segura e funcional de pets.
-- Substitua a função swapPetByIndex por esta:
function Player.swapPetByIndex(self, index)
    local list = self:getPetList()
    local selectedPet = list[index]
    if not selectedPet then return false end

    local currentType = self:getPetType()
    local oldPet = nil

    -- Se existe um pet ativo (mesmo que guardado no storage), salva os dados dele antes de trocar
    if currentType > 0 then
        oldPet = {
            type = currentType,
            level = self:getPetLevel(),
            exp = self:getPetExperience(),
            lost = self:getPetLostHealth(), -- Salva o dano real
            rank = self:getStorageValue(S_RANK),
            ivs = {}
        }
        for _, storage in ipairs(S_IVS) do
            table.insert(oldPet.ivs, math.max(0, self:getStorageValue(storage)))
        end
    end

    -- Remove o novo pet da lista
    table.remove(list, index)
    
    -- Insere o pet antigo na lista (se houver)
    if oldPet then 
        table.insert(list, 1, oldPet) 
    end
    
    self:savePetList(list)

    -- Aplica os dados do pet SELECIONADO nos storages principais do player
    self:setPetType(selectedPet.type)
    self:setPetLevel(selectedPet.level)
    self:setPetExperience(selectedPet.exp)
    self:setPetLostHealth(selectedPet.lost or 0) -- Carrega o dano salvo (previne HP negativo)
    self:setStorageValue(S_RANK, selectedPet.rank)

    for i, storage in ipairs(S_IVS) do
        self:setStorageValue(storage, selectedPet.ivs[i] or 0)
    end

    -- Seta status OK para o sistema de spawn permitir a invocação
    self:setPetUid(PETS.CONSTANS.STATUS_OK)
    return true
end