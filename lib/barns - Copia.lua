-- data/lib/barns.lua

_G.BARN_FEMALES = _G.BARN_FEMALES or {}
_G.BARN_MALES = _G.BARN_MALES or {}

BARN_MARKERS = {
    {x=1442, y=924, z=7, range=10}, -- exemplo
}

function isInsideAnyBarn(pos)
    for _, b in ipairs(BARN_MARKERS) do
        if pos.z == b.z and
            math.abs(pos.x - b.x) <= b.range and
            math.abs(pos.y - b.y) <= b.range then
            return true
        end
    end
    return false
end

function registerBarnAnimals()
    -- Limpa as tabelas antes de re-registrar
    _G.BARN_FEMALES = {}
    _G.BARN_MALES = {}

    local processed = {}

    for _, b in ipairs(BARN_MARKERS) do
        local centerPos = Position(b.x, b.y, b.z)
        local range = b.range

        -- Usa Game.getSpectators no centro do celeiro para obter todas as criaturas dentro do range
        local specs = Game.getSpectators(
            centerPos,
            false, false,
            range, range,
            range, range
        )

        for _, c in ipairs(specs) do
            if c:isMonster() then
                local uid = c:getId()
                
                -- Evita processar o mesmo monstro várias vezes se celeiros se sobrepõem
                if not processed[uid] then
                    processed[uid] = true

                    local gender = getMonsterGender(uid)
                    if gender == 2 then
                        _G.BARN_FEMALES[uid] = c
                    elseif gender == 1 then
                        _G.BARN_MALES[uid] = c
                    end
                end
            end
        end
    end
end

-- chamar no server start ou global event init
registerBarnAnimals()