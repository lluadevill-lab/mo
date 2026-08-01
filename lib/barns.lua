-- data/lib/barn_system.lua

-- Requer a biblioteca JSON (padrão no TFS 1.2+)
if not json then
    print("[BarnSystem] ERRO: Biblioteca JSON não encontrada. Verifique sua configuração do TFS.")
end

BarnSystem = {
    -- Configuração dos Markers
    config = {
        -- ITEMID = {type, radius, name}
        [20075] = {type = "barn", radius = 5, name = "Celeiro"},    -- Exemplo: Vaca/Touro (5x5)
        [20076] = {type = "coop", radius = 3, name = "Galinheiro"}, -- Exemplo: Galinha/Galo (3x3)
        [20077] = {type = "pen",  radius = 4, name = "Chiqueiro"}   -- Exemplo: Porco/Porca (4x4)
    },
    
    -- Cache em memória: ["x:y:z"] = {data}
    activeZones = {}, 
    
    -- Configurações de Persistência
    storageKey = 54321, -- Global Storage Key para salvar a lista de markers
    
    -- Configurações do Sistema de Reprodução
    reproductionRate = 60 * 60, -- 1 hora (em segundos)
    spawnChance = 20,           -- 20% de chance de spawn por zona (se houver machos/fêmeas)
    maxBabies = 3,              -- Máximo de filhotes gerados por ciclo
    
    -- Mapeamento de Gênero/Prole: Nome do Monstro -> {gender, baby_name}
    genderMap = {
        -- Exemplo para o tipo 'barn' (Vaca/Touro)
        ["cow"] = {gender = 2, mate = "bull", baby = "calf"}, 
        ["bull"] = {gender = 1, mate = "cow", baby = "calf"},
        
        -- Exemplo para o tipo 'coop' (Galinha/Galo)
        ["chicken"] = {gender = 2, mate = "rooster", baby = "chick"}, 
        ["rooster"] = {gender = 1, mate = "chicken", baby = "chick"},
        
        -- Exemplo para o tipo 'pen' (Porco/Porca)
        ["pig"] = {gender = 2, mate = "boar", baby = "piglet"}, 
        ["boar"] = {gender = 1, mate = "pig", baby = "piglet"},
        
        -- Adicione mais monstros aqui...
    }
}

-- FUNÇÕES DE UTILIDADE E REGISTRO

function BarnSystem:sendDebugMessage(pos, message)
    -- Tenta enviar a mensagem para o jogador mais próximo que seja GM (level 4+)
    local specs = Game.getSpectators(pos, true, true, 10, 10, 10, 10)
    
    for _, p in ipairs(specs) do
        if p:isPlayer() and p:getGroup():getId() >= 4 then -- Verifica se é GM
            p:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "[BarnSystem Debug] " .. message)
            return -- Envia para o primeiro GM encontrado
        end
    end
end

function BarnSystem:getPositionKey(pos)
    return string.format("%d:%d:%d", pos.x, pos.y, pos.z)
end

-- Adiciona um marker ao sistema (chamado pelo onAddItem ou no Startup)
function BarnSystem:registerMarker(item)
    if not item then return false end
    
    local cfg = self.config[item:getId()]
    if not cfg then return false end

    local pos = item:getPosition()
    local key = self:getPositionKey(pos)

    self.activeZones[key] = {
        uid = item:getUniqueId(),
        itemId = item:getId(),
        type = cfg.type,
        name = cfg.name,
        radius = cfg.radius,
        center = pos
    }
    
    -- FEEDBACK VISUAL: Efeito Mágico no centro do celeiro.
    pos:sendMagicEffect(CONST_ME_HOLYAREA) 
    
    self:sendDebugMessage(pos, "Zona '" .. cfg.name .. "' registrada em " .. key .. " com Raio " .. cfg.radius .. ".")
    
    self:saveCache() -- Salva na storage após registrar
    return true
end

-- Remove um marker do sistema
function BarnSystem:unregisterMarker(item)
    local pos = item:getPosition()
    local key = self:getPositionKey(pos)
    
    if self.activeZones[key] then
        self.activeZones[key] = nil
        
        -- FEEDBACK VISUAL: Efeito Mágico de Fumaça na remoção.
        pos:sendMagicEffect(CONST_ME_POFF)
        self:sendDebugMessage(pos, "Zona '" .. item:getName() .. "' removida de " .. key .. ".")
        
        self:saveCache() -- Salva na storage após remover
        return true
    end
    return false
end

-- Remove um marker do sistema
function BarnSystem:unregisterMarker(item)
    local pos = item:getPosition()
    local key = self:getPositionKey(pos)
    
    if self.activeZones[key] then
        self.activeZones[key] = nil
        self:saveCache() -- Salva na storage após remover
        return true
    end
    return false
end

-- FUNÇÕES DE VERIFICAÇÃO E DADOS

-- Verifica se uma posição está dentro de qualquer zona
function BarnSystem:getZoneAt(pos)
    for _, zone in pairs(self.activeZones) do
        if pos.z == zone.center.z then
            local dx = math.abs(pos.x - zone.center.x)
            local dy = math.abs(pos.y - zone.center.y)
            
            if dx <= zone.radius and dy <= zone.radius then
                return zone -- Retorna a tabela da zona encontrada
            end
        end
    end
    return nil
end

-- Retorna todos os animais dentro de uma zona específica
function BarnSystem:getAnimalsInZone(zoneData)
    local creatures = {males = {}, females = {}}
    local specs = Game.getSpectators(zoneData.center, false, false, zoneData.radius, zoneData.radius, zoneData.radius, zoneData.radius)
    
    for _, spectator in ipairs(specs) do
        if spectator:isMonster() then
            local monsterName = string.lower(spectator:getName())
            local genderData = self.genderMap[monsterName]
            
            if genderData then
                if genderData.gender == 1 then
                    table.insert(creatures.males, spectator)
                elseif genderData.gender == 2 then
                    table.insert(creatures.females, spectator)
                end
            end
        end
    end
    return creatures
end

-- FUNÇÕES DE PERSISTÊNCIA (SAVE/LOAD)

function BarnSystem:saveCache()
    local dataToSave = {}
    for _, zone in pairs(self.activeZones) do
        table.insert(dataToSave, {x=zone.center.x, y=zone.center.y, z=zone.center.z, id=zone.itemId})
    end
    -- Salva o JSON na Global Storage
    Game.setStorageValue(self.storageKey, json.encode(dataToSave))
end

function BarnSystem:loadCache()
    local saved = Game.getStorageValue(self.storageKey)
    if not saved or type(saved) ~= "string" then return end
    
    local data = json.decode(saved)
    local loadedCount = 0
    
    if data then
        for _, entry in ipairs(data) do
            local pos = Position(entry.x, entry.y, entry.z)
            local tile = Tile(pos)
            if tile then
                local item = tile:getItemById(entry.id)
                if item and item:isItem() then 
                    self:registerMarker(item) -- O registro já envia o efeito/debug
                    loadedCount = loadedCount + 1
                else
                    -- Este WARN é importante, mas precisa de console. Vamos ignorar por enquanto.
                end
            end
        end
    end
    
    -- Mensagem de resumo carregada no servidor (visível ao primeiro GM que logar)
    local dummyPos = Position(100, 100, 7) -- Posição fictícia para enviar a mensagem
    self:sendDebugMessage(dummyPos, "Cache carregado ao iniciar: " .. loadedCount .. " zonas ativas.")
end

-- FUNÇÃO PRINCIPAL DE REPRODUÇÃO (CHAMADA PELO GLOBALEVENT)

function BarnSystem:processReproduction()
    local spawns = 0
    for key, zone in pairs(self.activeZones) do
        local animals = self:getAnimalsInZone(zone)
        
        -- Verifica se existe pelo menos um casal
        if #animals.males > 0 and #animals.females > 0 then
            
            -- Sorteio da chance de spawn
            if math.random(100) <= self.spawnChance then
                local babyCount = math.random(1, self.maxBabies)
                local spawned = 0
                
                -- Escolhe um par aleatório (fêmea define o tipo de prole)
                local female = animals.females[math.random(1, #animals.females)]
                local monsterName = string.lower(female:getName())
                local babyName = self.genderMap[monsterName].baby
                
                if babyName then 
                    -- Tenta spawnar os filhotes
                    for i = 1, babyCount do
                        local randomPos = Position(
                            zone.center.x + math.random(-zone.radius, zone.radius),
                            zone.center.y + math.random(-zone.radius, zone.radius),
                            zone.center.z
                        )
                        
                        if Game.createMonster(babyName, randomPos, false, false) then
                            spawns = spawns + 1
                            spawned = spawned + 1
                        end
                    end
                    
                    if spawned > 0 then
                        -- Broadcast de evento para jogadores próximos (opcional, para feedback)
                        Game.sendDistanceMessage(zone.center, "Um novo nascimento ocorreu no " .. zone.name .. "!", MESSAGE_STATUS_CONSOLE_ORANGE)
                    end
                    
                else 
                    print("[BarnSystem] ERRO: Baby name não configurado para " .. monsterName)
                end
            end
        end
    end
    if spawns > 0 then
        print(string.format("[BarnSystem] %d novos animais nasceram em %d zonas.", spawns, table.maxn(self.activeZones)))
    end
    return true
end