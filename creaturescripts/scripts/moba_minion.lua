function onThink(creature, interval)
    if not creature or not creature:isMonster() then return true end
    local cid = creature:getId()
    local myTeam = MOBA.getInfo(cid, "team")
    if myTeam <= 0 then return true end
    
    -- 1. COMBATE: Se já tem target, bate nele.
    local target = creature:getTarget()
    if target then
        -- Se o target for player ou monstro valido, continua batendo
        if not target:isDead() and creature:getPosition():getDistance(target:getPosition()) <= 7 then
            return true
        end
    end
    
    -- 2. SCAN: Procura inimigos próximos
    local specs = Game.getSpectators(creature:getPosition(), false, false, 7, 7, 7, 7)
    local enemyTeamId = getEnemyTeam(myTeam)
    local bestTarget = nil
    
    for _, spec in ipairs(specs) do
        if spec:getId() ~= cid then
            if spec:isMonster() then
                local t = MOBA.getInfo(spec:getId(), "team")
                if t == enemyTeamId then
                    bestTarget = spec
                    break
                end
            elseif spec:isPlayer() and not spec:getGroup():getAccess() then
                bestTarget = spec
            end
        end
    end
    
    if bestTarget then
        creature:setTarget(bestTarget)
        doChallengeCreature(cid, bestTarget:getId())
        return true
    end
    
    -- 3. MOVIMENTO POR OBJETIVO (Pathfinding Simples)
    -- Descobre qual é o próximo alvo vivo
    local enemyTeamObj = (enemyTeamId == 1) and MOBA.TEAMS.LEFT or MOBA.TEAMS.RIGHT
    local targetPos = nil
    
    -- Lógica: Verifica torres da mais externa (última da lista) para a interna
    -- A tabela 'towers' no config está: {Inner, Outer}.
    -- Então queremos ir na Outer (2) se viva, senão Inner (1), senão Nexus.
    
    local objectives = MOBA.Objectives[enemyTeamId]
    
    if objectives.towers[2] then -- Torre Externa
        targetPos = enemyTeamObj.towers[2].pos
    elseif objectives.towers[1] then -- Torre Interna
        targetPos = enemyTeamObj.towers[1].pos
    elseif objectives.nexus then -- Nexus
        targetPos = enemyTeamObj.nexus.pos
    end
    
    if targetPos then
        local myPos = creature:getPosition()
        local destPos = Position(targetPos.x, targetPos.y, targetPos.z)
        
        -- Algoritmo de movimento simples (X depois Y)
        local nextDir = nil
        local dx = destPos.x - myPos.x
        local dy = destPos.y - myPos.y
        
        -- Prioriza o eixo com maior distancia para evitar ziguezague excessivo
        if math.abs(dx) > math.abs(dy) then
            if dx > 0 then nextDir = DIRECTION_EAST else nextDir = DIRECTION_WEST end
        else
            if dy > 0 then nextDir = DIRECTION_SOUTH else nextDir = DIRECTION_NORTH end
        end
        
        -- Tenta mover. Se falhar (bloqueio), tenta o outro eixo
        if nextDir then
            local ret = creature:move(nextDir)
            if not ret then
                -- Se travou no X, tenta mover no Y
                if nextDir == DIRECTION_EAST or nextDir == DIRECTION_WEST then
                    if dy > 0 then creature:move(DIRECTION_SOUTH)
                    elseif dy < 0 then creature:move(DIRECTION_NORTH) end
                else
                    -- Se travou no Y, tenta mover no X
                    if dx > 0 then creature:move(DIRECTION_EAST)
                    elseif dx < 0 then creature:move(DIRECTION_WEST) end
                end
            end
        end
    end
    
    return true
end