-- [[ CORREÇÃO DO ERRO DA LIB JSON ]] --
if not table_insert then table_insert = table.insert end
if not table_concat then table_concat = table.concat end

MOBA_OPCODE = 56

-- CONFIGURAÇÃO
SHOP_CONFIG = {
    -- SORCERER (ID 1)
    [1] = {
        {
            category = "Consumiveis",
            items = {
                -- Exemplo 1: clientId diferente do id
                -- Na loja mostra a imagem 1234, mas o player ganha o item 8704
                {clientId = 1234, id = 8704, count = 1, name = "Health Potion", desc = "Cura fraca", price = 45},
                
                -- Exemplo 2: Sem clientId (Usa o mesmo ID para imagem e item)
                {id = 7620, count = 1, name = "Mana Potion", desc = "Mana fraca", price = 50}
            }
        },
        {
            category = "Wands",
            items = {
                {clientId = 2190, id = 2190, count = 1, name = "Wand of Vortex", desc = "Energy (Iniciante)", price = 500},
                {id = 2187, count = 1, name = "Wand of Inferno", desc = "Fire (Avancado)", price = 3000}
            }
        }
    },
    -- DRUID (ID 2)
    [2] = {
        {
            category = "Rods",
            items = {
                {id = 2182, count = 1, name = "Snakebite Rod", desc = "Earth (Iniciante)", price = 500}
            }
        }
    }
}

function OpenMobaShop(player)
    local vocId = player:getVocation():getId()
    if vocId > 4 then vocId = vocId - 4 end
    
    local shop = SHOP_CONFIG[vocId] or SHOP_CONFIG[1] 
    
    local data = {
        action = "OPEN",
        shop = shop,
        balance = player:getMoney()
    }
    
    local status, json_data = pcall(json.encode, data)
    if status then
        player:sendExtendedOpcode(MOBA_OPCODE, json_data)
    else
        print(">> [MobaShop] ERRO JSON: " .. tostring(json_data))
    end
end