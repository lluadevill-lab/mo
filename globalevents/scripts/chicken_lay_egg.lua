-- data/globalevents/scripts/chicken_lay_egg.lua

local EGG_ITEM_ID = 2328
local MONSTER_NAME = "Chicken"
local CHANCE = 70 
local MIN_EGGS = 0
local MAX_EGGS = 3
local COOLDOWN_SECONDS = 120 -- 10 minutos (600 segundos)

-- Tabela para armazenar o último tempo de postura de cada galinha (Em memória)
local cooldowns = cooldowns or {}

local CHECK_RADIUS = 9 -- Raio de tiles para checar (usado apenas se o método global falhar)

function onThink(interval)
    local currentTime = os.time()
    local monstersToCheck = {}

    -- 1. TENTATIVA GLOBAL: Prioriza a iteração em todos os monstros vivos
    if Game.getMonsters then
        local globalMonsters = Game.getMonsters()
        if globalMonsters and #globalMonsters > 0 then
            monstersToCheck = globalMonsters
        end
    end
    
    -- 2. FALLBACK (se Game.getMonsters não existir ou falhar): Itera por jogadores e área carregada
    if #monstersToCheck == 0 then
        local players = Game.getPlayers()
        if players and #players > 0 then
            local creaturesChecked = {}
            for _, player in ipairs(players) do
                local playerPos = player:getPosition()
                for dx = -CHECK_RADIUS, CHECK_RADIUS do
                    for dy = -CHECK_RADIUS, CHECK_RADIUS do
                        local pos = Position(playerPos.x + dx, playerPos.y + dy, playerPos.z)
                        local posKey = pos.x .. "," .. pos.y .. "," .. pos.z
                        if creaturesChecked[posKey] then
                            goto continue_inner
                        end
                        creaturesChecked[posKey] = true

                        local tile = Tile(pos)
                        if tile then
                            local creature = tile:getTopCreature()
                            if creature and creature:isMonster() and creature:getName() == MONSTER_NAME then
                                -- Adiciona a galinha à lista de checagem, mesmo que já tenha sido checada
                                table.insert(monstersToCheck, creature) 
                            end
                        end
                        ::continue_inner::
                    end
                end
            end
        end
    end

    -- 3. EXECUTA A LÓGICA DE POSTURA DE OVO
    for _, creature in ipairs(monstersToCheck) do
        if creature:isMonster() and creature:getName() == MONSTER_NAME then
            local uniqueId = creature:getId()
            local lastLay = cooldowns[uniqueId]
            
            if not lastLay or currentTime >= (lastLay + COOLDOWN_SECONDS) then
                if math.random(100) <= CHANCE then
                    local numEggs = math.random(MIN_EGGS, MAX_EGGS)
                    local dropPos = creature:getPosition()
                    
                    local item = Game.createItem(EGG_ITEM_ID, numEggs, dropPos)
                    
                    if item then
                        dropPos:sendMagicEffect(CONST_ME_TUTORING) 
                    end
                end
                
                cooldowns[uniqueId] = currentTime
            end
        end
    end
    
    return true
end