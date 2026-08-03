-- [[ CORREÇÃO JSON ]] --
if not table_insert then table_insert = table.insert end
if not table_concat then table_concat = table.concat end

local OPCODE_MOBA = 56
local MAX_DISTANCE = 3 

-- [[ CONFIGURAÇÃO DA LOJA COMPLETA (MOBA - MAX LVL 50) ]] --
SHOP_CONFIG = {
    -- ========================================================================
    -- SORCERER (ID 1)
    -- ========================================================================
    [1] = {
        {
            category = "Wands (Dano)",
            items = {
                {clientId = 3074, id = 2190, name = "Wand of Vortex", stats = "Energy (13 dmg)", level = 8, price = 200},
                {clientId = 3075, id = 2191, name = "Wand of Dragonbreath", stats = "Fire (19 dmg)", level = 13, price = 500},
                {clientId = 3072, id = 2188, name = "Wand of Decay", stats = "Death (30 dmg)", level = 19, price = 1000},
                {clientId = 8093, id = 2189, name = "Wand of Draconia", stats = "Fire (34 dmg)", level = 22, price = 1500},
                {clientId = 3073, id = 2187, name = "Wand of Cosmic", stats = "Energy (45 dmg)", level = 26, price = 2500},
                {clientId = 8092, id = 8920, name = "Wand of Starstorm", stats = "Energy (65 dmg)", level = 33, price = 5000},
                {clientId = 8094, id = 8922, name = "Wand of Voodoo", stats = "Death (65 dmg)", level = 42, price = 6000},
                {clientId = 3071, id = 2186, name = "Wand of Inferno", stats = "Fire (70 dmg)", level = 33, price = 8000}
            }
        },
        {
            category = "Set (Mage)",
            items = {
                {clientId = 7991, id = 8819, name = "Magician Robe", stats = "Arm: 6 (Start)", level = 1, price = 100},
                {clientId = 8042, id = 8867, name = "Spirit Cloak", stats = "Arm: 8 | ML +1", level = 10, price = 800},
                {clientId = 3557, id = 2469, name = "Plate Legs", stats = "Arm: 7", level = 10, price = 300},
                {clientId = 3210, id = 2323, name = "Hat of the Mad", stats = "Arm: 3 | ML +1", level = 20, price = 2500},
                {clientId = 8043, id = 8871, name = "Focus Cape", stats = "Arm: 9 | ML +1", level = 25, price = 4000},
                {clientId = 645, id = 7730, name = "Blue Legs", stats = "Arm: 8 (Leve)", level = 30, price = 5000},
                {clientId = 3567, id = 2656, name = "Blue Robe", stats = "Arm: 11", level = 40, price = 7000},
                {clientId = 3079, id = 2195, name = "Boots of Haste", stats = "Speed +20", level = 20, price = 15000}
            }
        },
        {
            category = "Spellbooks/Shields",
            items = {
                {clientId = 3418, id = 2518, name = "Beholder Shield", stats = "Def: 24", level = 15, price = 1000},
                {clientId = 3424, id = 2524, name = "Ornamented Shield", stats = "Def: 30", level = 25, price = 2500},
                {clientId = 8072, id = 8900, name = "Spellbook of Enlight.", stats = "Def: 18 | ML +1", level = 30, price = 3500},
                {clientId = 8074, id = 8902, name = "Spellbook of Mind", stats = "Def: 16 | ML +2", level = 40, price = 8000},
                {clientId = 3419, id = 2519, name = "Crown Shield", stats = "Def: 32", level = 40, price = 5000}
            }
        },
        {
            category = "Runas/Pots",
            items = {
                {clientId = 268, id = 7620, count = 1, name = "Mana Potion", stats = "Recupera Mana", level = 1, price = 50},
                {clientId = 237, id = 7589, count = 1, name = "Strong Mana Potion", stats = "Recupera Mana+", level = 50, price = 80},
                {clientId = 3198, id = 2311, count = 50, name = "HMM Rune (x50)", stats = "Energy Dmg", level = 25, price = 1000},
                {clientId = 3191, id = 2304, count = 50, name = "GFB Rune (x50)", stats = "Fire Area", level = 30, price = 2500},
                {clientId = 3200, id = 2313, count = 50, name = "Explosion (x50)", stats = "Physical Dmg", level = 35, price = 3000},
                {clientId = 3155, id = 2268, count = 50, name = "SD Rune (x50)", stats = "Death KILLER", level = 45, price = 5000}
            }
        }
    },

    -- ========================================================================
    -- DRUID (ID 2)
    -- ========================================================================
    [2] = {
        {
            category = "Rods (Dano)",
            items = {
                {clientId = 2182, id = 2182, name = "Snakebite Rod", stats = "Earth (13 dmg)", level = 8, price = 200},
                {clientId = 2186, id = 2186, name = "Moonlight Rod", stats = "Ice (19 dmg)", level = 13, price = 500},
                {clientId = 2185, id = 2185, name = "Necrotic Rod", stats = "Death (30 dmg)", level = 19, price = 1000},
                {clientId = 8911, id = 8911, name = "Northwind Rod", stats = "Ice (30 dmg)", level = 22, price = 1500},
                {clientId = 2181, id = 2181, name = "Terra Rod", stats = "Earth (45 dmg)", level = 26, price = 2500},
                {clientId = 2183, id = 2183, name = "Hailstorm Rod", stats = "Ice (65 dmg)", level = 33, price = 5000},
                {clientId = 8912, id = 8912, name = "Springsprout Rod", stats = "Earth (65 dmg)", level = 42, price = 6000},
                {clientId = 8910, id = 8910, name = "Underworld Rod", stats = "Death (70 dmg)", level = 42, price = 8000}
            }
        },
        {
            category = "Set (Druid)",
            items = {
                {clientId = 8819, id = 8819, name = "Magician Robe", stats = "Arm: 6 (Start)", level = 1, price = 100},
                {clientId = 2651, id = 2651, name = "Coat", stats = "Arm: 1", level = 1, price = 10},
                {clientId = 8867, id = 8867, name = "Spirit Cloak", stats = "Arm: 8 | ML +1", level = 10, price = 800},
                {clientId = 8820, id = 8820, name = "Terra Hood", stats = "Arm: 5 | ML +2 (Earth)", level = 20, price = 2500},
                {clientId = 8871, id = 8871, name = "Focus Cape", stats = "Arm: 9 | ML +1", level = 25, price = 4000},
                {clientId = 7730, id = 7730, name = "Blue Legs", stats = "Arm: 8", level = 30, price = 5000},
                {clientId = 8819, id = 8819, name = "Terra Mantle", stats = "Arm: 11 | Earth Prot", level = 40, price = 6000},
                {clientId = 2195, id = 2195, name = "Boots of Haste", stats = "Speed +20", level = 20, price = 15000}
            }
        },
        {
            category = "Spellbooks/Shields",
            items = {
                {clientId = 2525, id = 2525, name = "Dwarven Shield", stats = "Def: 26", level = 10, price = 500},
                {clientId = 2524, id = 2524, name = "Ornamented Shield", stats = "Def: 30", level = 25, price = 2500},
                {clientId = 8900, id = 8900, name = "Spellbook of Enlight.", stats = "Def: 18 | ML +1", level = 30, price = 3500},
                {clientId = 8902, id = 8902, name = "Spellbook of Mind", stats = "Def: 16 | ML +2", level = 40, price = 8000}
            }
        },
        {
            category = "Runas/Pots",
            items = {
                {clientId = 7620, id = 7620, count = 1, name = "Mana Potion", stats = "Recupera Mana", level = 1, price = 50},
                {clientId = 7589, id = 7589, count = 1, name = "Strong Mana Potion", stats = "Recupera Mana+", level = 50, price = 80},
                {clientId = 2273, id = 2273, count = 50, name = "UH Rune (x50)", stats = "Cura Intensa", level = 24, price = 2000},
                {clientId = 2274, id = 2274, count = 50, name = "Avalanche (x50)", stats = "Ice Area", level = 30, price = 2500},
                {clientId = 2278, id = 2278, count = 50, name = "Paralyze (x50)", stats = "Slow Extremo", level = 45, price = 4000}
            }
        }
    },

    -- ========================================================================
    -- PALADIN (ID 3)
    -- ========================================================================
    [3] = {
        {
            category = "Arcos/Bestas",
            items = {
                {clientId = 2456, id = 2456, name = "Bow", stats = "Atk+0", level = 1, price = 100},
                {clientId = 2455, id = 2455, name = "Crossbow", stats = "Atk+0 (Bolts)", level = 10, price = 300},
                {clientId = 7438, id = 7438, name = "Elvish Bow", stats = "Hit% +5", level = 20, price = 1500},
                {clientId = 8857, id = 8857, name = "Silkweaver Bow", stats = "Hit% +4 | Atk +3", level = 30, price = 4000},
                {clientId = 8855, id = 8855, name = "Composite Hornbow", stats = "Hit% +2 | Atk +3", level = 45, price = 8000},
                {clientId = 8854, id = 8854, name = "Warsinger Bow", stats = "Hit% +5 | Range 7", level = 50, price = 30000}
            }
        },
        {
            category = "Municoes",
            items = {
                {clientId = 2389, id = 2389, count = 10, name = "Spears (x10)", stats = "Early Game", level = 1, price = 100},
                {clientId = 7378, id = 7378, count = 10, name = "Royal Spears (x10)", stats = "Mid Game", level = 25, price = 500},
                {clientId = 7367, id = 7367, count = 10, name = "Enchanted Spears (x10)", stats = "Late Game", level = 42, price = 1000},
                {clientId = 2544, id = 2544, count = 100, name = "Arrows (x100)", stats = "Basic", level = 1, price = 200},
                {clientId = 2543, id = 2543, count = 100, name = "Bolts (x100)", stats = "Basic Bolt", level = 10, price = 300},
                {clientId = 7365, id = 7365, count = 100, name = "Onyx Arrows (x100)", stats = "Atk 38", level = 40, price = 1500},
                {clientId = 7363, id = 7363, count = 100, name = "Piercing Bolts (x100)", stats = "Atk 33", level = 30, price = 1200},
                {clientId = 2547, id = 2547, count = 100, name = "Power Bolts (x100)", stats = "Atk 40", level = 50, price = 2000}
            }
        },
        {
            category = "Set (Paladin)",
            items = {
                {clientId = 2660, id = 2660, name = "Ranger's Cloak", stats = "Arm: 7", level = 1, price = 200},
                {clientId = 2654, id = 2654, name = "Cape", stats = "Arm: 1", level = 1, price = 10},
                {clientId = 2465, id = 2465, name = "Brass Armor", stats = "Arm: 8", level = 8, price = 300},
                {clientId = 2480, id = 2480, name = "Legion Helmet", stats = "Arm: 4", level = 8, price = 100},
                {clientId = 2647, id = 2647, name = "Plate Legs", stats = "Arm: 7", level = 10, price = 400},
                {clientId = 8891, id = 8891, name = "Paladin Armor", stats = "Arm: 12 | Dist +2", level = 20, price = 8000},
                {clientId = 2487, id = 2487, name = "Crown Armor", stats = "Arm: 13", level = 30, price = 5000},
                {clientId = 2643, id = 2643, name = "Boots of Haste", stats = "Speed +20", level = 20, price = 15000}
            }
        },
        {
            category = "Escudos",
            items = {
                {clientId = 2510, id = 2510, name = "Plate Shield", stats = "Def: 17", level = 1, price = 100},
                {clientId = 2525, id = 2525, name = "Dwarven Shield", stats = "Def: 26", level = 10, price = 500},
                {clientId = 2516, id = 2516, name = "Dragon Shield", stats = "Def: 31", level = 25, price = 3000},
                {clientId = 2534, id = 2534, name = "Vampire Shield", stats = "Def: 34", level = 35, price = 6000}
            }
        }
    },

    -- ========================================================================
    -- KNIGHT (ID 4)
    -- ========================================================================
    [4] = {
        {
            category = "Armas Melee",
            items = {
                -- Espadas
                {clientId = 8602, id = 8602, name = "Jagged Sword", stats = "Atk: 21 (Sword)", level = 8, price = 200},
                {clientId = 2392, id = 2392, name = "Fire Sword", stats = "Atk: 35 Fire (Sword)", level = 20, price = 2500},
                {clientId = 7404, id = 7404, name = "Assassin Dagger", stats = "Atk: 40 (Sword)", level = 40, price = 5000},
                {clientId = 2400, id = 2400, name = "Magic Sword", stats = "Atk: 48 (Sword)", level = 50, price = 25000},
                -- Machados
                {clientId = 2429, id = 2429, name = "Barbarian Axe", stats = "Atk: 28 (Axe)", level = 20, price = 1500},
                {clientId = 2432, id = 2432, name = "Fire Axe", stats = "Atk: 38 Fire (Axe)", level = 35, price = 5500},
                {clientId = 2431, id = 2431, name = "Stonecutter Axe", stats = "Atk: 50 (Axe)", level = 50, price = 30000},
                -- Clavas
                {clientId = 2398, id = 2398, name = "Mace", stats = "Atk: 16 (Club)", level = 8, price = 100},
                {clientId = 7426, id = 7426, name = "Amber Staff", stats = "Atk: 35 (Club)", level = 25, price = 3000},
                {clientId = 2421, id = 2421, name = "Thunder Hammer", stats = "Atk: 49 Energy", level = 50, price = 35000}
            }
        },
        {
            category = "Set (Tank)",
            items = {
                {clientId = 2463, id = 2463, name = "Plate Armor", stats = "Arm: 10", level = 10, price = 400},
                {clientId = 2465, id = 2465, name = "Brass Armor", stats = "Arm: 8", level = 5, price = 100},
                {clientId = 2457, id = 2457, name = "Steel Helmet", stats = "Arm: 6", level = 10, price = 300},
                {clientId = 2476, id = 2476, name = "Knight Armor", stats = "Arm: 12", level = 20, price = 2000},
                {clientId = 2477, id = 2477, name = "Knight Legs", stats = "Arm: 8", level = 20, price = 1500},
                {clientId = 2487, id = 2487, name = "Crown Armor", stats = "Arm: 13", level = 30, price = 5000},
                {clientId = 2472, id = 2472, name = "Magic Plate Armor", stats = "Arm: 17", level = 50, price = 25000},
                {clientId = 2643, id = 2643, name = "Boots of Haste", stats = "Speed +20", level = 20, price = 15000}
            }
        },
        {
            category = "Escudos",
            items = {
                {clientId = 2510, id = 2510, name = "Plate Shield", stats = "Def: 17", level = 1, price = 100},
                {clientId = 2525, id = 2525, name = "Dwarven Shield", stats = "Def: 26", level = 10, price = 500},
                {clientId = 2519, id = 2519, name = "Crown Shield", stats = "Def: 32", level = 30, price = 4000},
                {clientId = 2534, id = 2534, name = "Vampire Shield", stats = "Def: 34", level = 40, price = 6000},
                {clientId = 2514, id = 2514, name = "Mastermind Shield", stats = "Def: 37", level = 50, price = 15000}
            }
        },
        {
            category = "Consumiveis",
            items = {
                {clientId = 7618, id = 7618, count = 1, name = "Health Potion", stats = "Cura Vida", level = 1, price = 45},
                {clientId = 7588, id = 7588, count = 1, name = "Strong Health Potion", stats = "Cura Vida Media", level = 50, price = 100},
                {clientId = 7591, id = 7591, count = 1, name = "Great Health Potion", stats = "Cura Vida Alta", level = 80, price = 190}
            }
        }
    }
}

-- Mapeia promotions
function getBaseVocId(id)
    if id > 4 and id < 9 then return id - 4 end
    return id
end

-- [[ FUNÇÃO DE ABRIR ]] --
function OpenMobaShop(player, shopPos)
    local vocId = getBaseVocId(player:getVocation():getId())
    local shop = SHOP_CONFIG[vocId] or SHOP_CONFIG[1] 
    
    local data = {
        action = "OPEN",
        shop = shop,
        balance = player:getMoney(),
        shopPos = {x = shopPos.x, y = shopPos.y, z = shopPos.z}
    }
    
    local status, json_data = pcall(json.encode, data)
    if status then
        player:sendExtendedOpcode(OPCODE_MOBA, json_data)
    else
        end
end

-- [[ PROCESSAMENTO ]] --
function onExtendedOpcode(player, opcode, buffer)
    if opcode ~= OPCODE_MOBA then return end

    -- PEDIDO DE REFRESH DO CLIENTE (ATUALIZA SALDO)
    if buffer == "REFRESH" then
        local data = {action = "UPDATE_BALANCE", balance = player:getMoney()}
        player:sendExtendedOpcode(OPCODE_MOBA, json.encode(data))
        return
    end

    if buffer:sub(1, 4) == "BUY:" then
        
        local params = string.split(buffer:sub(5), ",")
        if #params < 5 then return end
        
        local catIdx = tonumber(params[1])
        local itmIdx = tonumber(params[2])
        local sX = tonumber(params[3])
        local sY = tonumber(params[4])
        local sZ = tonumber(params[5])
        
        -- Anti-Run Check
        local shopPos = Position(sX, sY, sZ)
        
        -- SE A POSIÇÃO FOR 0 (TESTE/REMOTO), IGNORA A DISTANCIA
        if sX ~= 0 and player:getPosition():getDistance(shopPos) > MAX_DISTANCE then
            local msg = {action = "MSG", text = "Voce se afastou da loja!", color = "#ff5555"}
            player:sendExtendedOpcode(OPCODE_MOBA, json.encode(msg))
            return
        end

        local vocId = getBaseVocId(player:getVocation():getId())
        local shop = SHOP_CONFIG[vocId] or SHOP_CONFIG[1]
        
        if shop and shop[catIdx] and shop[catIdx].items[itmIdx] then
            local itemData = shop[catIdx].items[itmIdx]
            
            if player:getMoney() >= itemData.price then
                if player:removeMoney(itemData.price) then
                    player:addItem(itemData.id, itemData.count or 1)
                    player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
                    
                    local msg = {
                        action = "MSG", 
                        text = "Comprado: " .. itemData.name, 
                        color = "#55ff55",
                        balance = player:getMoney()
                    }
                    player:sendExtendedOpcode(OPCODE_MOBA, json.encode(msg))
                    end
            else
                local msg = {action = "MSG", text = "Dinheiro insuficiente.", color = "#ff5555"}
                player:sendExtendedOpcode(OPCODE_MOBA, json.encode(msg))
                end
        else
            
        end
    end
end

function string.split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, str) end
    return t
end