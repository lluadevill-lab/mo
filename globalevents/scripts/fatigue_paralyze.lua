local FATIGUE_STORAGE = 50002
local MIN_FATIGUE_TO_PARALYZE = 5
local SLOW_DURATION = 10000 -- 10 segundos
local PARALYZE_CONDITION_ID = CONDITION_PARALYZE
local SLOW_SPEED_PENALTY = -6000 -- Um alto valor negativo para SLOW FORTE. Ajuste se precisar de mais ou menos slow (ex: -800)

function onThink(interval)
    for _, player in ipairs(Game.getPlayers()) do
        -- Ignora NPCs e players logados
        if player:isPlayer() and player:getStorageValue(FATIGUE_STORAGE) ~= -1 then 
            
            local fatigueValue = player:getStorageValue(FATIGUE_STORAGE)
            
            if fatigueValue < MIN_FATIGUE_TO_PARALYZE then
                
                -- Verifica se o player JÁ ESTÁ paralisado/lento
                if not player:getCondition(PARALYZE_CONDITION_ID) then
                    
                    local condition = Condition(PARALYZE_CONDITION_ID, SLOW_DURATION)
                    
                    -- Verifica se a condição foi criada com sucesso
                    if condition then
                        -- Define a penalidade de velocidade. No TFS 1.x, Paralyze é uma variação de speed.
                        condition:setParameter(CONDITION_PARAM_SPEED_DELTA, SLOW_SPEED_PENALTY)
                        
                        player:addCondition(condition)
                        player:sendCancelMessage("A exaustão extrema te atinge. Você mal consegue se mover.")
                    end
                end
            end
        end
    end
    
    return true
end