-- ==========================================================
-- MOBA BOTS v47 - SISTEMA COMPLETO DE BOTS INTELIGENTES
-- ==========================================================
-- Sistema avançado de IA para bots em modo MOBA
-- Inclui: Pathfinding, Combate, Spells, Compras, Teamfight, etc.
-- ==========================================================

MOBA_BOTS = MOBA_BOTS or {}

-- ==========================================================
-- ESTADOS DO BOT
-- ==========================================================

MOBA_BOTS.STATE = {
    PREPARING = 1,
    IN_BASE = 2,
    GOING_TO_LANE = 3,
    LANING = 4,
    FIGHTING = 5,
    RETREATING = 6,
    RECALLING = 7,
    DEAD = 8,
    DEFENDING_TOWER = 9,
    PUSHING = 10,
    CHASING = 11,
    FLEEING_TOWER = 12,
    SIEGING = 13,
    ALL_IN = 14,
    KITING_FIGHT = 15,
    ASSISTING_ALLY = 16,
    FLEEING_FOR_RECALL = 17,
    HEALING_ALLY = 18,
    WAITING_WAVE = 19,
    FARMING = 20,
    ROAMING = 21,
    GANKING = 22,
    RETURNING_TO_LANE = 23
}

MOBA_BOTS.STATE_NAMES = {
    [1] = "PREPARING",
    [2] = "IN_BASE",
    [3] = "GOING_TO_LANE",
    [4] = "LANING",
    [5] = "FIGHTING",
    [6] = "RETREATING",
    [7] = "RECALLING",
    [8] = "DEAD",
    [9] = "DEFENDING_TOWER",
    [10] = "PUSHING",
    [11] = "CHASING",
    [12] = "FLEEING_TOWER",
    [13] = "SIEGING",
    [14] = "ALL_IN",
    [15] = "KITING_FIGHT",
    [16] = "ASSISTING_ALLY",
    [17] = "FLEEING_FOR_RECALL",
    [18] = "HEALING_ALLY",
    [19] = "WAITING_WAVE",
    [20] = "FARMING",
    [21] = "ROAMING",
    [22] = "GANKING",
    [23] = "RETURNING_TO_LANE"
}

-- ==========================================================
-- CONFIGURAÇÕES GLOBAIS
-- ==========================================================

MOBA_BOTS.CONFIG = {
    -- Intervalos de tempo (ms)
    THINK_INTERVAL = 300,
    THINK_INTERVAL_COMBAT = 300,
    THINK_INTERVAL_CRITICAL = 300,
    ATTACK_CD = 2.0,
    SPELL_CD_GLOBAL = 1,0,
    POTION_CD = 3.0,
    HEAL_ALLY_CD = 3.0,
    
    -- Ranges de visão e detecção
    VISION_RANGE = 12,
    EXTENDED_VISION_RANGE = 16,
    TOWER_RANGE = 4,
    TOWER_SAFE_DISTANCE = 5,
    TOWER_DANGER_DISTANCE = 4,
    TOWER_SEARCH_RANGE = 25,
    ENGAGE_RANGE = 6,
    ASSIST_RANGE = 10,
    ASSIST_ENGAGE_RANGE = 7,
    TEAM_FOCUS_RANGE = 8,
    SAFE_LANE_DISTANCE = 8,
    CHASE_MAX_DISTANCE = 12,
    CHASE_GIVE_UP_DISTANCE = 15,
    RECALL_SAFE_DISTANCE = 15,
    RECALL_FLEE_DISTANCE = 10,
    DEFEND_TOWER_RANGE = 14,
    SAFE_FROM_HERO_DISTANCE = 10,
    GANK_DETECTION_RANGE = 14,
    ROAM_TRIGGER_RANGE = 50,
    
    -- Thresholds de HP
    HP_CRITICAL = 0.18,
    HP_VERY_LOW = 0.25,
    HP_LOW = 0.38,
    HP_MEDIUM = 0.55,
    HP_HEALTHY = 0.75,
    HP_HIGH = 0.85,
    HP_FULL = 0.95,
    HP_PERFECT = 0.99,
    
    -- Thresholds específicos
    DEFEND_MIN_HP = 0.30,
    CHASE_HP_THRESHOLD = 0.35,
    ALL_IN_ENEMY_HP_THRESHOLD = 0.25,
    ALL_IN_MY_HP_MAX = 0.40,
    ALL_IN_CHANCE = 0.65,
    DUEL_HP_ADVANTAGE = 0.15,
    HEAL_ALLY_HP_THRESHOLD = 0.50,
    HEAL_SELF_HP_THRESHOLD = 0.60,
    USE_HP_POT_THRESHOLD = 0.45,
    USE_MANA_POT_THRESHOLD = 0.35,
    LAST_HIT_HP_THRESHOLD = 0.28,
    
    -- Configurações de Kiting
    RANGED_KITE_DISTANCE = 3,
    RANGED_OPTIMAL_DISTANCE = 4,
    RANGED_MIN_DISTANCE = 2,
    MELEE_ENGAGE_DISTANCE = 1,
    KITE_AFTER_ATTACK_DELAY = 0.3,
    
    -- Recall
    RECALL_TIME = 8,
    RECALL_CHANNEL_TIME = 8,
    RECALL_EFFECT_INTERVAL = 1.5,
    RECALL_CANCEL_DAMAGE_THRESHOLD = 0.05,
    
    -- Waypoints e movimento
    WP_ARRIVE_DISTANCE = 2,
    WP_STRICT_DISTANCE = 4,
    WP_SKIP_DISTANCE = 8,
    MAX_PATH_LENGTH = 50,
    PATH_RECALC_INTERVAL = 2.0,
    PATH_CACHE_TTL = 5,
    STUCK_THRESHOLD = 3,
    STUCK_CRITICAL_THRESHOLD = 8,
    STUCK_TELEPORT_THRESHOLD = 15,
    MAX_STUCK_COUNT = 20,
    ANTI_STUCK_RADIUS = 3,
    
    -- Lane management
    MAX_PER_LANE = 2,
    LANE_ASSIGN_TIMEOUT = 5,
    LANE_RETURN_DISTANCE = 30,
    OUT_OF_LANE_THRESHOLD = 15,
    
    -- Torre
    TOWER_FLEE_EXTRA_DISTANCE = 3,
    TOWER_AGGRO_DURATION = 3.0,
    TOWER_SAFE_MARGIN = 2,
    TOWER_ATTACK_PRIORITY = 150,
    
    -- Base
    BASE_HEAL_RATE = 0.15,
    BASE_HEAL_INTERVAL = 400,
    BASE_FORCE_EXIT_TIME = 15,
    BASE_MAX_TIME = 30,
    IDLE_RECALL_TIME = 10,
    
    -- Gold e economia
    STARTING_GOLD = 500,
    GOLD_RESERVE_FOR_POTS = 150,
    MIN_POTS_TO_BUY = 3,
    MAX_POTS_CARRY = 15,
    MINION_GOLD = 40,
    HERO_KILL_GOLD = 300,
    TOWER_KILL_GOLD = 150,
    ASSIST_GOLD_PERCENT = 0.5,
    
    -- Experiência
    MINION_EXP = 50,
    HERO_KILL_EXP = 600,
    TOWER_KILL_EXP = 200,
    ASSIST_EXP_PERCENT = 0.5,
    
    -- Combate em grupo
    TEAMFIGHT_HERO_THRESHOLD = 3,
    TEAMFIGHT_RANGE = 12,
    FOCUS_TARGET_SWITCH_CD = 2.0,
    PRIORITY_LOW_HP_BONUS = 100,
    PRIORITY_HERO_BONUS = 200,
    PRIORITY_DISTANCE_PENALTY = 2,
    
    -- Comportamento avançado
    AGGRESSION_BASE = 0.5,
    AGGRESSION_HP_MODIFIER = 0.3,
    AGGRESSION_ALLY_MODIFIER = 0.2,
    DEFENSIVE_WHEN_ALONE = true,
    COORDINATE_WITH_ALLIES = true,
    SMART_RETREAT_ENABLED = true,
    PREDICT_ENEMY_MOVEMENT = true,
    
    -- Debug
    DEBUG_ENABLED = false,
    DEBUG_MOVEMENT = false,
    DEBUG_COMBAT = false,
    DEBUG_DECISIONS = false,
    LOG_PURCHASES = true,
    LOG_SPELLS = true,
    LOG_STATE_CHANGES = false
}

-- ==========================================================
-- TABELA DE EXPERIÊNCIA POR LEVEL
-- ==========================================================

MOBA_BOTS.EXP_TABLE = {
    [1] = 0,
    [2] = 100,
    [3] = 250,
    [4] = 450,
    [5] = 700,
    [6] = 1000,
    [7] = 1400,
    [8] = 1900,
    [9] = 2500,
    [10] = 3200,
    [11] = 4000,
    [12] = 5000,
    [13] = 6200,
    [14] = 7600,
    [15] = 9200,
    [16] = 11000,
    [17] = 13000,
    [18] = 15500,
    [19] = 18500,
    [20] = 22000,
    [21] = 26000,
    [22] = 31000,
    [23] = 37000,
    [24] = 44000,
    [25] = 52000
}

-- ==========================================================
-- CLASSES DOS BOTS
-- ==========================================================

MOBA_BOTS.CLASSES = {
    knight = {
        name = "Knight",
        hp = 650,
        hpGain = 85,
        mana = 100,
        manaGain = 10,
        atk = 38,
        atkGain = 3.2,
        def = 15,
        defGain = 2,
        speed = 280,
        range = 1,
        ranged = false,
        distEffect = CONST_ANI_NONE,
        hitEffect = CONST_ME_HITAREA,
        vocId = 4,
        role = "tank",
        playstyle = "aggressive",
        outfit = {
            male = 131,
            female = 139
        },
        spells = {
            {
                name = "exori",
                words = "exori",
                level = 8,
                mana = 20,
                cd = 5.0,
                type = "absolute",
                pattern = "adjacent",
                damage = {min = 40, max = 65},
                effect = CONST_ME_HITAREA,
                areaEffect = true,
                priority = 1
            },
            {
                name = "exori gran",
                words = "exori gran",
                level = 15,
                mana = 50,
                cd = 15.0,
                type = "absolute",
                pattern = "adjacent",
                damage = {min = 90, max = 140},
                effect = CONST_ME_HITAREA,
                areaEffect = true,
                priority = 2
            },
            {
                name = "exori mas",
                words = "exori mas",
                level = 20,
                mana = 80,
                cd = 10.0,
                type = "absolute",
                pattern = "small_area",
                damage = {min = 70, max = 100},
                effect = CONST_ME_GROUNDSHAKER,
                areaEffect = true,
                radius = 3,
                priority = 3
            },
            {
                name = "utito tempo",
                words = "utito tempo",
                level = 14,
                mana = 100,
                cd = 30.0,
                type = "buff",
                duration = 10,
                effect = CONST_ME_MAGIC_GREEN,
                bonuses = {bonusAtk = 35, bonusSpeed = 20},
                priority = 4
            },
            {
                name = "exori min",
                words = "exori min",
                level = 8,
                mana = 15,
                cd = 5.0,
                type = "targeted",
                range = 1,
                damage = {min = 25, max = 40},
                effect = CONST_ME_HITAREA,
                priority = 0
            }
        },
        potionType = "health",
        buyPriority = {"weapon", "armor", "shield", "helmet", "boots", "potion"}
    },
    
    paladin = {
        name = "Paladin",
        hp = 480,
        hpGain = 55,
        mana = 150,
        manaGain = 15,
        atk = 32,
        atkGain = 2.8,
        def = 10,
        defGain = 1.5,
        speed = 300,
        range = 5,
        ranged = true,
        distEffect = CONST_ANI_BOLT,
        hitEffect = CONST_ME_DRAWBLOOD,
        vocId = 3,
        role = "marksman",
        playstyle = "kiting",
        outfit = {
            male = 129,
            female = 137
        },
        spells = {
            {
                name = "exori san",
                words = "exori san",
                level = 8,
                mana = 20,
                cd = 3.0,
                type = "targeted",
                range = 4,
                damage = {min = 30, max = 50},
                distEffect = CONST_ANI_HOLY,
                effect = CONST_ME_HOLYDAMAGE,
                priority = 1
            },
            {
                name = "exori con",
                words = "exori con",
                level = 13,
                mana = 25,
                cd = 4.0,
                type = "targeted",
                range = 6,
                damage = {min = 40, max = 65},
                distEffect = CONST_ANI_BOLT,
                effect = CONST_ME_DRAWBLOOD,
                priority = 2
            },
            {
                name = "exevo mas san",
                words = "exevo mas san",
                level = 25,
                mana = 100,
                cd = 12.0,
                type = "absolute",
                pattern = "small_area",
                damage = {min = 80, max = 130},
                effect = CONST_ME_HOLYDAMAGE,
                radius = 3,
                priority = 3
            },
            
            {
                name = "utito tempo san",
                words = "utito tempo san",
                level = 20,
                mana = 80,
                cd = 25.0,
                type = "buff",
                duration = 10,
                effect = CONST_ME_MAGIC_GREEN,
                bonuses = {bonusAtk = 25, bonusDist = 15},
                priority = 4
            }
        },
        potionType = "health",
        buyPriority = {"weapon", "ammo", "armor", "helmet", "boots", "potion"}
    },
    
    sorcerer = {
        name = "Sorcerer",
        hp = 380,
        hpGain = 38,
        mana = 250,
        manaGain = 30,
        atk = 28,
        atkGain = 2.2,
        def = 5,
        defGain = 1,
        speed = 290,
        range = 4,
        ranged = true,
        distEffect = CONST_ANI_ENERGY,
        hitEffect = CONST_ME_ENERGYHIT,
        vocId = 1,
        role = "mage",
        playstyle = "burst",
        outfit = {
            male = 130,
            female = 138
        },
        spells = {
            {
                name = "exori vis",
                words = "exori vis",
                level = 8,
                mana = 20,
                cd = 3.0,
                type = "targeted",
                range = 3,
                damage = {min = 35, max = 55},
                distEffect = CONST_ANI_ENERGY,
                effect = CONST_ME_ENERGYHIT,
                priority = 1
            },
            {
                name = "exori flam",
                words = "exori flam",
                level = 12,
                mana = 25,
                cd = 3.0,
                type = "targeted",
                range = 3,
                damage = {min = 40, max = 65},
                distEffect = CONST_ANI_FIRE,
                effect = CONST_ME_FIREATTACK,
                priority = 1
            },
            {
                name = "exori mort",
                words = "exori mort",
                level = 16,
                mana = 30,
                cd = 3.0,
                type = "targeted",
                range = 3,
                damage = {min = 50, max = 80},
                distEffect = CONST_ANI_DEATH,
                effect = CONST_ME_MORTAREA,
                priority = 1
            },
            {
                name = "exevo vis hur",
                words = "exevo vis hur",
                level = 18,
                mana = 50,
                cd = 6.0,
                type = "wave",
                direction = true,
                length = 5,
                width = 3,
                damage = {min = 70, max = 110},
                effect = CONST_ME_ENERGYAREA,
                priority = 2
            },
            {
                name = "exevo flam hur",
                words = "exevo flam hur",
                level = 20,
                mana = 60,
                cd = 6.0,
                type = "wave",
                direction = true,
                length = 6,
                width = 4,
                damage = {min = 80, max = 130},
                effect = CONST_ME_FIREAREA,
                priority = 2
            },
            {
                name = "exevo gran vis hur",
                words = "exevo gran vis hur",
                level = 25,
                mana = 80,
                cd = 15.0,
                type = "wave",
                direction = true,
                length = 7,
                width = 5,
                damage = {min = 120, max = 180},
                effect = CONST_ME_BIGCLOUDS,
                priority = 3
            },
            {
                name = "exevo gran mas vis",
                words = "exevo gran mas vis",
                level = 35,
                mana = 150,
                cd = 20.0,
                type = "absolute",
                pattern = "large_area",
                damage = {min = 180, max = 280},
                effect = CONST_ME_ENERGYAREA,
                radius = 5,
                priority = 4
            },
            {
                name = "utori vis",
                words = "utori vis",
                level = 30,
                mana = 50,
                cd = 15.0,
                type = "debuff",
                range = 4,
                duration = 6,
                effect = CONST_ME_ENERGYHIT,
                bonuses = {slow = 20},
                priority = 3
            }
        },
        potionType = "mana",
        buyPriority = {"wand", "armor", "spellbook", "helmet", "rune", "potion"}
    },
    
    druid = {
        name = "Druid",
        hp = 400,
        hpGain = 42,
        mana = 280,
        manaGain = 35,
        atk = 24,
        atkGain = 2.0,
        def = 6,
        defGain = 1.2,
        speed = 285,
        range = 4,
        ranged = true,
        distEffect = CONST_ANI_ICE,
        hitEffect = CONST_ME_ICEATTACK,
        vocId = 2,
        role = "support",
        playstyle = "supportive",
        outfit = {
            male = 130,
            female = 138
        },
        spells = {
            {
                name = "exori frigo",
                words = "exori frigo",
                level = 8,
                mana = 20,
                cd = 3.0,
                type = "targeted",
                range = 3,
                damage = {min = 30, max = 50},
                distEffect = CONST_ANI_ICE,
                effect = CONST_ME_ICEATTACK,
                priority = 1
            },
            {
                name = "exori tera",
                words = "exori tera",
                level = 12,
                mana = 25,
                cd = 3.0,
                type = "targeted",
                range = 3,
                damage = {min = 35, max = 55},
                distEffect = CONST_ANI_EARTH,
                effect = CONST_ME_CARNIPHILA,
                priority = 1
            },
            {
                name = "exevo frigo hur",
                words = "exevo frigo hur",
                level = 16,
                mana = 45,
                cd = 5.0,
                type = "wave",
                direction = true,
                length = 5,
                width = 3,
                damage = {min = 60, max = 100},
                effect = CONST_ME_ICEAREA,
                priority = 2
            },
            {
                name = "exevo gran frigo hur",
                words = "exevo gran frigo hur",
                level = 22,
                mana = 70,
                cd = 12.0,
                type = "wave",
                direction = true,
                length = 6,
                width = 4,
                damage = {min = 90, max = 140},
                effect = CONST_ME_ICETORNADO,
                priority = 3
            },
            {
                name = "exevo tera hur",
                words = "exevo tera hur",
                level = 18,
                mana = 50,
                cd = 8.5,
                type = "wave",
                direction = true,
                length = 5,
                width = 3,
                damage = {min = 70, max = 110},
                effect = CONST_ME_STONES,
                priority = 2
            },
            {
                name = "exevo gran mas frigo",
                words = "exevo gran mas frigo",
                level = 30,
                mana = 120,
                cd = 20.0,
                type = "absolute",
                pattern = "medium_area",
                damage = {min = 120, max = 200},
                effect = CONST_ME_ICETORNADO,
                radius = 4,
                priority = 4
            },
            {
                name = "exura",
                words = "exura",
                level = 8,
                mana = 25,
                cd = 3.0,
                type = "heal_self",
                heal = {min = 50, max = 80},
                effect = CONST_ME_MAGIC_BLUE,
                priority = 5
            },
            {
                name = "exura gran",
                words = "exura gran",
                level = 12,
                mana = 50,
                cd = 6.0,
                type = "heal_self",
                heal = {min = 100, max = 160},
                effect = CONST_ME_MAGIC_BLUE,
                priority = 5
            },
            {
                name = "exura sio",
                words = "exura sio",
                level = 18,
                mana = 120,
                cd = 5.0,
                type = "heal_ally",
                range = 7,
                heal = {min = 120, max = 200},
                effect = CONST_ME_MAGIC_BLUE,
                priority = 6
            },
            {
                name = "exura gran sio",
                words = "exura gran sio",
                level = 25,
                mana = 180,
                cd = 25.0,
                type = "heal_ally",
                range = 7,
                heal = {min = 200, max = 320},
                effect = CONST_ME_MAGIC_BLUE,
                priority = 6
            },
            {
                name = "exura gran mas res",
                words = "exura gran mas res",
                level = 35,
                mana = 250,
                cd = 15.0,
                type = "heal_area",
                radius = 4,
                heal = {min = 150, max = 250},
                effect = CONST_ME_MAGIC_BLUE,
                priority = 7
            }
        },
        potionType = "mana",
        buyPriority = {"rod", "armor", "spellbook", "helmet", "rune", "potion"}
    }
}

-- ==========================================================
-- PRIORIDADES DE LANE POR VOCAÇÃO
-- ==========================================================

MOBA_BOTS.VOCATIONS = {
    knight = {
        priority = {"top", "mid", "bot"},
        preferSolo = false,
        canRoam = true,
        roamPriority = 2
    },
    paladin = {
        priority = {"bot", "mid", "top"},
        preferSolo = false,
        canRoam = true,
        roamPriority = 3
    },
    sorcerer = {
        priority = {"mid", "bot", "top"},
        preferSolo = true,
        canRoam = false,
        roamPriority = 1
    },
    druid = {
        priority = {"bot", "top", "mid"},
        preferSolo = false,
        canRoam = true,
        roamPriority = 4
    }
}

-- ==========================================================
-- TIMES
-- ==========================================================

MOBA_BOTS.TEAMS = {
    [1] = {
        id = 1,
        name = "Luz",
        skull = SKULL_GREEN,
        enemySkull = SKULL_RED,
        spawn = Position(253, 1050, 7),
        healZone = {
            from = Position(249, 1044, 7),
            to = Position(261, 1056, 7)
        },
        baseZone = {
            from = Position(251, 1032, 7),
            to = Position(271, 1054, 7)
        },
        shopZone = {
            from = Position(250, 1045, 7),
            to = Position(258, 1053, 7)
        },
        direction = DIRECTION_NORTH,
        advanceDirection = -1
    },
    [2] = {
        id = 2,
        name = "Sombra",
        skull = SKULL_RED,
        enemySkull = SKULL_GREEN,
        spawn = Position(381, 924, 7),
        healZone = {
            from = Position(375, 918, 7),
            to = Position(387, 930, 7)
        },
        baseZone = {
            from = Position(362, 921, 7),
            to = Position(386, 941, 7)
        },
        shopZone = {
            from = Position(376, 920, 7),
            to = Position(384, 928, 7)
        },
        direction = DIRECTION_SOUTH,
        advanceDirection = 1
    }
}

-- ==========================================================
-- SPELL PATTERNS
-- ==========================================================

MOBA_BOTS.SPELL_PATTERNS = {
    adjacent = {
        type = "static",
        positions = {
            {x = -1, y = -1}, {x = 0, y = -1}, {x = 1, y = -1},
            {x = -1, y = 0},                   {x = 1, y = 0},
            {x = -1, y = 1},  {x = 0, y = 1},  {x = 1, y = 1}
        }
    },
    small_area = {
        type = "radius",
        radius = 3
    },
    medium_area = {
        type = "radius",
        radius = 4
    },
    large_area = {
        type = "radius",
        radius = 5
    },
    huge_area = {
        type = "radius",
        radius = 6
    },
    cross = {
        type = "static",
        positions = {
            {x = 0, y = -1},
            {x = -1, y = 0}, {x = 1, y = 0},
            {x = 0, y = 1}
        }
    },
    line_north = {
        type = "directional",
        direction = DIRECTION_NORTH,
        length = 5,
        width = 1
    },
    line_south = {
        type = "directional",
        direction = DIRECTION_SOUTH,
        length = 5,
        width = 1
    },
    line_east = {
        type = "directional",
        direction = DIRECTION_EAST,
        length = 5,
        width = 1
    },
    line_west = {
        type = "directional",
        direction = DIRECTION_WEST,
        length = 5,
        width = 1
    }
}

-- ==========================================================
-- SISTEMA DE ITENS E LOJA
-- ==========================================================

MOBA_BOTS.SHOP_ITEMS = {
    knight = {
        weapons = {
            {id = 8602, name = "Jagged Sword", price = 200, level = 8, bonusAtk = 5, slot = "weapon"},
            {id = 2392, name = "Fire Sword", price = 2500, level = 20, bonusAtk = 18, slot = "weapon"},
            {id = 7404, name = "Assassin Dagger", price = 5000, level = 40, bonusAtk = 28, slot = "weapon"},
            {id = 2400, name = "Magic Sword", price = 25000, level = 50, bonusAtk = 45, slot = "weapon"}
        },
        armor = {
            {id = 2465, name = "Brass Armor", price = 100, level = 5, bonusHp = 40, bonusDef = 3, slot = "armor"},
            {id = 2463, name = "Plate Armor", price = 400, level = 10, bonusHp = 70, bonusDef = 5, slot = "armor"},
            {id = 2476, name = "Knight Armor", price = 2000, level = 20, bonusHp = 120, bonusDef = 8, slot = "armor"},
            {id = 2487, name = "Crown Armor", price = 5000, level = 30, bonusHp = 180, bonusDef = 10, slot = "armor"},
            {id = 2472, name = "Magic Plate Armor", price = 25000, level = 50, bonusHp = 300, bonusDef = 15, slot = "armor"}
        },
        shield = {
            {id = 2510, name = "Plate Shield", price = 100, level = 1, bonusHp = 25, bonusDef = 2, slot = "shield"},
            {id = 2525, name = "Dwarven Shield", price = 500, level = 10, bonusHp = 50, bonusDef = 4, slot = "shield"},
            {id = 2519, name = "Crown Shield", price = 4000, level = 30, bonusHp = 100, bonusDef = 7, slot = "shield"},
            {id = 2534, name = "Vampire Shield", price = 6000, level = 40, bonusHp = 130, bonusDef = 9, slot = "shield"},
            {id = 2514, name = "Mastermind Shield", price = 15000, level = 50, bonusHp = 180, bonusDef = 12, slot = "shield"}
        },
        helmet = {
            {id = 2457, name = "Steel Helmet", price = 300, level = 10, bonusHp = 30, bonusDef = 2, slot = "helmet"},
            {id = 2497, name = "Crown Helmet", price = 2500, level = 25, bonusHp = 60, bonusDef = 4, slot = "helmet"},
            {id = 2498, name = "Royal Helmet", price = 10000, level = 40, bonusHp = 100, bonusDef = 6, slot = "helmet"}
        },
        boots = {
            {id = 2643, name = "Leather Boots", price = 50, level = 1, bonusSpeed = 5, slot = "boots"},
            {id = 2195, name = "Boots of Haste", price = 15000, level = 20, bonusSpeed = 25, slot = "boots"}
        },
        potions = {
            {id = 7618, name = "Health Potion", price = 45, level = 1, type = "hp", heal = 150},
            {id = 7588, name = "Strong Health Potion", price = 100, level = 50, type = "hp", heal = 400},
            {id = 7591, name = "Great Health Potion", price = 190, level = 80, type = "hp", heal = 600}
        }
    },
    
    paladin = {
        weapons = {
            {id = 2456, name = "Bow", price = 100, level = 1, bonusAtk = 2, slot = "weapon"},
            {id = 7438, name = "Elvish Bow", price = 1500, level = 20, bonusAtk = 10, slot = "weapon"},
            {id = 8857, name = "Silkweaver Bow", price = 4000, level = 30, bonusAtk = 18, slot = "weapon"},
            {id = 8855, name = "Composite Hornbow", price = 8000, level = 45, bonusAtk = 28, slot = "weapon"},
            {id = 8854, name = "Warsinger Bow", price = 30000, level = 50, bonusAtk = 40, slot = "weapon"}
        },
        ammo = {
            {id = 2544, name = "Arrows", price = 200, level = 1, count = 100, bonusAtk = 2},
            {id = 7365, name = "Onyx Arrows", price = 1500, level = 40, count = 100, bonusAtk = 10},
            {id = 7364, name = "Sniper Arrows", price = 2000, level = 50, count = 100, bonusAtk = 12}
        },
        armor = {
            {id = 2660, name = "Ranger's Cloak", price = 200, level = 1, bonusHp = 25, bonusDef = 2, slot = "armor"},
            {id = 2465, name = "Brass Armor", price = 300, level = 8, bonusHp = 45, bonusDef = 3, slot = "armor"},
            {id = 8891, name = "Paladin Armor", price = 8000, level = 20, bonusHp = 140, bonusDef = 8, bonusDist = 3, slot = "armor"},
            {id = 2487, name = "Crown Armor", price = 5000, level = 30, bonusHp = 170, bonusDef = 10, slot = "armor"}
        },
        helmet = {
            {id = 2480, name = "Legion Helmet", price = 100, level = 8, bonusHp = 20, bonusDef = 1, slot = "helmet"},
            {id = 2497, name = "Crown Helmet", price = 2500, level = 25, bonusHp = 55, bonusDef = 3, slot = "helmet"}
        },
        boots = {
            {id = 2643, name = "Leather Boots", price = 50, level = 1, bonusSpeed = 5, slot = "boots"},
            {id = 2195, name = "Boots of Haste", price = 15000, level = 20, bonusSpeed = 25, slot = "boots"}
        },
        potions = {
            {id = 7618, name = "Health Potion", price = 45, level = 1, type = "hp", heal = 150},
            {id = 7588, name = "Strong Health Potion", price = 100, level = 50, type = "hp", heal = 400}
        }
    },
    
    sorcerer = {
        wands = {
            {id = 2190, name = "Wand of Vortex", price = 200, level = 8, bonusAtk = 6, slot = "weapon"},
            {id = 2191, name = "Wand of Dragonbreath", price = 500, level = 13, bonusAtk = 12, slot = "weapon"},
            {id = 2188, name = "Wand of Decay", price = 1000, level = 19, bonusAtk = 20, slot = "weapon"},
            {id = 2187, name = "Wand of Cosmic Energy", price = 2500, level = 26, bonusAtk = 30, slot = "weapon"},
            {id = 8920, name = "Wand of Starstorm", price = 5000, level = 33, bonusAtk = 42, slot = "weapon"},
            {id = 8922, name = "Wand of Voodoo", price = 6000, level = 42, bonusAtk = 48, slot = "weapon"},
            {id = 2186, name = "Wand of Inferno", price = 8000, level = 33, bonusAtk = 55, slot = "weapon"}
        },
        armor = {
            {id = 8819, name = "Magician's Robe", price = 100, level = 1, bonusHp = 18, bonusMl = 1, slot = "armor"},
            {id = 8867, name = "Spirit Cloak", price = 800, level = 10, bonusHp = 35, bonusMl = 2, slot = "armor"},
            {id = 8871, name = "Focus Cape", price = 4000, level = 25, bonusHp = 70, bonusMl = 3, slot = "armor"},
            {id = 2656, name = "Blue Robe", price = 7000, level = 40, bonusHp = 120, bonusMl = 4, slot = "armor"}
        },
        spellbook = {
            {id = 2518, name = "Beholder Shield", price = 1000, level = 15, bonusHp = 25, bonusMl = 1, slot = "shield"},
            {id = 8900, name = "Spellbook of Enlightenment", price = 3500, level = 30, bonusHp = 45, bonusMl = 2, bonusAtk = 5, slot = "shield"},
            {id = 8902, name = "Spellbook of Mind Control", price = 8000, level = 40, bonusHp = 60, bonusMl = 3, bonusAtk = 10, slot = "shield"}
        },
        helmet = {
            {id = 2323, name = "Hat of the Mad", price = 2500, level = 20, bonusHp = 25, bonusMl = 2, slot = "helmet"},
            {id = 8820, name = "Magician's Hat", price = 5000, level = 35, bonusHp = 40, bonusMl = 3, slot = "helmet"}
        },
        runes = {
            {id = 2311, name = "HMM Rune", price = 1000, level = 25, count = 50, type = "attack", damage = {min = 60, max = 100}},
            {id = 2304, name = "GFB Rune", price = 2500, level = 30, count = 50, type = "attack_area", damage = {min = 80, max = 140}},
            {id = 2268, name = "SD Rune", price = 5000, level = 45, count = 50, type = "attack", damage = {min = 150, max = 250}}
        },
        potions = {
            {id = 7620, name = "Mana Potion", price = 50, level = 1, type = "mana", restore = 100},
            {id = 7589, name = "Strong Mana Potion", price = 80, level = 50, type = "mana", restore = 200},
            {id = 7590, name = "Great Mana Potion", price = 120, level = 80, type = "mana", restore = 350}
        }
    },
    
    druid = {
        rods = {
            {id = 2182, name = "Snakebite Rod", price = 200, level = 8, bonusAtk = 6, slot = "weapon"},
            {id = 2186, name = "Moonlight Rod", price = 500, level = 13, bonusAtk = 12, slot = "weapon"},
            {id = 2185, name = "Necrotic Rod", price = 1000, level = 19, bonusAtk = 20, slot = "weapon"},
            {id = 2181, name = "Terra Rod", price = 2500, level = 26, bonusAtk = 30, slot = "weapon"},
            {id = 2183, name = "Hailstorm Rod", price = 5000, level = 33, bonusAtk = 42, slot = "weapon"},
            {id = 8912, name = "Springsprout Rod", price = 6000, level = 42, bonusAtk = 48, slot = "weapon"},
            {id = 8910, name = "Underworld Rod", price = 8000, level = 42, bonusAtk = 55, slot = "weapon"}
        },
        armor = {
            {id = 8819, name = "Magician's Robe", price = 100, level = 1, bonusHp = 18, bonusMl = 1, slot = "armor"},
            {id = 8867, name = "Spirit Cloak", price = 800, level = 10, bonusHp = 35, bonusMl = 2, slot = "armor"},
            {id = 8871, name = "Focus Cape", price = 4000, level = 25, bonusHp = 70, bonusMl = 3, slot = "armor"}
        },
        spellbook = {
            {id = 2525, name = "Dwarven Shield", price = 500, level = 10, bonusHp = 25, bonusDef = 3, slot = "shield"},
            {id = 8900, name = "Spellbook of Enlightenment", price = 3500, level = 30, bonusHp = 45, bonusMl = 2, bonusAtk = 5, slot = "shield"},
            {id = 8902, name = "Spellbook of Mind Control", price = 8000, level = 40, bonusHp = 60, bonusMl = 3, bonusAtk = 10, slot = "shield"}
        },
        helmet = {
            {id = 8820, name = "Terra Hood", price = 2500, level = 20, bonusHp = 30, bonusMl = 2, slot = "helmet"}
        },
        runes = {
            {id = 2273, name = "UH Rune", price = 2000, level = 24, count = 50, type = "heal", heal = {min = 200, max = 300}},
            {id = 2274, name = "Avalanche Rune", price = 2500, level = 30, count = 50, type = "attack_area", damage = {min = 70, max = 130}},
            {id = 2278, name = "Paralyze Rune", price = 4000, level = 45, count = 50, type = "debuff", effect = "slow"}
        },
        potions = {
            {id = 7620, name = "Mana Potion", price = 50, level = 1, type = "mana", restore = 100},
            {id = 7589, name = "Strong Mana Potion", price = 80, level = 50, type = "mana", restore = 200}
        }
    }
}

-- ==========================================================
-- DADOS GLOBAIS E CACHE
-- ==========================================================

MOBA_BOTS.Data = {}
MOBA_BOTS.PathCache = {}
MOBA_BOTS.PathCacheTime = {}
MOBA_BOTS.PersistentLanes = {}
MOBA_BOTS.LaneSlots = {[1] = {top = {}, mid = {}, bot = {}}, [2] = {top = {}, mid = {}, bot = {}}}
MOBA_BOTS.BlockedPositions = {}
MOBA_BOTS.DamageTracker = {}
MOBA_BOTS.TeamFocus = {[1] = nil, [2] = nil}
MOBA_BOTS.LastTeamFocusTime = {[1] = 0, [2] = 0}

MOBA_BOTS.TeamScores = {
    [1] = {kills = 0, deaths = 0, assists = 0, towersDestroyed = 0, totalGold = 0, totalExp = 0, minionsKilled = 0, nexusDestroyed = false},
    [2] = {kills = 0, deaths = 0, assists = 0, towersDestroyed = 0, totalGold = 0, totalExp = 0, minionsKilled = 0, nexusDestroyed = false}
}

MOBA_BOTS.PlayerStats = {}
MOBA_BOTS.MatchStartTime = 0
MOBA_BOTS.WaveCount = {[1] = 0, [2] = 0}

-- ==========================================================
-- DIREÇÕES E OFFSETS
-- ==========================================================

local DIR_OFFSETS = {
    [DIRECTION_NORTH] = {x = 0, y = -1},
    [DIRECTION_SOUTH] = {x = 0, y = 1},
    [DIRECTION_EAST] = {x = 1, y = 0},
    [DIRECTION_WEST] = {x = -1, y = 0},
    [DIRECTION_NORTHEAST] = {x = 1, y = -1},
    [DIRECTION_NORTHWEST] = {x = -1, y = -1},
    [DIRECTION_SOUTHEAST] = {x = 1, y = 1},
    [DIRECTION_SOUTHWEST] = {x = -1, y = 1}
}

local PERPENDICULAR_DIRS = {
    [DIRECTION_NORTH] = {DIRECTION_EAST, DIRECTION_WEST},
    [DIRECTION_SOUTH] = {DIRECTION_EAST, DIRECTION_WEST},
    [DIRECTION_EAST] = {DIRECTION_NORTH, DIRECTION_SOUTH},
    [DIRECTION_WEST] = {DIRECTION_NORTH, DIRECTION_SOUTH}
}

local OPPOSITE_DIR = {
    [DIRECTION_NORTH] = DIRECTION_SOUTH,
    [DIRECTION_SOUTH] = DIRECTION_NORTH,
    [DIRECTION_EAST] = DIRECTION_WEST,
    [DIRECTION_WEST] = DIRECTION_EAST
}

local ALL_DIRECTIONS = {DIRECTION_NORTH, DIRECTION_SOUTH, DIRECTION_EAST, DIRECTION_WEST}
local ALL_DIRECTIONS_8 = {DIRECTION_NORTH, DIRECTION_NORTHEAST, DIRECTION_EAST, DIRECTION_SOUTHEAST, DIRECTION_SOUTH, DIRECTION_SOUTHWEST, DIRECTION_WEST, DIRECTION_NORTHWEST}

-- ==========================================================
-- FUNÇÕES UTILITÁRIAS BÁSICAS
-- ==========================================================

local function botDist(p1, p2)
    if not p1 or not p2 then return 999 end
    local dx = math.abs((p1.x or 0) - (p2.x or 0))
    local dy = math.abs((p1.y or 0) - (p2.y or 0))
    return math.max(dx, dy)
end

local function euclideanDist(p1, p2)
    if not p1 or not p2 then return 999 end
    local dx = (p1.x or 0) - (p2.x or 0)
    local dy = (p1.y or 0) - (p2.y or 0)
    return math.sqrt(dx * dx + dy * dy)
end

local function manhattanDist(p1, p2)
    if not p1 or not p2 then return 999 end
    return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y)
end

local function posKey(pos)
    if not pos then return "0_0_0" end
    return (pos.x or 0) .. "_" .. (pos.y or 0) .. "_" .. (pos.z or 7)
end

local function posEqual(p1, p2)
    if not p1 or not p2 then return false end
    return p1.x == p2.x and p1.y == p2.y and p1.z == p2.z
end

local function clonePos(pos)
    if not pos then return nil end
    return Position(pos.x, pos.y, pos.z)
end

local function getNextPos(pos, dir)
    local offset = DIR_OFFSETS[dir]
    if not offset then return nil end
    return Position(pos.x + offset.x, pos.y + offset.y, pos.z)
end

local function getDirectionTo(from, to)
    if not from or not to then return DIRECTION_SOUTH end
    local dx = to.x - from.x
    local dy = to.y - from.y
    
    if math.abs(dx) >= math.abs(dy) then
        return dx > 0 and DIRECTION_EAST or DIRECTION_WEST
    else
        return dy > 0 and DIRECTION_SOUTH or DIRECTION_NORTH
    end
end

local function getDirectionTo8(from, to)
    if not from or not to then return DIRECTION_SOUTH end
    local dx = to.x - from.x
    local dy = to.y - from.y
    local adx, ady = math.abs(dx), math.abs(dy)
    
    if adx < 1 and ady < 1 then
        return DIRECTION_SOUTH
    elseif adx > ady * 2 then
        return dx > 0 and DIRECTION_EAST or DIRECTION_WEST
    elseif ady > adx * 2 then
        return dy > 0 and DIRECTION_SOUTH or DIRECTION_NORTH
    else
        if dx > 0 then
            return dy > 0 and DIRECTION_SOUTHEAST or DIRECTION_NORTHEAST
        else
            return dy > 0 and DIRECTION_SOUTHWEST or DIRECTION_NORTHWEST
        end
    end
end

local function getOppositeDirection(dir)
    return OPPOSITE_DIR[dir] or DIRECTION_SOUTH
end

local function randomElement(t)
    if not t or #t == 0 then return nil end
    return t[math.random(1, #t)]
end

local function tableContains(t, value)
    for _, v in pairs(t) do
        if v == value then return true end
    end
    return false
end

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function lerp(a, b, t)
    return a + (b - a) * clamp(t, 0, 1)
end

-- ==========================================================
-- FUNÇÕES DE LOG
-- ==========================================================

local function logBot(data, action, details)
    if not data then return end
    local teamName = data.teamId == 1 and "LUZ" or "SOMBRA"
    local className = (data.class or "?"):upper()
    local msg = string.format("[BOT %s][%s] %s", teamName, className, action)
    if details then
        msg = msg .. ": " .. tostring(details)
    end
    print(msg)
end

local function logPurchase(data, itemName, price, category)
    if not MOBA_BOTS.CONFIG.LOG_PURCHASES then return end
    logBot(data, "COMPROU", string.format("%s por %d gold (%s)", itemName, price, category))
end

local function logEquip(data, itemName)
    if not MOBA_BOTS.CONFIG.LOG_PURCHASES then return end
    logBot(data, "EQUIPOU", itemName)
end

local function logUseItem(data, itemName, context)
    if not MOBA_BOTS.CONFIG.LOG_PURCHASES then return end
    logBot(data, "USOU", string.format("%s (%s)", itemName, context or ""))
end

local function logSpell(data, spellName, targetName)
    if not MOBA_BOTS.CONFIG.LOG_SPELLS then return end
    if targetName then
        logBot(data, "SPELL", string.format("%s em %s", spellName, targetName))
    else
        logBot(data, "SPELL", spellName)
    end
end

local function logStateChange(data, oldState, newState)
    if not MOBA_BOTS.CONFIG.LOG_STATE_CHANGES then return end
    local oldName = MOBA_BOTS.STATE_NAMES[oldState] or "?"
    local newName = MOBA_BOTS.STATE_NAMES[newState] or "?"
    logBot(data, "STATE", string.format("%s -> %s", oldName, newName))
end

local function debugPrint(category, msg)
    if not MOBA_BOTS.CONFIG.DEBUG_ENABLED then return end
    if category == "movement" and not MOBA_BOTS.CONFIG.DEBUG_MOVEMENT then return end
    if category == "combat" and not MOBA_BOTS.CONFIG.DEBUG_COMBAT then return end
    if category == "decisions" and not MOBA_BOTS.CONFIG.DEBUG_DECISIONS then return end
    print("[DEBUG][" .. category:upper() .. "] " .. tostring(msg))
end

-- ==========================================================
-- FUNÇÕES DE DETECÇÃO DE CRIATURAS
-- ==========================================================

local function isHero(creature)
    if not creature then return false end
    if creature:isPlayer() then return true end
    local cid = creature:getId()
    return MOBA_BOTS.Data[cid] ~= nil
end

local function isMinion(creature)
    if not creature then return false end
    if creature:isPlayer() then return false end
    local cid = creature:getId()
    if MOBA_BOTS.Data[cid] then return false end
    local state = MOBA.MinionState and MOBA.MinionState[cid]
    if not state then return false end
    return not state.isStructure and not state.isNexus and not state.isBot
end

local function isTower(creature)
    if not creature then return false end
    if creature:isPlayer() then return false end
    local cid = creature:getId()
    local state = MOBA.MinionState and MOBA.MinionState[cid]
    return state and state.isStructure and not state.isNexus
end

local function isNexus(creature)
    if not creature then return false end
    if creature:isPlayer() then return false end
    local cid = creature:getId()
    local state = MOBA.MinionState and MOBA.MinionState[cid]
    return state and state.isNexus
end

local function isStructure(creature)
    return isTower(creature) or isNexus(creature)
end

local function isGM(creature)
    if not creature then return false end
    if not creature:isPlayer() then return false end
    local ok, result = pcall(function() return creature:getGroup():getAccess() end)
    return ok and result
end

local function getCreatureTeam(creature)
    if not creature then return 0 end
    local cid = creature:getId()
    
    local botData = MOBA_BOTS.Data[cid]
    if botData then return botData.teamId end
    
    if creature:isPlayer() then
        local ok, team = pcall(function() return creature:getStorageValue(MOBA.STORAGE_TEAM) end)
        if ok and team and team > 0 then return team end
        return 0
    end
    
    local state = MOBA.MinionState and MOBA.MinionState[cid]
    if state then return state.teamId or 0 end
    
    return 0
end

local function isAllyTeam(creature, data)
    if not creature or not data then return false end
    return getCreatureTeam(creature) == data.teamId
end

local function isEnemyTeam(creature, data)
    if not creature or not data then return false end
    local ct = getCreatureTeam(creature)
    return ct ~= 0 and ct ~= data.teamId
end

local function isValidTarget(creature)
    if not creature then return false end
    local ok, hp = pcall(function() return creature:getHealth() end)
    return ok and hp and hp > 0
end

local function canAttackTarget(target, data)
    if not target or not data then return false end
    if not isValidTarget(target) then return false end
    return isEnemyTeam(target, data)
end

local function getCreatureName(creature)
    if not creature then return "?" end
    local ok, name = pcall(function() return creature:getName() end)
    return ok and name or "?"
end

local function getCreatureHealthPercent(creature)
    if not creature then return 0 end
    local ok, result = pcall(function() 
        return creature:getHealth() / creature:getMaxHealth() 
    end)
    return ok and result or 0
end

-- ==========================================================
-- FUNÇÕES DE ZONA
-- ==========================================================

local function isInZone(pos, zone)
    if not pos or not zone or not zone.from or not zone.to then return false end
    return pos.x >= zone.from.x and pos.x <= zone.to.x and
           pos.y >= zone.from.y and pos.y <= zone.to.y and
           pos.z == zone.from.z
end

local function isInHealZone(pos, teamId)
    local team = MOBA_BOTS.TEAMS[teamId]
    return team and isInZone(pos, team.healZone)
end

local function isInBaseZone(pos, teamId)
    local team = MOBA_BOTS.TEAMS[teamId]
    return team and isInZone(pos, team.baseZone)
end

local function isInShopZone(pos, teamId)
    local team = MOBA_BOTS.TEAMS[teamId]
    return team and team.shopZone and isInZone(pos, team.shopZone)
end

-- ==========================================================
-- SISTEMA DE DANO E ESTATÍSTICAS
-- ==========================================================

function MOBA_BOTS.registerDamage(targetId, damageType, amount, attackerId)
    if not MOBA_BOTS.DamageTracker[targetId] then
        MOBA_BOTS.DamageTracker[targetId] = {
            total = 0,
            sources = {},
            lastTime = os.time(),
            byType = {}
        }
    end
    
    local tracker = MOBA_BOTS.DamageTracker[targetId]
    tracker.total = tracker.total + amount
    tracker.lastTime = os.time()
    tracker.byType[damageType] = (tracker.byType[damageType] or 0) + amount
    
    if attackerId then
        if not tracker.sources[attackerId] then
            tracker.sources[attackerId] = {
                total = 0,
                lastHit = os.time()
            }
        end
        tracker.sources[attackerId].total = tracker.sources[attackerId].total + amount
        tracker.sources[attackerId].lastHit = os.time()
    end
end

function MOBA_BOTS.getAssists(targetId, killerId, timeWindow)
    timeWindow = timeWindow or 10
    local assists = {}
    local tracker = MOBA_BOTS.DamageTracker[targetId]
    
    if not tracker then return assists end
    
    local now = os.time()
    for attackerId, info in pairs(tracker.sources) do
        if attackerId ~= killerId and info.total > 0 then
            if now - info.lastHit <= timeWindow then
                table.insert(assists, {
                    id = attackerId,
                    damage = info.total
                })
            end
        end
    end
    
    table.sort(assists, function(a, b) return a.damage > b.damage end)
    return assists
end

function MOBA_BOTS.clearDamageTracker(targetId)
    MOBA_BOTS.DamageTracker[targetId] = nil
end

function MOBA_BOTS.cleanupDamageTrackers()
    local now = os.time()
    local toRemove = {}
    
    for targetId, tracker in pairs(MOBA_BOTS.DamageTracker) do
        if now - tracker.lastTime > 60 then
            table.insert(toRemove, targetId)
        end
    end
    
    for _, id in ipairs(toRemove) do
        MOBA_BOTS.DamageTracker[id] = nil
    end
end

function MOBA_BOTS.registerStat(cid, statType, value)
    value = value or 1
    
    local data = MOBA_BOTS.Data[cid]
    if data then
        if statType == "kill" then
            data.kills = (data.kills or 0) + value
        elseif statType == "death" then
            data.deaths = (data.deaths or 0) + value
        elseif statType == "assist" then
            data.assists = (data.assists or 0) + value
        end
    end
    
    local creature = Creature(cid)
    if creature and creature:isPlayer() then
        if not MOBA_BOTS.PlayerStats[cid] then
            MOBA_BOTS.PlayerStats[cid] = {
                kills = 0, deaths = 0, assists = 0,
                gold = 0, exp = 0, damage = 0, healing = 0
            }
        end
        MOBA_BOTS.PlayerStats[cid][statType] = (MOBA_BOTS.PlayerStats[cid][statType] or 0) + value
    end
end

function MOBA_BOTS.addScore(teamId, scoreType, amount)
    if not MOBA_BOTS.TeamScores[teamId] then
        MOBA_BOTS.TeamScores[teamId] = {
            kills = 0, deaths = 0, assists = 0,
            towersDestroyed = 0, totalGold = 0, totalExp = 0,
            minionsKilled = 0, nexusDestroyed = false
        }
    end
    
    if scoreType == "nexusDestroyed" then
        MOBA_BOTS.TeamScores[teamId][scoreType] = true
    else
        MOBA_BOTS.TeamScores[teamId][scoreType] = (MOBA_BOTS.TeamScores[teamId][scoreType] or 0) + amount
    end
end

function MOBA_BOTS.resetScoreboard()
    MOBA_BOTS.TeamScores = {
        [1] = {kills = 0, deaths = 0, assists = 0, towersDestroyed = 0, totalGold = 0, totalExp = 0, minionsKilled = 0, nexusDestroyed = false},
        [2] = {kills = 0, deaths = 0, assists = 0, towersDestroyed = 0, totalGold = 0, totalExp = 0, minionsKilled = 0, nexusDestroyed = false}
    }
end

function MOBA_BOTS.resetPlayerStats()
    MOBA_BOTS.PlayerStats = {}
end

-- ==========================================================
-- SISTEMA DE ESTADO
-- ==========================================================

local function setState(data, newState)
    if not data then return end
    if data.state == newState then return end
    
    local oldState = data.state
    data.state = newState
    data.stateTime = os.clock()
    data.stateLoops = 0
    
    if MOBA_BOTS.CONFIG.LOG_STATE_CHANGES then
        logStateChange(data, oldState, newState)
    end
end

local function getStateTime(data)
    if not data or not data.stateTime then return 0 end
    return os.clock() - data.stateTime
end

local function isInState(data, ...)
    if not data then return false end
    for _, state in ipairs({...}) do
        if data.state == state then return true end
    end
    return false
end

-- ==========================================================
-- SISTEMA DE STATUS DE COMBATE
-- ==========================================================

local function isUnderAttack(data)
    if not data or not data.lastDamageTime then return false end
    return (os.clock() - data.lastDamageTime) < 3.0
end

local function isUnderHeavyAttack(data)
    if not data or not data.lastDamageTime then return false end
    if not data.recentDamage then return false end
    return (os.clock() - data.lastDamageTime) < 2.0 and data.recentDamage > 100
end

local function isUnderTowerAttack(data)
    if not data or not data.lastTowerDamageTime then return false end
    return (os.clock() - data.lastTowerDamageTime) < MOBA_BOTS.CONFIG.TOWER_AGGRO_DURATION
end

local function isSafe(data)
    if not data then return false end
    return not isUnderAttack(data) and not isUnderTowerAttack(data)
end

local function isInCombat(data)
    if not data then return false end
    local now = os.clock()
    local recentDamage = data.lastDamageTime and (now - data.lastDamageTime) < 5.0
    local recentAttack = data.lastAtk and (now - data.lastAtk) < 3.0
    return recentDamage or recentAttack
end

local function getTimeSinceLastCombat(data)
    if not data then return 999 end
    local now = os.clock()
    local sinceDamage = data.lastDamageTime and (now - data.lastDamageTime) or 999
    local sinceAttack = data.lastAtk and (now - data.lastAtk) or 999
    return math.min(sinceDamage, sinceAttack)
end

-- ==========================================================
-- SISTEMA DE RECALL
-- ==========================================================

local function startRecall(data, bot)
    if not data or not bot then return false end
    if data.state == MOBA_BOTS.STATE.RECALLING then return false end
    
    setState(data, MOBA_BOTS.STATE.RECALLING)
    data.recallStartTime = os.clock()
    data.recallPos = clonePos(bot:getPosition())
    data.recallInitialHp = bot:getHealth()
    data.lastRecallEffect = 0
    
    bot:say("Recalling...", TALKTYPE_MONSTER_SAY)
    bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    
    logBot(data, "RECALL", "Iniciando recall")
    return true
end

local function cancelRecall(data, reason)
    if not data then return end
    if data.state ~= MOBA_BOTS.STATE.RECALLING then return end
    
    data.recallStartTime = nil
    data.recallPos = nil
    data.recallInitialHp = nil
    
    logBot(data, "RECALL", "Cancelado: " .. (reason or "unknown"))
end

local function processRecall(bot, data)
    if not bot or not data then return false end
    if data.state ~= MOBA_BOTS.STATE.RECALLING then return false end
    if not data.recallStartTime then
        cancelRecall(data, "no start time")
        setState(data, MOBA_BOTS.STATE.LANING)
        return false
    end
    
    local elapsed = os.clock() - data.recallStartTime
    local cfg = MOBA_BOTS.CONFIG
    local currentPos = bot:getPosition()
    
    -- Verifica se moveu
    if data.recallPos then
        if botDist(currentPos, data.recallPos) > 1 then
            cancelRecall(data, "moved")
            setState(data, MOBA_BOTS.STATE.LANING)
            return false
        end
    end
    
    -- Verifica se tomou dano significativo
    if data.recallInitialHp then
        local currentHp = bot:getHealth()
        local hpLost = (data.recallInitialHp - currentHp) / bot:getMaxHealth()
        if hpLost > cfg.RECALL_CANCEL_DAMAGE_THRESHOLD then
            cancelRecall(data, "took damage")
            setState(data, MOBA_BOTS.STATE.RETREATING)
            return false
        end
    end
    
    -- Efeito visual periódico
    if elapsed - (data.lastRecallEffect or 0) >= cfg.RECALL_EFFECT_INTERVAL then
        currentPos:sendMagicEffect(CONST_ME_MAGIC_BLUE)
        data.lastRecallEffect = elapsed
        
        local remaining = math.ceil(cfg.RECALL_TIME - elapsed)
        if remaining > 0 and remaining <= 5 then
            bot:say(remaining .. "...", TALKTYPE_MONSTER_SAY)
        end
    end
    
    -- Completa recall
    if elapsed >= cfg.RECALL_TIME then
        local team = MOBA_BOTS.TEAMS[data.teamId]
        bot:teleportTo(team.spawn)
        bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
        
        data.recallStartTime = nil
        data.recallPos = nil
        data.recallInitialHp = nil
        data.lastRecallEffect = nil
        
        setState(data, MOBA_BOTS.STATE.IN_BASE)
        logBot(data, "RECALL", "Completo!")
        return true
    end
    
    return true -- Ainda em recall
end

-- ==========================================================
-- SISTEMA DE TORRES
-- ==========================================================

local function findNearestEnemyTower(bot, data)
    if not MOBA or not MOBA.Objectives then return nil, 999 end
    if not bot or not data then return nil, 999 end
    
    local pos = bot:getPosition()
    local enemyTeamId = data.teamId == 1 and 2 or 1
    local enemyTeamObj = MOBA.getTeamById(enemyTeamId)
    local objectives = MOBA.Objectives[enemyTeamId]
    
    if not objectives or not enemyTeamObj then return nil, 999 end
    
    local nearest, nearestDist = nil, 999
    
    for _, lane in ipairs({"top", "mid", "bot"}) do
        local laneTowers = objectives.towers[lane]
        if laneTowers then
            for i = 1, 3 do
                if laneTowers[i] then
                    local towerCfg = enemyTeamObj.towers[lane][i]
                    if towerCfg then
                        local towerPos = Position(towerCfg.pos.x, towerCfg.pos.y, towerCfg.pos.z)
                        local d = botDist(pos, towerPos)
                        if d < nearestDist then
                            local specs = Game.getSpectators(towerPos, false, false, 2, 2, 2, 2)
                            for _, s in ipairs(specs) do
                                if isTower(s) and isEnemyTeam(s, data) and isValidTarget(s) then
                                    nearest = s
                                    nearestDist = d
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nearest, nearestDist
end

local function findNearestAllyTower(bot, data)
    if not MOBA or not MOBA.Objectives then return nil, 999 end
    if not bot or not data then return nil, 999 end
    
    local pos = bot:getPosition()
    local teamObj = MOBA.getTeamById(data.teamId)
    local objectives = MOBA.Objectives[data.teamId]
    
    if not objectives or not teamObj then return nil, 999 end
    
    local nearest, nearestDist = nil, 999
    
    for _, lane in ipairs({"top", "mid", "bot"}) do
        local laneTowers = objectives.towers[lane]
        if laneTowers then
            for i = 1, 3 do
                if laneTowers[i] then
                    local towerCfg = teamObj.towers[lane][i]
                    if towerCfg then
                        local towerPos = Position(towerCfg.pos.x, towerCfg.pos.y, towerCfg.pos.z)
                        local d = botDist(pos, towerPos)
                        if d < nearestDist then
                            local specs = Game.getSpectators(towerPos, false, false, 2, 2, 2, 2)
                            for _, s in ipairs(specs) do
                                if isTower(s) and isAllyTeam(s, data) and isValidTarget(s) then
                                    nearest = s
                                    nearestDist = d
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nearest, nearestDist
end

local function getPosBehind(pos, teamId, distance)
    if not pos then return nil end
    local newPos = clonePos(pos)
    if teamId == 1 then
        newPos.y = newPos.y + distance
    else
        newPos.y = newPos.y - distance
    end
    return newPos
end

local function getPosInFront(pos, teamId, distance)
    if not pos then return nil end
    local newPos = clonePos(pos)
    if teamId == 1 then
        newPos.y = newPos.y - distance
    else
        newPos.y = newPos.y + distance
    end
    return newPos
end

local function getPosAway(from, awayFrom, distance)
    if not from or not awayFrom then return nil end
    local dx = from.x - awayFrom.x
    local dy = from.y - awayFrom.y
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then len = 1 end
    
    return Position(
        math.floor(from.x + (dx / len) * distance + 0.5),
        math.floor(from.y + (dy / len) * distance + 0.5),
        from.z
    )
end

local function isPositionNearEnemyTower(pos, data, env, extraRange)
    if not pos or not env then return false end
    if not env.enemyTowerPos then return false end
    
    extraRange = extraRange or 0
    local cfg = MOBA_BOTS.CONFIG
    return botDist(pos, env.enemyTowerPos) <= cfg.TOWER_RANGE + extraRange
end

local function isPositionSafeFromTower(pos, data, env)
    if not pos or not env then return true end
    if not env.enemyTowerPos then return true end
    
    local distToTower = botDist(pos, env.enemyTowerPos)
    local cfg = MOBA_BOTS.CONFIG
    
    -- Se minions tankando, é seguro até o range da torre
    if env.allyMinionsTankingTower then
        return true
    end
    
    -- Senão, precisa estar fora do range de perigo
    return distToTower > cfg.TOWER_SAFE_DISTANCE
end

-- ==========================================================
-- SISTEMA DE WAYPOINTS
-- ==========================================================

local function getWaypoints(data)
    if not data or not data.assignedLane then return nil end
    return MOBA.getWaypoints(data.teamId, data.assignedLane)
end

local function findNearestWaypointIdx(data, pos)
    local wps = getWaypoints(data)
    if not wps or #wps == 0 then return 1 end
    
    local bestIdx, bestDist = 1, 999
    for i, wp in ipairs(wps) do
        local d = botDist(pos, wp)
        if d < bestDist then
            bestDist = d
            bestIdx = i
        end
    end
    return bestIdx
end

local function getWaypoint(data, index)
    local wps = getWaypoints(data)
    if not wps or #wps == 0 then return nil, 0, 0 end
    
    local idx = index or data.wpIndex or 1
    if idx < 1 then idx = 1 end
    if idx > #wps then idx = #wps end
    
    local wp = wps[idx]
    return Position(wp.x, wp.y, wp.z), idx, #wps
end

local function getRetreatWaypoint(data, currentPos, stepsBack)
    local wps = getWaypoints(data)
    if not wps or #wps == 0 then return nil end
    
    local currentWp = findNearestWaypointIdx(data, currentPos)
    local targetWp = math.max(1, currentWp - stepsBack)
    
    return Position(wps[targetWp].x, wps[targetWp].y, wps[targetWp].z)
end

local function getAdvanceWaypoint(data, currentPos, stepsForward)
    local wps = getWaypoints(data)
    if not wps or #wps == 0 then return nil end
    
    local currentWp = findNearestWaypointIdx(data, currentPos)
    local targetWp = math.min(#wps, currentWp + stepsForward)
    
    return Position(wps[targetWp].x, wps[targetWp].y, wps[targetWp].z)
end

local function updateWaypointToNearest(bot, data)
    if not bot or not data then return end
    local pos = bot:getPosition()
    local wps = getWaypoints(data)
    if not wps or #wps == 0 then return end
    
    local nearestIdx = findNearestWaypointIdx(data, pos)
    local currentWpIdx = data.wpIndex or 1
    
    if currentWpIdx > #wps then currentWpIdx = #wps end
    
    local currentWpPos = Position(wps[currentWpIdx].x, wps[currentWpIdx].y, wps[currentWpIdx].z)
    local nearestWpPos = Position(wps[nearestIdx].x, wps[nearestIdx].y, wps[nearestIdx].z)
    
    local distToCurrent = botDist(pos, currentWpPos)
    local distToNearest = botDist(pos, nearestWpPos)
    
    -- Se está muito mais perto de outro waypoint, atualiza
    if distToNearest < distToCurrent - 5 then
        data.wpIndex = nearestIdx
    end
end

local function isWaypointNearTower(data, wpIdx, enemyTowerPos)
    if not enemyTowerPos then return false end
    
    local wps = getWaypoints(data)
    if not wps or not wps[wpIdx] then return false end
    
    local wpPos = Position(wps[wpIdx].x, wps[wpIdx].y, wps[wpIdx].z)
    return botDist(wpPos, enemyTowerPos) <= MOBA_BOTS.CONFIG.TOWER_RANGE + 2
end

-- ==========================================================
-- SISTEMA DE MOVIMENTO
-- ==========================================================

local function canWalkTo(pos, excludeCid)
    if not pos then return false end
    
    local tile = Tile(pos)
    if not tile then return false end
    
    local ground = tile:getGround()
    if not ground then return false end
    
    -- Verifica criaturas
    local creatures = tile:getCreatures()
    if creatures then
        for _, c in ipairs(creatures) do
            if not excludeCid or c:getId() ~= excludeCid then
                return false
            end
        end
    end
    
    -- Verifica itens bloqueadores
    local items = tile:getItems()
    if items then
        for _, item in ipairs(items) do
            local hasBlock = false
            pcall(function()
                hasBlock = item:hasProperty(CONST_PROP_BLOCKSOLID) or item:hasProperty(CONST_PROP_BLOCKPATH)
            end)
            if hasBlock then
                return false
            end
        end
    end
    
    return true
end

local function tryMoveDirection(bot, dir, data)
    if not bot or not dir then return false end
    
    local pos = bot:getPosition()
    local nextPos = getNextPos(pos, dir)
    
    if not canWalkTo(nextPos, bot:getId()) then
        return false
    end
    
    local moved = bot:move(dir)
    if moved then
        data.stuckCount = 0
        data.lastMoveTime = os.clock()
        data.lastMoveDir = dir
    end
    
    return moved
end

local function getAllDirectionsOrdered(from, to)
    local dirs = {}
    local dx = to.x - from.x
    local dy = to.y - from.y
    
    -- Direção principal baseada no eixo com maior diferença
    if math.abs(dx) >= math.abs(dy) then
        if dx > 0 then table.insert(dirs, DIRECTION_EAST) end
        if dx < 0 then table.insert(dirs, DIRECTION_WEST) end
        if dy > 0 then table.insert(dirs, DIRECTION_SOUTH) end
        if dy < 0 then table.insert(dirs, DIRECTION_NORTH) end
    else
        if dy > 0 then table.insert(dirs, DIRECTION_SOUTH) end
        if dy < 0 then table.insert(dirs, DIRECTION_NORTH) end
        if dx > 0 then table.insert(dirs, DIRECTION_EAST) end
        if dx < 0 then table.insert(dirs, DIRECTION_WEST) end
    end
    
    -- Adiciona direções restantes
    for _, d in ipairs(ALL_DIRECTIONS) do
        local found = false
        for _, existing in ipairs(dirs) do
            if d == existing then found = true break end
        end
        if not found then
            table.insert(dirs, d)
        end
    end
    
    return dirs
end

local function moveTowards(bot, targetPos, data)
    if not bot or not targetPos or not data then return false end
    
    local pos = bot:getPosition()
    local cid = bot:getId()
    
    -- Já chegou
    if botDist(pos, targetPos) <= 1 then
        data.stuckCount = 0
        return true
    end
    
    -- Obtém direções ordenadas por prioridade
    local dirs = getAllDirectionsOrdered(pos, targetPos)
    
    -- Evita voltar na direção oposta à última (reduz zig-zag)
    if data.lastMoveDir then
        local opposite = getOppositeDirection(data.lastMoveDir)
        local newDirs = {}
        for _, d in ipairs(dirs) do
            if d ~= opposite then
                table.insert(newDirs, d)
            end
        end
        -- Adiciona oposta no final como última opção
        table.insert(newDirs, opposite)
        dirs = newDirs
    end
    
    -- Tenta cada direção
    for _, dir in ipairs(dirs) do
        if tryMoveDirection(bot, dir, data) then
            return true
        end
    end
    
    -- Não conseguiu mover, incrementa stuck
    data.stuckCount = (data.stuckCount or 0) + 1
    
    -- Sistema de contorno de obstáculos
    if data.stuckCount >= 3 then
        local perps = PERPENDICULAR_DIRS[dirs[1]] or {DIRECTION_EAST, DIRECTION_WEST}
        local perpIdx = (data.stuckCount % 2) + 1
        
        if tryMoveDirection(bot, perps[perpIdx], data) then
            return true
        end
        if tryMoveDirection(bot, perps[perpIdx == 1 and 2 or 1], data) then
            return true
        end
    end
    
    return false
end

local function moveAway(bot, fromPos, data)
    if not bot or not fromPos or not data then return false end
    
    local pos = bot:getPosition()
    
    -- Calcula direção de fuga
    local dx = pos.x - fromPos.x
    local dy = pos.y - fromPos.y
    
    local dirs = {}
    
    -- Direções principais de fuga
    if math.abs(dx) >= math.abs(dy) then
        table.insert(dirs, dx >= 0 and DIRECTION_EAST or DIRECTION_WEST)
        table.insert(dirs, dy >= 0 and DIRECTION_SOUTH or DIRECTION_NORTH)
    else
        table.insert(dirs, dy >= 0 and DIRECTION_SOUTH or DIRECTION_NORTH)
        table.insert(dirs, dx >= 0 and DIRECTION_EAST or DIRECTION_WEST)
    end
    
    -- Adiciona perpendiculares
    for _, d in ipairs(ALL_DIRECTIONS) do
        local found = false
        for _, existing in ipairs(dirs) do
            if d == existing then found = true break end
        end
        if not found then
            table.insert(dirs, d)
        end
    end
    
    -- Tenta cada direção
    for _, dir in ipairs(dirs) do
        if tryMoveDirection(bot, dir, data) then
            return true
        end
    end
    
    data.stuckCount = (data.stuckCount or 0) + 1
    return false
end

local function advanceLane(bot, data)
    if not bot or not data then return false end
    
    local wps = getWaypoints(data)
    if not wps or #wps == 0 then return false end
    
    local pos = bot:getPosition()
    local wpIdx = data.wpIndex or 1
    local cfg = MOBA_BOTS.CONFIG
    
    if wpIdx > #wps then wpIdx = #wps end
    if wpIdx < 1 then wpIdx = 1 end
    
    local targetWp = wps[wpIdx]
    local targetPos = Position(targetWp.x, targetWp.y, targetWp.z)
    local distToWp = botDist(pos, targetPos)
    
    -- Chegou no waypoint
    if distToWp <= cfg.WP_ARRIVE_DISTANCE then
        if wpIdx < #wps then
            data.wpIndex = wpIdx + 1
            data.stuckCount = 0
        end
        return true
    end
    
    -- Move em direção ao waypoint
    local moved = moveTowards(bot, targetPos, data)
    
    -- Tratamento de stuck
    if not moved then
        data.stuckCount = (data.stuckCount or 0) + 1
        
        -- Pula waypoint se muito stuck
        if data.stuckCount >= cfg.STUCK_CRITICAL_THRESHOLD then
            if wpIdx < #wps then
                data.wpIndex = wpIdx + 1
                data.stuckCount = 0
                logBot(data, "SKIP WP", "Pulando waypoint " .. wpIdx .. " (stuck)")
            end
        end
        
        -- Teleporta se extremamente stuck
        if data.stuckCount >= cfg.STUCK_TELEPORT_THRESHOLD then
            -- Encontra posição livre perto do waypoint
            for radius = 0, 3 do
                for dx = -radius, radius do
                    for dy = -radius, radius do
                        if math.abs(dx) == radius or math.abs(dy) == radius or radius == 0 then
                            local testPos = Position(targetPos.x + dx, targetPos.y + dy, targetPos.z)
                            if canWalkTo(testPos, bot:getId()) then
                                bot:teleportTo(testPos)
                                bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
                                data.stuckCount = 0
                                data.wpIndex = math.min(wpIdx + 1, #wps)
                                logBot(data, "TELEPORT", "Destravar em waypoint " .. wpIdx)
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    
    return moved
end

local function retreatLane(bot, data)
    if not bot or not data then return false end
    
    local wps = getWaypoints(data)
    if not wps or #wps == 0 then
        -- Sem waypoints, vai para spawn
        local team = MOBA_BOTS.TEAMS[data.teamId]
        return moveTowards(bot, team.spawn, data)
    end
    
    local pos = bot:getPosition()
    local cfg = MOBA_BOTS.CONFIG
    
    -- Encontra waypoint mais próximo e recua
    local nearestIdx = findNearestWaypointIdx(data, pos)
    local targetIdx = math.max(1, nearestIdx - 1)
    
    data.wpIndex = targetIdx
    
    local targetWp = wps[targetIdx]
    local targetPos = Position(targetWp.x, targetWp.y, targetWp.z)
    
    return moveTowards(bot, targetPos, data)
end

local function moveToAttackPosition(bot, targetPos, data, class)
    if not bot or not targetPos or not data then return false end
    
    class = class or MOBA_BOTS.CLASSES[data.class]
    local pos = bot:getPosition()
    local dist = botDist(pos, targetPos)
    
    -- Já está no range
    if dist <= class.range then
        return true
    end
    
    -- Move em direção ao alvo
    return moveTowards(bot, targetPos, data)
end

local function kiteAway(bot, targetPos, data, class)
    if not bot or not targetPos or not data then return false end
    
    class = class or MOBA_BOTS.CLASSES[data.class]
    local cfg = MOBA_BOTS.CONFIG
    local pos = bot:getPosition()
    local dist = botDist(pos, targetPos)
    
    -- Se muito perto, afasta
    if dist < cfg.RANGED_OPTIMAL_DISTANCE then
        return moveAway(bot, targetPos, data)
    end
    
    return true
end

local function getPosBehindAllyWave(bot, data, env)
    if not bot or not data or not env then return nil end
    if not env.allyFrontlinePos then return nil end
    
    return getPosBehind(env.allyFrontlinePos, data.teamId, 2)
end

-- ==========================================================
-- SCAN ENVIRONMENT
-- ==========================================================

local function scanEnvironment(bot, data)
    if not bot or not data then return nil end
    
    local pos = bot:getPosition()
    local cid = bot:getId()
    local class = MOBA_BOTS.CLASSES[data.class]
    local cfg = MOBA_BOTS.CONFIG
    local vr = cfg.VISION_RANGE
    
    local env = {
        -- Posição e status
        pos = pos,
        hp = bot:getHealth() / bot:getMaxHealth(),
        maxHp = bot:getMaxHealth(),
        currentHp = bot:getHealth(),
        
        -- Contagens
        allyMinions = 0,
        allyHeroes = 0,
        enemyMinions = 0,
        enemyHeroes = 0,
        
        -- Criaturas mais próximas
        nearestEnemy = nil,
        nearestEnemyDist = 999,
        nearestEnemyPos = nil,
        nearestEnemyHero = nil,
        nearestEnemyHeroDist = 999,
        nearestEnemyHeroHp = 1,
        nearestEnemyHeroPos = nil,
        nearestEnemyMinion = nil,
        nearestEnemyMinionDist = 999,
        nearestAllyMinion = nil,
        nearestAllyMinionDist = 999,
        nearestAllyHero = nil,
        nearestAllyHeroDist = 999,
        nearestAllyHeroHp = 1,
        nearestEnemyCreature = nil,
        nearestEnemyCreatureDist = 999,
        
        -- Alvos especiais
        lowHpEnemy = nil,
        lowHpEnemyDist = 999,
        lowHpMinion = nil,
        lowHpMinionDist = 999,
        
        -- Cura de aliados (Druid)
        allyNeedingHeal = nil,
        allyNeedingHealDist = 999,
        allyNeedingHealHp = 1,
        alliesNeedingHeal = {},
        
        -- Torres
        allyTower = nil,
        allyTowerDist = 999,
        allyTowerPos = nil,
        enemyTower = nil,
        enemyTowerDist = 999,
        enemyTowerPos = nil,
        
        -- Situações de torre
        allyMinionsTankingTower = false,
        allyMinionNearTower = nil,
        underEnemyTower = false,
        nearAllyTower = false,
        enemyMinionsAtAllyTower = 0,
        nearestEnemyMinionAtTower = nil,
        nearestEnemyMinionAtTowerDist = 999,
        
        -- Zonas
        inHealZone = isInHealZone(pos, data.teamId),
        inBaseZone = isInBaseZone(pos, data.teamId),
        inShopZone = isInShopZone(pos, data.teamId),
        
        -- Combate
        targetsInRange = {},
        heroesInRange = {},
        minionsInRange = {},
        canAllIn = false,
        allInTarget = nil,
        enemyHeroInRange = nil,
        enemyHeroInRangeDist = 999,
        
        -- Assistência
        allyInCombat = nil,
        allyInCombatDist = 999,
        allyInCombatTarget = nil,
        
        -- Duelo
        isDuelSituation = false,
        duelAdvantage = false,
        
        -- Wave e lane
        hasAllyWaveNearby = false,
        allyFrontlinePos = nil,
        isBeyondLastTower = false,
        shouldWaitForWave = false,
        
        -- Team focus
        teamFocusTarget = nil,
        
        -- Estado geral
        isIdle = false,
        dangerLevel = 0,
        advantageLevel = 0,
        
        -- Listas completas
        allyHeroList = {},
        enemyHeroList = {},
        allyMinionList = {},
        enemyMinionList = {}
    }
    
    -- ===== TORRES =====
    env.allyTower, env.allyTowerDist = findNearestAllyTower(bot, data)
    if env.allyTower then
        env.allyTowerPos = env.allyTower:getPosition()
        env.nearAllyTower = env.allyTowerDist <= cfg.TOWER_RANGE + 2
    end
    
    env.enemyTower, env.enemyTowerDist = findNearestEnemyTower(bot, data)
    if env.enemyTower then
        env.enemyTowerPos = env.enemyTower:getPosition()
        env.underEnemyTower = env.enemyTowerDist <= cfg.TOWER_RANGE
    end
    
    -- ===== ALÉM DA ÚLTIMA TORRE =====
    if not env.allyTower or env.allyTowerDist > cfg.TOWER_SEARCH_RANGE then
        local wps = getWaypoints(data)
        if wps and #wps > 0 then
            local myWpIdx = findNearestWaypointIdx(data, pos)
            if myWpIdx > #wps * 0.65 then
                env.isBeyondLastTower = true
            end
        end
    end
    
    -- ===== SCAN DE CRIATURAS =====
    local specs = Game.getSpectators(pos, false, false, vr, vr, vr, vr)
    
    for _, s in ipairs(specs) do
        if s:getId() ~= cid and isValidTarget(s) and not isTower(s) and not isNexus(s) then
            if isGM(s) then goto continue end
            
            local sPos = s:getPosition()
            local d = botDist(pos, sPos)
            local hp = getCreatureHealthPercent(s)
            local team = getCreatureTeam(s)
            
            -- ===== ALIADOS =====
            if team == data.teamId then
                if isHero(s) then
                    env.allyHeroes = env.allyHeroes + 1
                    table.insert(env.allyHeroList, {creature = s, pos = sPos, dist = d, hp = hp})
                    
                    if d < env.nearestAllyHeroDist then
                        env.nearestAllyHero = s
                        env.nearestAllyHeroDist = d
                        env.nearestAllyHeroHp = hp
                    end
                    
                    -- Aliado precisando de cura
                    if hp <= cfg.HEAL_ALLY_HP_THRESHOLD then
                        table.insert(env.alliesNeedingHeal, {creature = s, pos = sPos, dist = d, hp = hp})
                        if d < env.allyNeedingHealDist then
                            env.allyNeedingHeal = s
                            env.allyNeedingHealDist = d
                            env.allyNeedingHealHp = hp
                        end
                    end
                else
                    -- Minion aliado
                    env.allyMinions = env.allyMinions + 1
                    table.insert(env.allyMinionList, {creature = s, pos = sPos, dist = d, hp = hp})
                    
                    if d < env.nearestAllyMinionDist then
                        env.nearestAllyMinion = s
                        env.nearestAllyMinionDist = d
                    end
                    
                    -- Minion tankando torre inimiga
                    if env.enemyTowerPos then
                        local minionToTower = botDist(sPos, env.enemyTowerPos)
                        if minionToTower <= cfg.TOWER_RANGE then
                            env.allyMinionsTankingTower = true
                            env.allyMinionNearTower = s
                        end
                    end
                    
                    -- Frontline aliada (minion mais avançado)
                    if not env.allyFrontlinePos then
                        env.allyFrontlinePos = sPos
                    else
                        if data.teamId == 1 then
                            if sPos.y < env.allyFrontlinePos.y then
                                env.allyFrontlinePos = sPos
                            end
                        else
                            if sPos.y > env.allyFrontlinePos.y then
                                env.allyFrontlinePos = sPos
                            end
                        end
                    end
                end
            
            -- ===== INIMIGOS =====
            elseif team ~= 0 and team ~= data.teamId then
                -- Nearest enemy creature (qualquer tipo)
                if d < env.nearestEnemyCreatureDist then
                    env.nearestEnemyCreature = s
                    env.nearestEnemyCreatureDist = d
                end
                
                if d < env.nearestEnemyDist then
                    env.nearestEnemy = s
                    env.nearestEnemyDist = d
                    env.nearestEnemyPos = sPos
                end
                
                if isHero(s) then
                    env.enemyHeroes = env.enemyHeroes + 1
                    table.insert(env.enemyHeroList, {creature = s, pos = sPos, dist = d, hp = hp})
                    
                    if d < env.nearestEnemyHeroDist then
                        env.nearestEnemyHero = s
                        env.nearestEnemyHeroDist = d
                        env.nearestEnemyHeroHp = hp
                        env.nearestEnemyHeroPos = sPos
                    end
                    
                    -- Em range de ataque
                    if d <= class.range then
                        table.insert(env.targetsInRange, {
                            creature = s, dist = d, hp = hp,
                            isHero = true, isMinion = false, isTower = false,
                            pos = sPos
                        })
                        table.insert(env.heroesInRange, {creature = s, dist = d, hp = hp, pos = sPos})
                        
                        if d < env.enemyHeroInRangeDist then
                            env.enemyHeroInRange = s
                            env.enemyHeroInRangeDist = d
                        end
                    end
                    
                    -- Alvo com HP baixo para chase
                    if hp < cfg.CHASE_HP_THRESHOLD and d <= cfg.CHASE_MAX_DISTANCE then
                        local safeToChase = not isPositionNearEnemyTower(sPos, data, env, 1) or env.allyMinionsTankingTower
                        if safeToChase then
                            if not env.lowHpEnemy or hp < getCreatureHealthPercent(env.lowHpEnemy) then
                                env.lowHpEnemy = s
                                env.lowHpEnemyDist = d
                            end
                        end
                    end
                else
                    -- Minion inimigo
                    env.enemyMinions = env.enemyMinions + 1
                    table.insert(env.enemyMinionList, {creature = s, pos = sPos, dist = d, hp = hp})
                    
                    if d < env.nearestEnemyMinionDist then
                        env.nearestEnemyMinion = s
                        env.nearestEnemyMinionDist = d
                    end
                    
                    -- Minion com low HP para last hit
                    if hp <= cfg.LAST_HIT_HP_THRESHOLD and d <= class.range + 2 then
                        if not env.lowHpMinion or d < env.lowHpMinionDist then
                            env.lowHpMinion = s
                            env.lowHpMinionDist = d
                        end
                    end
                    
                    -- Em range de ataque
                    if d <= class.range then
                        table.insert(env.targetsInRange, {
                            creature = s, dist = d, hp = hp,
                            isHero = false, isMinion = true, isTower = false,
                            pos = sPos
                        })
                        table.insert(env.minionsInRange, {creature = s, dist = d, hp = hp, pos = sPos})
                    end
                    
                    -- Minion na torre aliada
                    if env.allyTowerPos and botDist(sPos, env.allyTowerPos) <= cfg.TOWER_RANGE + 1 then
                        env.enemyMinionsAtAllyTower = env.enemyMinionsAtAllyTower + 1
                        if d < env.nearestEnemyMinionAtTowerDist then
                            env.nearestEnemyMinionAtTower = s
                            env.nearestEnemyMinionAtTowerDist = d
                        end
                    end
                end
            end
            
            ::continue::
        end
    end
    
    -- ===== PÓS-PROCESSAMENTO =====
    
    -- Wave aliada próxima
    env.hasAllyWaveNearby = env.allyMinions > 0 and env.nearestAllyMinionDist <= cfg.SAFE_LANE_DISTANCE
    
    -- Torre inimiga como alvo (se minions tankando)
    if env.enemyTower and env.allyMinionsTankingTower and env.enemyTowerDist <= class.range then
        table.insert(env.targetsInRange, {
            creature = env.enemyTower,
            dist = env.enemyTowerDist,
            hp = getCreatureHealthPercent(env.enemyTower),
            isHero = false, isMinion = false, isTower = true,
            pos = env.enemyTowerPos
        })
    end
    
    -- Atualiza tempo de último inimigo visto
    if env.enemyMinions > 0 or env.enemyHeroes > 0 then
        data.lastEnemySeenTime = os.time()
    end
    
    -- ===== TEAM FOCUS =====
    for _, ally in ipairs(env.allyHeroList) do
        if ally.dist <= cfg.TEAM_FOCUS_RANGE then
            local allyData = MOBA_BOTS.Data[ally.creature:getId()]
            if allyData and allyData.lastAttackTarget then
                local attackTarget = Creature(allyData.lastAttackTarget)
                if attackTarget and isValidTarget(attackTarget) and isEnemyTeam(attackTarget, data) and isHero(attackTarget) then
                    env.teamFocusTarget = attackTarget
                    break
                end
            end
        end
    end
    
    -- ===== ALIADO EM COMBATE (ASSIST) =====
    for _, ally in ipairs(env.allyHeroList) do
        if ally.dist <= cfg.ASSIST_RANGE then
            local allyData = MOBA_BOTS.Data[ally.creature:getId()]
            local fighting = allyData and (
                allyData.state == MOBA_BOTS.STATE.FIGHTING or
                allyData.state == MOBA_BOTS.STATE.ALL_IN or
                allyData.state == MOBA_BOTS.STATE.KITING_FIGHT or
                isUnderAttack(allyData)
            )
            
            for _, enemy in ipairs(env.enemyHeroList) do
                local allyToEnemy = botDist(ally.pos, enemy.pos)
                if allyToEnemy <= cfg.ASSIST_ENGAGE_RANGE then
                    if fighting or (ally.hp < 0.75 and allyToEnemy <= 4) then
                        if ally.dist < env.allyInCombatDist then
                            env.allyInCombat = ally.creature
                            env.allyInCombatDist = ally.dist
                            env.allyInCombatTarget = enemy.creature
                        end
                    end
                end
            end
        end
    end
    
    -- ===== DUELO 1v1 =====
    if env.enemyHeroes == 1 and env.allyHeroes == 0 and env.nearestEnemyHero then
        if env.nearestEnemyHeroDist <= cfg.ENGAGE_RANGE then
            env.isDuelSituation = true
            env.duelAdvantage = env.hp > (env.nearestEnemyHeroHp + cfg.DUEL_HP_ADVANTAGE)
        end
    end
    
    -- ===== CONDIÇÃO DE ALL-IN =====
    if env.nearestEnemyHero and
       env.hp <= cfg.ALL_IN_MY_HP_MAX and
       env.nearestEnemyHeroHp <= cfg.ALL_IN_ENEMY_HP_THRESHOLD and
       not env.underEnemyTower and
       env.nearestEnemyHeroDist <= cfg.CHASE_MAX_DISTANCE and
       env.enemyHeroes == 1 then
        env.canAllIn = true
        env.allInTarget = env.nearestEnemyHero
    end
    
    -- ===== DEVE ESPERAR WAVE =====
    if env.isBeyondLastTower and not env.hasAllyWaveNearby then
        if env.enemyMinions > 0 or env.enemyHeroes > 0 then
            env.shouldWaitForWave = true
        end
    end
    
    if env.enemyTowerPos and env.enemyTowerDist <= cfg.TOWER_SAFE_DISTANCE then
        if not env.allyMinionsTankingTower then
            env.shouldWaitForWave = true
        end
    end
    
    -- ===== CÁLCULO DE PERIGO =====
    env.dangerLevel = 0
    if env.underEnemyTower and not env.allyMinionsTankingTower then
        env.dangerLevel = env.dangerLevel + 50
    end
    if isUnderTowerAttack(data) then
        env.dangerLevel = env.dangerLevel + 30
    end
    if env.enemyHeroes > env.allyHeroes + 1 then
        env.dangerLevel = env.dangerLevel + 20
    end
    if env.hp < cfg.HP_LOW then
        env.dangerLevel = env.dangerLevel + 25
    end
    if isUnderAttack(data) and env.allyMinions == 0 then
        env.dangerLevel = env.dangerLevel + 15
    end
    
    -- ===== CÁLCULO DE VANTAGEM =====
    env.advantageLevel = 0
    if env.allyHeroes > env.enemyHeroes then
        env.advantageLevel = env.advantageLevel + 20
    end
    if env.allyMinions > env.enemyMinions then
        env.advantageLevel = env.advantageLevel + 10
    end
    if env.hp > cfg.HP_HEALTHY then
        env.advantageLevel = env.advantageLevel + 15
    end
    if env.nearAllyTower then
        env.advantageLevel = env.advantageLevel + 10
    end
    if env.allyMinionsTankingTower then
        env.advantageLevel = env.advantageLevel + 25
    end
    
    -- ===== IDLE =====
    if env.nearestEnemyDist > vr and env.enemyMinions == 0 and env.enemyHeroes == 0 and
       not env.inBaseZone and not isUnderAttack(data) then
        env.isIdle = true
    end
    
    -- Ordena aliados que precisam de cura por HP (mais baixo primeiro)
    table.sort(env.alliesNeedingHeal, function(a, b) return a.hp < b.hp end)
    
    return env
end

-- ==========================================================
-- SELEÇÃO DE ALVO
-- ==========================================================

local function selectTarget(env, data, prioritizeTower)
    if not env or not data then return nil end
    if #env.targetsInRange == 0 then return nil end
    
    local cfg = MOBA_BOTS.CONFIG
    
    -- Prioriza torre se solicitado
    if prioritizeTower then
        for _, t in ipairs(env.targetsInRange) do
            if t.isTower then return t.creature end
        end
    end
    
    -- Se aliado está focando um herói, foca junto
    if env.teamFocusTarget and isValidTarget(env.teamFocusTarget) then
        local class = MOBA_BOTS.CLASSES[data.class]
        if botDist(env.pos, env.teamFocusTarget:getPosition()) <= class.range then
            return env.teamFocusTarget
        end
    end
    
    -- Sistema de pontuação
    local best, bestScore = nil, -9999
    
    for _, t in ipairs(env.targetsInRange) do
        local score = 0
        
        if t.isTower then
            score = cfg.TOWER_ATTACK_PRIORITY
        elseif t.isHero then
            score = cfg.PRIORITY_HERO_BONUS
            
            -- Bônus por HP baixo
            if t.hp < 0.20 then
                score = score + 150
            elseif t.hp < 0.35 then
                score = score + cfg.PRIORITY_LOW_HP_BONUS
            elseif t.hp < 0.50 then
                score = score + 50
            end
            
            -- Bônus se é o foco do time
            if env.teamFocusTarget and t.creature:getId() == env.teamFocusTarget:getId() then
                score = score + 100
            end
        else
            -- Minion
            score = 30
            
            -- Bônus para last hit
            if t.hp < cfg.LAST_HIT_HP_THRESHOLD then
                score = score + 120
            elseif t.hp < 0.50 then
                score = score + 40
            end
        end
        
        -- Penalidade por distância
        score = score - (t.dist * cfg.PRIORITY_DISTANCE_PENALTY)
        
        if score > bestScore then
            bestScore = score
            best = t.creature
        end
    end
    
    return best
end

local function selectBestTarget(env, data)
    return selectTarget(env, data, false)
end

local function selectTowerTarget(env, data)
    return selectTarget(env, data, true)
end

-- ==========================================================
-- SISTEMA DE ATAQUE
-- ==========================================================

local function doAttack(bot, target, data)
    if not bot or not target or not data then return false end
    if not canAttackTarget(target, data) then return false end
    
    local class = MOBA_BOTS.CLASSES[data.class]
    local pos = bot:getPosition()
    local targetPos = target:getPosition()
    local dist = botDist(pos, targetPos)
    
    if dist > class.range then return false end
    
    -- Cancela recall se estava recalling
    if data.state == MOBA_BOTS.STATE.RECALLING then
        cancelRecall(data, "attacking")
        setState(data, MOBA_BOTS.STATE.FIGHTING)
    end
    
    -- Vira para o alvo
    local dir = getDirectionTo(pos, targetPos)
    bot:setDirection(dir)
    
    -- Calcula dano
    local baseDmg = class.atk + (data.level * class.atkGain)
    local bonusDmg = (data.bonusAtk or 0)
    local totalDmg = baseDmg + bonusDmg + math.random(-3, 3)
    
    -- Efeito visual de ataque
    if class.ranged and class.distEffect ~= CONST_ANI_NONE then
        pos:sendDistanceEffect(targetPos, class.distEffect)
    end
    
    -- Verifica se vai matar
    local currentHp = target:getHealth()
    local kill = currentHp <= totalDmg
    
    -- Registra dano
    local targetId = target:getId()
    if MOBA_BOTS.Data[targetId] or target:isPlayer() then
        MOBA_BOTS.registerDamage(targetId, "basic", totalDmg, data.myId)
    end
    
    -- Aplica dano
    target:addHealth(-totalDmg)
    
    -- Efeito visual de hit
    if kill then
        targetPos:sendMagicEffect(CONST_ME_DEATH)
    else
        targetPos:sendMagicEffect(class.hitEffect or CONST_ME_DRAWBLOOD)
    end
    
    -- Atualiza estado
    data.lastAtk = os.clock()
    data.lastAttackTarget = targetId
    data.totalDamageDealt = (data.totalDamageDealt or 0) + totalDmg
    
    -- ===== RECOMPENSAS POR KILL =====
    if kill then
        local isHeroKill = isHero(target)
        local isTowerKill = isTower(target)
        local isNexusKill = isNexus(target)
        local cfg = MOBA_BOTS.CONFIG
        
        local gold = 0
        local exp = 0
        
        if isNexusKill then
            gold = 500
            exp = 1000
            MOBA_BOTS.addScore(data.teamId, "nexusDestroyed", 1)
        elseif isTowerKill then
            gold = cfg.TOWER_KILL_GOLD
            exp = cfg.TOWER_KILL_EXP
            MOBA_BOTS.addScore(data.teamId, "towersDestroyed", 1)
        elseif isHeroKill then
            gold = cfg.HERO_KILL_GOLD
            exp = cfg.HERO_KILL_EXP
            MOBA_BOTS.registerStat(data.myId, "kill")
            MOBA_BOTS.registerStat(targetId, "death")
            MOBA_BOTS.addScore(data.teamId, "kills", 1)
            
            -- Processa assists
            local assists = MOBA_BOTS.getAssists(targetId, data.myId)
            for _, assist in ipairs(assists) do
                local assistData = MOBA_BOTS.Data[assist.id]
                if assistData then
                    assistData.gold = (assistData.gold or 0) + math.floor(gold * cfg.ASSIST_GOLD_PERCENT)
                    assistData.exp = (assistData.exp or 0) + math.floor(exp * cfg.ASSIST_EXP_PERCENT)
                    assistData.assists = (assistData.assists or 0) + 1
                end
                MOBA_BOTS.registerStat(assist.id, "assist")
            end
            MOBA_BOTS.addScore(data.teamId, "assists", #assists)
            
            MOBA_BOTS.clearDamageTracker(targetId)
        else
            gold = cfg.MINION_GOLD
            exp = cfg.MINION_EXP
            MOBA_BOTS.addScore(data.teamId, "minionsKilled", 1)
        end
        
        data.gold = (data.gold or 0) + gold
        data.exp = (data.exp or 0) + exp
        MOBA_BOTS.addScore(data.teamId, "totalGold", gold)
        MOBA_BOTS.addScore(data.teamId, "totalExp", exp)
        
        -- ===== LEVEL UP =====
        local nextExp = MOBA_BOTS.EXP_TABLE[data.level + 1] or 999999
        while data.exp >= nextExp and data.level < 25 do
            data.level = data.level + 1
            nextExp = MOBA_BOTS.EXP_TABLE[data.level + 1] or 999999
            
            local newMax = class.hp + data.level * class.hpGain + (data.bonusHp or 0)
            bot:setMaxHealth(newMax)
            bot:addHealth(bot:getMaxHealth())
            
            bot:say("LEVEL UP! (" .. data.level .. ")", TALKTYPE_MONSTER_YELL)
            bot:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
            
            logBot(data, "LEVEL UP", "Nível " .. data.level)
        end
    end
    
    return true
end

-- ==========================================================
-- SISTEMA DE SPELLS
-- ==========================================================

local function canCastSpell(data, spell)
    if not data or not spell then return false end
    
    local now = os.clock()
    
    -- Verifica cooldown
    if data.spellCooldowns and data.spellCooldowns[spell.name] then
        if now - data.spellCooldowns[spell.name] < spell.cd then
            return false
        end
    end
    
    -- Verifica level
    if data.level < spell.level then
        return false
    end
    
    -- Verifica cooldown global
    if data.lastSpellCast then
        if now - data.lastSpellCast < MOBA_BOTS.CONFIG.SPELL_CD_GLOBAL then
            return false
        end
    end
    
    return true
end

local function getSpellAreaPositions(casterPos, spell, direction)
    local positions = {}
    
    if spell.type == "absolute" then
        local pattern = MOBA_BOTS.SPELL_PATTERNS[spell.pattern]
        if not pattern then
            -- Padrão: área ao redor
            local radius = spell.radius or 3
            for dx = -radius, radius do
                for dy = -radius, radius do
                    if dx ~= 0 or dy ~= 0 then
                        table.insert(positions, Position(casterPos.x + dx, casterPos.y + dy, casterPos.z))
                    end
                end
            end
        elseif pattern.type == "static" then
            for _, offset in ipairs(pattern.positions) do
                table.insert(positions, Position(casterPos.x + offset.x, casterPos.y + offset.y, casterPos.z))
            end
        elseif pattern.type == "radius" then
            local radius = pattern.radius
            for dx = -radius, radius do
                for dy = -radius, radius do
                    local dist = math.sqrt(dx*dx + dy*dy)
                    if dist <= radius and (dx ~= 0 or dy ~= 0) then
                        table.insert(positions, Position(casterPos.x + dx, casterPos.y + dy, casterPos.z))
                    end
                end
            end
        end
    elseif spell.type == "wave" then
        local length = spell.length or 5
        local width = spell.width or 1
        local halfWidth = math.floor(width / 2)
        
        for i = 1, length do
            for w = -halfWidth, halfWidth do
                local pos
                if direction == DIRECTION_NORTH then
                    pos = Position(casterPos.x + w, casterPos.y - i, casterPos.z)
                elseif direction == DIRECTION_SOUTH then
                    pos = Position(casterPos.x + w, casterPos.y + i, casterPos.z)
                elseif direction == DIRECTION_EAST then
                    pos = Position(casterPos.x + i, casterPos.y + w, casterPos.z)
                elseif direction == DIRECTION_WEST then
                    pos = Position(casterPos.x - i, casterPos.y + w, casterPos.z)
                end
                if pos then
                    table.insert(positions, pos)
                end
            end
        end
    end
    
    return positions
end

local function countEnemiesInArea(positions, data)
    local count = 0
    local enemies = {}
    
    for _, pos in ipairs(positions) do
        local tile = Tile(pos)
        if tile then
            local creatures = tile:getCreatures()
            for _, c in ipairs(creatures or {}) do
                if isValidTarget(c) and isEnemyTeam(c, data) then
                    local cid = c:getId()
                    if not enemies[cid] then
                        enemies[cid] = c
                        count = count + 1
                    end
                end
            end
        end
    end
    
    return count, enemies
end

local function findBestDirectionForWave(bot, data, spell, target)
    if not spell.direction then
        return bot:getDirection()
    end
    
    if target then
        return getDirectionTo(bot:getPosition(), target:getPosition())
    end
    
    -- Testa todas as direções
    local bestDir = bot:getDirection()
    local bestCount = 0
    
    for _, dir in ipairs(ALL_DIRECTIONS) do
        local positions = getSpellAreaPositions(bot:getPosition(), spell, dir)
        local count = countEnemiesInArea(positions, data)
        if count > bestCount then
            bestCount = count
            bestDir = dir
        end
    end
    
    return bestDir
end

local function castSpell(bot, data, spell, target, direction)
    if not bot or not data or not spell then return false end
    
    local pos = bot:getPosition()
    local class = MOBA_BOTS.CLASSES[data.class]
    local now = os.clock()
    
    -- Vira para o alvo/direção
    if target then
        local targetPos = target:getPosition()
        direction = getDirectionTo(pos, targetPos)
        bot:setDirection(direction)
    elseif direction then
        bot:setDirection(direction)
    end
    
    -- Calcula dano/cura base
    local effectValue = 0
    if spell.damage then
        effectValue = math.random(spell.damage.min, spell.damage.max) + (data.level * 2) + (data.bonusAtk or 0)
    elseif spell.heal then
        effectValue = math.random(spell.heal.min, spell.heal.max) + (data.level * 3)
    end
    
    local success = false
    
    -- ===== SPELL TARGETED =====
    if spell.type == "targeted" then
        if not target then return false end
        local targetPos = target:getPosition()
        local dist = botDist(pos, targetPos)
        if dist > (spell.range or class.range) then return false end
        
        -- Efeito de distância
        if spell.distEffect then
            pos:sendDistanceEffect(targetPos, spell.distEffect)
        elseif class.distEffect and class.distEffect ~= CONST_ANI_NONE then
            pos:sendDistanceEffect(targetPos, class.distEffect)
        end
        
        -- Efeito no alvo
        if spell.effect then
            targetPos:sendMagicEffect(spell.effect)
        end
        
        -- Aplica dano
        if spell.damage then
            MOBA_BOTS.registerDamage(target:getId(), "spell", effectValue, data.myId)
            target:addHealth(-effectValue)
        end
        
        logSpell(data, spell.name, getCreatureName(target))
        success = true
    
    -- ===== SPELL ABSOLUTE (área centrada no caster) =====
    elseif spell.type == "absolute" then
        local areaPositions = getSpellAreaPositions(pos, spell, direction or bot:getDirection())
        
        -- Efeito visual na área
        for _, areaPos in ipairs(areaPositions) do
            if spell.effect then
                areaPos:sendMagicEffect(spell.effect)
            end
        end
        
        -- Também mostra efeito na posição do caster
        if spell.effect then
            pos:sendMagicEffect(spell.effect)
        end
        
        -- Aplica dano em todos na área
        local hitCount = 0
        local hitEnemies = {}
        for _, areaPos in ipairs(areaPositions) do
            local tile = Tile(areaPos)
            if tile then
                local creatures = tile:getCreatures()
                for _, c in ipairs(creatures or {}) do
                    local cid = c:getId()
                    if isValidTarget(c) and isEnemyTeam(c, data) and not hitEnemies[cid] then
                        hitEnemies[cid] = true
                        hitCount = hitCount + 1
                        MOBA_BOTS.registerDamage(cid, "spell", effectValue, data.myId)
                        c:addHealth(-effectValue)
                        c:getPosition():sendMagicEffect(CONST_ME_HITBYFIRE)
                    end
                end
            end
        end
        
        logSpell(data, spell.name, string.format("(%d alvos)", hitCount))
        success = true
    
    -- ===== SPELL WAVE (direcional) =====
    elseif spell.type == "wave" then
        local waveDir = direction or findBestDirectionForWave(bot, data, spell, target)
        bot:setDirection(waveDir)
        
        local areaPositions = getSpellAreaPositions(pos, spell, waveDir)
        
        -- Efeito visual na área
        for _, areaPos in ipairs(areaPositions) do
            if spell.effect then
                areaPos:sendMagicEffect(spell.effect)
            end
        end
        
        -- Aplica dano
        local hitCount = 0
        local hitEnemies = {}
        for _, areaPos in ipairs(areaPositions) do
            local tile = Tile(areaPos)
            if tile then
                local creatures = tile:getCreatures()
                for _, c in ipairs(creatures or {}) do
                    local cid = c:getId()
                    if isValidTarget(c) and isEnemyTeam(c, data) and not hitEnemies[cid] then
                        hitEnemies[cid] = true
                        hitCount = hitCount + 1
                        MOBA_BOTS.registerDamage(cid, "spell", effectValue, data.myId)
                        c:addHealth(-effectValue)
                    end
                end
            end
        end
        
        logSpell(data, spell.name, string.format("(%d alvos)", hitCount))
        success = true
    
    -- ===== SPELL HEAL SELF =====
    elseif spell.type == "heal_self" then
        bot:addHealth(effectValue)
        pos:sendMagicEffect(spell.effect or CONST_ME_MAGIC_BLUE)
        logSpell(data, spell.name, string.format("(+%d HP)", effectValue))
        success = true
    
    -- ===== SPELL HEAL ALLY =====
    elseif spell.type == "heal_ally" then
        if not target then return false end
        if not isAllyTeam(target, data) then return false end
        
        local targetPos = target:getPosition()
        local dist = botDist(pos, targetPos)
        if dist > (spell.range or 7) then return false end
        
        target:addHealth(effectValue)
        targetPos:sendMagicEffect(spell.effect or CONST_ME_MAGIC_BLUE)
        
        -- Fala a magia com o nome do alvo
        local targetName = getCreatureName(target)
        bot:say(spell.words .. ' "' .. targetName .. '"', TALKTYPE_MONSTER_SAY)
        
        logSpell(data, spell.name, string.format("%s (+%d HP)", targetName, effectValue))
        success = true
    
    -- ===== SPELL HEAL AREA =====
    elseif spell.type == "heal_area" then
        local radius = spell.radius or 3
        local healedCount = 0
        
        pos:sendMagicEffect(spell.effect or CONST_ME_MAGIC_BLUE)
        
        local specs = Game.getSpectators(pos, false, false, radius, radius, radius, radius)
        for _, s in ipairs(specs) do
            if isValidTarget(s) and isAllyTeam(s, data) then
                s:addHealth(effectValue)
                s:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
                healedCount = healedCount + 1
            end
        end
        
        logSpell(data, spell.name, string.format("(%d aliados)", healedCount))
        success = true
    
    -- ===== SPELL BUFF =====
    elseif spell.type == "buff" then
        if spell.bonuses then
            for stat, value in pairs(spell.bonuses) do
                data[stat] = (data[stat] or 0) + value
            end
            
            pos:sendMagicEffect(spell.effect or CONST_ME_MAGIC_GREEN)
            
            -- Remove buff após duração
            if spell.duration then
                addEvent(function(botId, bonuses)
                    local bd = MOBA_BOTS.Data[botId]
                    if bd then
                        for stat, value in pairs(bonuses) do
                            bd[stat] = (bd[stat] or 0) - value
                        end
                    end
                end, spell.duration * 1000, data.myId, spell.bonuses)
            end
        end
        
        logSpell(data, spell.name)
        success = true
    
    -- ===== SPELL DEBUFF =====
    elseif spell.type == "debuff" then
        if not target then return false end
        
        local targetPos = target:getPosition()
        local dist = botDist(pos, targetPos)
        if dist > (spell.range or 4) then return false end
        
        if spell.effect then
            targetPos:sendMagicEffect(spell.effect)
        end
        
        -- Aplica debuff (simplificado - apenas visual)
        logSpell(data, spell.name, getCreatureName(target))
        success = true
    end
    
    if success then
        -- Registra cooldown
        data.spellCooldowns = data.spellCooldowns or {}
        data.spellCooldowns[spell.name] = now
        data.lastSpellCast = now
        
        -- Fala o spell (exceto heal ally que já falou)
        if spell.type ~= "heal_ally" then
            bot:say(spell.words, TALKTYPE_MONSTER_SAY)
        end
    end
    
    return success
end

local function tryUseSpells(bot, data, env, target)
    if not bot or not data or not env then return false end
    
    local class = MOBA_BOTS.CLASSES[data.class]
    if not class or not class.spells then return false end
    
    local pos = bot:getPosition()
    local cfg = MOBA_BOTS.CONFIG
    
    -- ===== DRUID: PRIORIZA CURA DE ALIADOS =====
    if data.class == "druid" then
        -- Ordena spells de cura por prioridade
        for _, spell in ipairs(class.spells) do
            if spell.type == "heal_ally" and canCastSpell(data, spell) then
                -- Procura aliado com HP mais baixo
                for _, ally in ipairs(env.alliesNeedingHeal) do
                    if ally.dist <= (spell.range or 7) then
                        if castSpell(bot, data, spell, ally.creature, nil) then
                            return true
                        end
                    end
                end
            end
        end
        
        -- Auto-heal
        if env.hp < cfg.HEAL_SELF_HP_THRESHOLD then
            for _, spell in ipairs(class.spells) do
                if spell.type == "heal_self" and canCastSpell(data, spell) then
                    if castSpell(bot, data, spell, nil, nil) then
                        return true
                    end
                end
            end
        end
        
        -- Heal em área se muitos aliados precisam
        if #env.alliesNeedingHeal >= 2 then
            for _, spell in ipairs(class.spells) do
                if spell.type == "heal_area" and canCastSpell(data, spell) then
                    if castSpell(bot, data, spell, nil, nil) then
                        return true
                    end
                end
            end
        end
    end
    
    -- ===== SPELLS OFENSIVOS =====
    if target and canAttackTarget(target, data) then
        local targetPos = target:getPosition()
        local dist = botDist(pos, targetPos)
        
        -- Ordena spells por prioridade (maior dano primeiro)
        local offensiveSpells = {}
        for _, spell in ipairs(class.spells) do
            if spell.damage and spell.type ~= "heal_self" and spell.type ~= "heal_ally" and spell.type ~= "heal_area" and spell.type ~= "buff" then
                table.insert(offensiveSpells, spell)
            end
        end
        table.sort(offensiveSpells, function(a, b)
            return (a.damage.max or 0) > (b.damage.max or 0)
        end)
        
        for _, spell in ipairs(offensiveSpells) do
            if canCastSpell(data, spell) then
                if spell.type == "targeted" then
                    if dist <= (spell.range or class.range) then
                        if castSpell(bot, data, spell, target, nil) then
                            return true
                        end
                    end
                elseif spell.type == "absolute" then
                    -- CORREÇÃO: Para pattern "adjacent" (exori), precisa estar colado
                    local effectiveRadius = spell.radius or 3
                    if spell.pattern == "adjacent" then
                        effectiveRadius = 1
                    end
                    
                    if dist <= effectiveRadius then
                        if castSpell(bot, data, spell, nil, nil) then
                            return true
                        end
                    end
                elseif spell.type == "wave" then
                    local dir = getDirectionTo(pos, targetPos)
                    local areaPositions = getSpellAreaPositions(pos, spell, dir)
                    
                    -- Verifica se alvo está na área
                    local targetInArea = false
                    for _, areaPos in ipairs(areaPositions) do
                        if posEqual(areaPos, targetPos) or botDist(areaPos, targetPos) <= 1 then
                            targetInArea = true
                            break
                        end
                    end
                    
                    if targetInArea or dist <= 3 then
                        if castSpell(bot, data, spell, nil, dir) then
                            return true
                        end
                    end
                end
            end
        end
    end
    
    -- ===== BUFF QUANDO EM COMBATE =====
    if env.enemyHeroInRange or env.nearestEnemyHeroDist <= cfg.ENGAGE_RANGE then
        for _, spell in ipairs(class.spells) do
            if spell.type == "buff" and canCastSpell(data, spell) then
                if castSpell(bot, data, spell, nil, nil) then
                    return true
                end
            end
        end
    end
    
    return false
end

-- ==========================================================
-- SISTEMA DE POÇÕES E SUPRIMENTOS
-- ==========================================================

local function tryUsePotion(bot, data, env)
    if not bot or not data or not env then return false end
    
    local cfg = MOBA_BOTS.CONFIG
    local now = os.clock()
    
    -- Verifica cooldown
    if data.lastPotionUse and now - data.lastPotionUse < cfg.POTION_CD then
        return false
    end
    
    -- HP Potion
    if env.hp < cfg.USE_HP_POT_THRESHOLD then
        local hpPots = data.hpPots or 0
        if hpPots > 0 then
            data.hpPots = hpPots - 1
            data.lastPotionUse = now
            
            local heal = 150 + data.level * 12
            bot:addHealth(heal)
            bot:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
            bot:say("*gulp*", TALKTYPE_MONSTER_SAY)
            
            logUseItem(data, "Health Potion", string.format("HP %.0f%% -> +%d", env.hp * 100, heal))
            return true
        end
    end
    
    return false
end

local function tryUseSupplies(bot, data, env)
    return tryUsePotion(bot, data, env)
end

-- ==========================================================
-- SISTEMA DE COMPRAS
-- ==========================================================

local function getShopItems(data, category)
    local shopItems = MOBA_BOTS.SHOP_ITEMS[data.class]
    if not shopItems then return {} end
    return shopItems[category] or {}
end

local function findBestItemToBuy(data, category)
    local items = getShopItems(data, category)
    if #items == 0 then return nil end
    
    local gold = data.gold or 0
    local level = data.level or 1
    local best = nil
    
    -- Encontra o melhor item que pode comprar
    for i = #items, 1, -1 do
        local item = items[i]
        if item.price <= gold and item.level <= level then
            -- Verifica se é upgrade significativo
            local currentBonus = 0
            if item.bonusAtk then currentBonus = currentBonus + (data.bonusAtk or 0) end
            if item.bonusHp then currentBonus = currentBonus + (data.bonusHp or 0) / 10 end
            
            local itemBonus = (item.bonusAtk or 0) + (item.bonusHp or 0) / 10
            
            if itemBonus > currentBonus * 0.3 or not best then
                best = item
                break
            end
        end
    end
    
    return best
end

local function buyPotions(data, potionType, count)
    local items = getShopItems(data, "potions")
    if #items == 0 then return false end
    
    local gold = data.gold or 0
    local level = data.level or 1
    local cfg = MOBA_BOTS.CONFIG
    
    -- Encontra melhor poção disponível
    for i = #items, 1, -1 do
        local item = items[i]
        if item.type == potionType and item.price <= gold and item.level <= level then
            local currentPots = potionType == "hp" and (data.hpPots or 0) or (data.manaPots or 0)
            if currentPots >= cfg.MAX_POTS_CARRY then return false end
            
            local buyCount = math.min(count, math.floor(gold / item.price))
            buyCount = math.min(buyCount, cfg.MAX_POTS_CARRY - currentPots)
            
            if buyCount > 0 then
                local totalCost = item.price * buyCount
                data.gold = gold - totalCost
                
                if potionType == "hp" then
                    data.hpPots = (data.hpPots or 0) + buyCount
                else
                    data.manaPots = (data.manaPots or 0) + buyCount
                end
                
                logPurchase(data, item.name .. " x" .. buyCount, totalCost, "potion")
                return true
            end
        end
    end
    
    return false
end

local function tryBuyItems(bot, data)
    if not data.inBase then return end
    
    local gold = data.gold or 0
    local cfg = MOBA_BOTS.CONFIG
    local class = MOBA_BOTS.CLASSES[data.class]
    
    -- Primeiro: garante poções
    local potType = class.potionType or "health"
    local currentPots = potType == "health" and (data.hpPots or 0) or (data.manaPots or 0)
    
    if currentPots < cfg.MIN_POTS_TO_BUY then
        buyPotions(data, potType == "health" and "hp" or "mana", cfg.MIN_POTS_TO_BUY)
    end
    
    -- Atualiza gold após compra de poções
    gold = data.gold or 0
    
    -- Reserva gold para poções
    local availableGold = gold - cfg.GOLD_RESERVE_FOR_POTS
    if availableGold <= 0 then return end
    
    -- Compra equipamentos seguindo prioridade da classe
    for _, category in ipairs(class.buyPriority or {}) do
        if category ~= "potion" then
            local item = findBestItemToBuy(data, category)
            if item and item.price <= availableGold then
                data.gold = (data.gold or 0) - item.price
                
                -- Aplica bônus
                if item.bonusAtk then
                    data.bonusAtk = (data.bonusAtk or 0) + item.bonusAtk
                end
                if item.bonusHp then
                    data.bonusHp = (data.bonusHp or 0) + item.bonusHp
                    local newMax = class.hp + data.level * class.hpGain + data.bonusHp
                    bot:setMaxHealth(newMax)
                    bot:addHealth(item.bonusHp)
                end
                if item.bonusSpeed then
                    data.bonusSpeed = (data.bonusSpeed or 0) + item.bonusSpeed
                    bot:changeSpeed(item.bonusSpeed)
                end
                if item.bonusDef then
                    data.bonusDef = (data.bonusDef or 0) + item.bonusDef
                end
                
                logPurchase(data, item.name, item.price, category)
                logEquip(data, item.name)
                
                availableGold = availableGold - item.price
            end
        end
    end
end

-- ==========================================================
-- FUNÇÕES DE EMERGÊNCIA E DETECÇÃO DE PROBLEMAS
-- ==========================================================

local function isLostFromLane(bot, data)
    if not data.assignedLane then return false end
    
    local pos = bot:getPosition()
    local wps = getWaypoints(data)
    if not wps or #wps == 0 then return false end
    
    local nearestDist = 999
    for _, wp in ipairs(wps) do
        local d = botDist(pos, wp)
        if d < nearestDist then
            nearestDist = d
        end
    end
    
    return nearestDist > 20
end

local function isStuckBeyondEnemyTower(data, env)
    if not env then return false end
    
    if (data.stuckCount or 0) >= 12 then
        return true
    end
    
    if env.isBeyondLastTower and not env.hasAllyWaveNearby and env.nearestEnemyDist <= 10 then
        return true
    end
    
    return false
end

local function emergencyEscapeFromTower(bot, data, env)
    local pos = bot:getPosition()
    local escapePos
    
    if env.enemyTowerPos then
        local dx = pos.x - env.enemyTowerPos.x
        local dy = pos.y - env.enemyTowerPos.y
        local len = math.sqrt(dx*dx + dy*dy)
        if len < 1 then len = 1 end
        
        local escapeDistance = MOBA_BOTS.CONFIG.TOWER_SAFE_DISTANCE + 5
        escapePos = Position(
            math.floor(pos.x + (dx/len) * escapeDistance + 0.5),
            math.floor(pos.y + (dy/len) * escapeDistance + 0.5),
            pos.z
        )
    else
        escapePos = MOBA_BOTS.TEAMS[data.teamId].spawn
    end
    
    local moved = moveTowards(bot, escapePos, data)
    
    if not moved and env.enemyTowerPos then
        moved = moveAway(bot, env.enemyTowerPos, data)
    end
    
    if not moved then
        for _, dir in ipairs(ALL_DIRECTIONS) do
            if tryMoveDirection(bot, dir, data) then
                moved = true
                break
            end
        end
    end
    
    return moved
end

-- ==========================================================
-- FUNÇÕES DE DECISÃO
-- ==========================================================

local function getBestRetreatPosition(data, env)
    if not data or not env then return nil end
    
    -- Prioridade 1: Atrás da torre aliada
    if env.allyTowerPos then
        return getPosBehind(env.allyTowerPos, data.teamId, 3)
    end
    
    -- Prioridade 2: Atrás da wave aliada
    if env.allyFrontlinePos then
        return getPosBehind(env.allyFrontlinePos, data.teamId, 3)
    end
    
    -- Prioridade 3: Waypoint anterior
    local retreatWp = getRetreatWaypoint(data, env.pos, 4)
    if retreatWp then return retreatWp end
    
    -- Fallback: spawn
    return MOBA_BOTS.TEAMS[data.teamId].spawn
end

local function getSafeRecallPosition(data, env)
    if not data or not env then return nil end
    
    if env.allyTowerPos then
        return getPosBehind(env.allyTowerPos, data.teamId, 4)
    end
    
    local retreatWp = getRetreatWaypoint(data, env.pos, 6)
    if retreatWp then return retreatWp end
    
    return MOBA_BOTS.TEAMS[data.teamId].spawn
end

local function shouldRetreat(data, env)
    if not data or not env then return false end
    local cfg = MOBA_BOTS.CONFIG
    
    -- Nunca recua durante all-in
    if data.state == MOBA_BOTS.STATE.ALL_IN then
        return env.hp < cfg.HP_CRITICAL * 0.5
    end
    
    -- Não recua durante kiting fight a menos que crítico
    if data.state == MOBA_BOTS.STATE.KITING_FIGHT then
        return env.hp < cfg.HP_CRITICAL
    end
    
    -- HP crítico = recua sempre
    if env.hp < cfg.HP_CRITICAL then
        return true
    end
    
    -- Sob ataque de torre sem minions tankando = recua imediatamente
    if isUnderTowerAttack(data) and not env.allyMinionsTankingTower then
        return true
    end
    
    -- Dentro do range de torre inimiga sem minions = recua
    if env.underEnemyTower and not env.allyMinionsTankingTower then
        return true
    end
    
    -- Sem wave aliada e tem inimigos por perto = recua
    if not env.hasAllyWaveNearby and env.nearestEnemyDist <= cfg.VISION_RANGE then
        if env.enemyMinions > 0 and env.allyMinions == 0 and not env.nearAllyTower then
            return true
        end
    end
    
    -- Sob ataque com HP baixo e sem minions aliados
    if isUnderAttack(data) and env.hp < cfg.HP_LOW and env.allyMinions == 0 then
        return true
    end
    
    -- Sob ataque com desvantagem numérica significativa
    if isUnderAttack(data) and env.hp < cfg.HP_MEDIUM then
        local myPower = 1 + env.allyHeroes + env.allyMinions * 0.4
        local enemyPower = env.enemyHeroes * 1.5 + env.enemyMinions * 0.3
        if enemyPower > myPower * 1.6 then
            return true
        end
    end
    
    -- Além da última torre sem wave = recua
    if env.isBeyondLastTower and not env.hasAllyWaveNearby then
        if env.nearestEnemyDist <= cfg.VISION_RANGE then
            return true
        end
    end
    
    -- Nível de perigo muito alto
    if env.dangerLevel >= 60 then
        return true
    end
    
    return false
end

local function shouldRecall(data, env)
    if not data or not env then return false end
    local cfg = MOBA_BOTS.CONFIG
    
    -- Não faz recall se sob ataque
    if isUnderAttack(data) or isUnderTowerAttack(data) then
        return false
    end
    
    -- Não faz recall durante all-in
    if data.state == MOBA_BOTS.STATE.ALL_IN then
        return false
    end
    
    -- HP baixo, seguro, e sem heróis inimigos perto
    return env.hp < cfg.HP_LOW and isSafe(data) and env.nearestEnemyHeroDist > cfg.RECALL_SAFE_DISTANCE
end

local function shouldDefendTower(data, env)
    if not data or not env then return false end
    local cfg = MOBA_BOTS.CONFIG
    
    -- Não defende durante all-in
    if data.state == MOBA_BOTS.STATE.ALL_IN then
        return false
    end
    
    -- Não tem minions na torre aliada
    if env.enemyMinionsAtAllyTower == 0 then
        return false
    end
    
    -- Torre muito longe
    if env.allyTowerDist > cfg.DEFEND_TOWER_RANGE then
        return false
    end
    
    -- HP muito baixo
    if env.hp < cfg.DEFEND_MIN_HP then
        return false
    end
    
    return true
end

local function hasEnemyHeroNearTower(env)
    if not env then return false end
    return env.nearestEnemyHeroDist <= MOBA_BOTS.CONFIG.SAFE_FROM_HERO_DISTANCE
end

local function shouldAssistAlly(data, env)
    if not data or not env then return false end
    local cfg = MOBA_BOTS.CONFIG
    
    -- Não tem aliado em combate
    if not env.allyInCombat or not env.allyInCombatTarget then
        return false
    end
    
    -- HP muito baixo ou em all-in
    if env.hp < cfg.HP_LOW or data.state == MOBA_BOTS.STATE.ALL_IN then
        return false
    end
    
    -- Verifica se alvo está em posição segura
    if env.allyInCombatTarget then
        local targetPos = env.allyInCombatTarget:getPosition()
        if env.enemyTowerPos and botDist(targetPos, env.enemyTowerPos) <= cfg.TOWER_RANGE then
            if not env.allyMinionsTankingTower then
                return false
            end
        end
    end
    
    return true
end

local function shouldHealAlly(data, env)
    if not data or not env then return false end
    
    -- Só druids curam aliados
    if data.class ~= "druid" then
        return false
    end
    
    -- Não tem aliado precisando de cura
    if not env.allyNeedingHeal then
        return false
    end
    
    -- Verifica se tem spell de cura disponível
    local class = MOBA_BOTS.CLASSES[data.class]
    for _, spell in ipairs(class.spells) do
        if spell.type == "heal_ally" and canCastSpell(data, spell) then
            if env.allyNeedingHealDist <= (spell.range or 7) then
                return true
            end
        end
    end
    
    return false
end

local function shouldAllIn(data, env)
    if not data or not env then return false end
    local cfg = MOBA_BOTS.CONFIG
    
    -- Não faz all-in sob torre inimiga
    if env.underEnemyTower and not env.allyMinionsTankingTower then
        return false
    end
    
    -- Condições básicas não satisfeitas
    if not env.canAllIn or not env.allInTarget then
        return false
    end
    
    -- Já decidiu neste ciclo
    if data.allInDecided then
        return data.allInDecided == "yes"
    end
    
    -- Chance de all-in
    if math.random() <= cfg.ALL_IN_CHANCE then
        data.allInDecided = "yes"
        data.allInTarget = env.allInTarget
        return true
    else
        data.allInDecided = "no"
        return false
    end
end

local function checkResetAllIn(data, env)
    if not data or not env then return false end
    
    -- Não está em all-in
    if data.state ~= MOBA_BOTS.STATE.ALL_IN then
        -- Reset decisão se HP recuperou
        if env.hp > MOBA_BOTS.CONFIG.ALL_IN_MY_HP_MAX + 0.15 then
            data.allInDecided = nil
            data.allInTarget = nil
        end
        return false
    end
    
    -- Condições para cancelar all-in
    if isUnderTowerAttack(data) then
        data.allInDecided = nil
        data.allInTarget = nil
        return true
    end
    
    if env.underEnemyTower and not env.allyMinionsTankingTower then
        data.allInDecided = nil
        data.allInTarget = nil
        return true
    end
    
    if env.enemyHeroes > 1 and env.allyHeroes == 0 then
        data.allInDecided = nil
        data.allInTarget = nil
        return true
    end
    
    -- Verifica se alvo ainda é válido
    if data.allInTarget then
        local ok, hp = pcall(function() return data.allInTarget:getHealth() end)
        if not ok or not hp or hp <= 0 then
            data.allInDecided = nil
            data.allInTarget = nil
            return true
        end
    else
        data.allInDecided = nil
        return true
    end
    
    return false
end

local function canChase(data, env)
    if not data or not env then return false end
    local cfg = MOBA_BOTS.CONFIG
    
    -- Não tem alvo de chase
    if not env.lowHpEnemy then
        return false
    end
    
    -- HP muito baixo
    if env.hp < cfg.HP_MEDIUM then
        return false
    end
    
    -- Sob ataque de torre
    if isUnderTowerAttack(data) then
        return false
    end
    
    -- Sob torre inimiga sem minions
    if env.underEnemyTower and not env.allyMinionsTankingTower then
        return false
    end
    
    -- Muitos inimigos
    if env.enemyHeroes > 1 and env.allyHeroes == 0 then
        return false
    end
    
    -- Verifica se alvo não está protegido por torre
    local targetPos = env.lowHpEnemy:getPosition()
    if env.enemyTowerPos then
        if botDist(targetPos, env.enemyTowerPos) <= cfg.TOWER_RANGE and not env.allyMinionsTankingTower then
            return false
        end
    end
    
    return true
end

local function canEngage(data, env)
    if not data or not env then return false end
    local cfg = MOBA_BOTS.CONFIG
    
    -- Sob ataque ou HP baixo
    if isUnderAttack(data) and env.hp < cfg.HP_HEALTHY then
        return false
    end
    
    -- Sob torre inimiga sem minions
    if env.underEnemyTower and not env.allyMinionsTankingTower then
        return false
    end
    
    -- Sem minions aliados
    if env.allyMinions == 0 then
        return false
    end
    
    -- Sem herói inimigo por perto
    if not env.nearestEnemyHero then
        return false
    end
    
    -- Muito longe para engajar
    if env.nearestEnemyHeroDist > cfg.ENGAGE_RANGE then
        return false
    end
    
    -- Calcula vantagem
    local myPower = 1 + env.allyHeroes + env.allyMinions * 0.4
    local enemyPower = env.enemyHeroes + env.enemyMinions * 0.25
    
    -- Precisa de vantagem numérica ou inimigo com HP baixo
    return myPower >= enemyPower + 0.5 or (env.nearestEnemyHeroHp < 0.35 and myPower >= enemyPower)
end

local function canApproachTower(data, env)
    if not data or not env then return false end
    
    -- NUNCA aproxima de torre sem minions tankando
    if not env.allyMinionsTankingTower then
        return false
    end
    
    return true
end

local function isTargetSafeToAttack(target, data, env)
    if not target or not data or not env then return false end
    
    local targetPos = target:getPosition()
    local cfg = MOBA_BOTS.CONFIG
    
    -- Verifica se alvo está perto de torre inimiga
    if env.enemyTowerPos then
        local targetToTower = botDist(targetPos, env.enemyTowerPos)
        if targetToTower <= cfg.TOWER_RANGE then
            if not env.allyMinionsTankingTower then
                return false
            end
        end
    end
    
    return true
end

-- ==========================================================
-- LANE ASSIGNMENT
-- ==========================================================

function MOBA_BOTS.assignLaneToBot(cid, data)
    if not data then return end
    
    -- Verifica se já tem lane persistente
    if data.uniqueId and MOBA_BOTS.PersistentLanes[data.uniqueId] then
        data.assignedLane = MOBA_BOTS.PersistentLanes[data.uniqueId]
        data.wpIndex = 1
        return
    end
    
    local vocPriority = MOBA_BOTS.VOCATIONS[data.class]
    if not vocPriority then
        data.assignedLane = "mid"
        if data.uniqueId then
            MOBA_BOTS.PersistentLanes[data.uniqueId] = "mid"
        end
        return
    end
    
    -- Conta ocupação de lanes
    local laneCounts = {top = 0, mid = 0, bot = 0}
    
    -- Conta outros bots do mesmo time
    for otherCid, otherData in pairs(MOBA_BOTS.Data) do
        if otherCid ~= cid and otherData.teamId == data.teamId and otherData.assignedLane then
            local c = Creature(otherCid)
            if c and c:getHealth() > 0 then
                laneCounts[otherData.assignedLane] = (laneCounts[otherData.assignedLane] or 0) + 1
            end
        end
    end
    
    -- Conta players do mesmo time
    for _, p in ipairs(Game.getPlayers()) do
        local pTeam = p:getStorageValue(MOBA.STORAGE_TEAM)
        if pTeam == data.teamId then
            local playerClass = MOBA.getPlayerClass and MOBA.getPlayerClass(p)
            if playerClass and MOBA_BOTS.VOCATIONS[playerClass] then
                local preferredLane = MOBA_BOTS.VOCATIONS[playerClass].priority[1]
                laneCounts[preferredLane] = (laneCounts[preferredLane] or 0) + 1
            end
        end
    end
    
    local cfg = MOBA_BOTS.CONFIG
    local chosen = nil
    
    -- Tenta lanes por prioridade da vocação
    for _, lane in ipairs(vocPriority.priority) do
        if (laneCounts[lane] or 0) < cfg.MAX_PER_LANE then
            chosen = lane
            break
        end
    end
    
    -- Se todas cheias, vai para a menos lotada
    if not chosen then
        local minCount = 999
        for _, lane in ipairs(vocPriority.priority) do
            if (laneCounts[lane] or 0) < minCount then
                minCount = laneCounts[lane] or 0
                chosen = lane
            end
        end
    end
    
    data.assignedLane = chosen or "mid"
    data.wpIndex = 1
    
    if data.uniqueId then
        MOBA_BOTS.PersistentLanes[data.uniqueId] = data.assignedLane
    end
    
    logBot(data, "LANE", "Atribuído para " .. data.assignedLane:upper())
end

-- ==========================================================
-- BOT THINK - LÓGICA PRINCIPAL
-- ==========================================================

function BotThink(cid)
    local bot = Creature(cid)
    if not bot or bot:getHealth() <= 0 then return end
    if not MOBA or not MOBA.matchActive then return end
    
    local data = MOBA_BOTS.Data[cid]
    if not data then return end

    data.myId = cid
    local team = MOBA_BOTS.TEAMS[data.teamId]
    local class = MOBA_BOTS.CLASSES[data.class]
    local pos = bot:getPosition()
    local now = os.clock()
    local canAtk = not data.lastAtk or (now - data.lastAtk) >= MOBA_BOTS.CONFIG.ATTACK_CD
    local cfg = MOBA_BOTS.CONFIG
    local interval = cfg.THINK_INTERVAL

    -- Limpa follow
    bot:setFollowCreature(nil)
    
    -- Incrementa loops de estado
    data.stateLoops = (data.stateLoops or 0) + 1
    
    -- Atribui lane se não tem
    if not data.assignedLane then
        MOBA_BOTS.assignLaneToBot(cid, data)
    end
    
    -- Limpeza periódica de cache
    if math.random(1, 100) == 1 then
        MOBA_BOTS.cleanupDamageTrackers()
    end

    -- ==========================================================
    -- ESTADO: PREPARING
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.PREPARING then
        data.preparingTime = (data.preparingTime or 0) + interval / 1000
        
        if not data.assignedLane then
            MOBA_BOTS.assignLaneToBot(cid, data)
        end
        
        if data.assignedLane or data.preparingTime > cfg.LANE_ASSIGN_TIMEOUT then
            if not data.assignedLane then
                data.assignedLane = "mid"
                if data.uniqueId then
                    MOBA_BOTS.PersistentLanes[data.uniqueId] = "mid"
                end
            end
            data.preparingTime = 0
            setState(data, MOBA_BOTS.STATE.IN_BASE)
        end
        
        addEvent(BotThink, 500, cid)
        return
    end

    -- ==========================================================
    -- ESTADO: RECALLING
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.RECALLING then
        if processRecall(bot, data) then
            addEvent(BotThink, 300, cid)
            return
        end
        -- Recall foi cancelado ou completou
    end

    -- ==========================================================
    -- SCAN DO AMBIENTE
    -- ==========================================================
    local env = scanEnvironment(bot, data)
    if not env then
        addEvent(BotThink, interval, cid)
        return
    end
    
    -- Atualiza flags de estado
    data.inBase = env.inBaseZone

    -- ==========================================================
    -- PRIORIDADE 0: EMERGÊNCIA ABSOLUTA - TOMANDO DANO DE TORRE
    -- BOT JAMAIS DEVE TANKAR TORRE!
    -- ==========================================================
    if isUnderTowerAttack(data) then
        setState(data, MOBA_BOTS.STATE.FLEEING_TOWER)
        data.allInDecided = nil
        data.allInTarget = nil
        
        tryUseSupplies(bot, data, env)
        emergencyEscapeFromTower(bot, data, env)
        
        if env.enemyTowerPos and botDist(pos, env.enemyTowerPos) <= cfg.TOWER_RANGE then
            data.towerFleeAttempts = (data.towerFleeAttempts or 0) + 1
            
            if data.towerFleeAttempts >= 8 then
                local safePos = getRetreatWaypoint(data, pos, 5)
                if safePos and canWalkTo(safePos, cid) then
                    bot:teleportTo(safePos)
                    bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
                    data.towerFleeAttempts = 0
                    logBot(data, "EMERGENCY TELEPORT", "Fugindo de torre")
                else
                    bot:teleportTo(team.spawn)
                    bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
                    data.towerFleeAttempts = 0
                    setState(data, MOBA_BOTS.STATE.IN_BASE)
                    logBot(data, "EMERGENCY BASE", "Não conseguiu fugir da torre")
                end
            end
        else
            data.towerFleeAttempts = 0
        end
        
        addEvent(BotThink, cfg.THINK_INTERVAL_CRITICAL, cid)
        return
    end

    -- ==========================================================
    -- PRIORIDADE 1: DENTRO DO RANGE DA TORRE SEM MINIONS
    -- ==========================================================
    if env.underEnemyTower and not env.allyMinionsTankingTower then
        setState(data, MOBA_BOTS.STATE.FLEEING_TOWER)
        data.allInDecided = nil
        data.allInTarget = nil
        
        tryUseSupplies(bot, data, env)
        emergencyEscapeFromTower(bot, data, env)
        
        addEvent(BotThink, cfg.THINK_INTERVAL_CRITICAL, cid)
        return
    end

    -- ==========================================================
    -- PRIORIDADE 2: HP CRÍTICO = FUGA TOTAL
    -- ==========================================================
    if env.hp < cfg.HP_CRITICAL then
        setState(data, MOBA_BOTS.STATE.RETREATING)
        data.allInDecided = nil
        data.allInTarget = nil
        
        tryUseSupplies(bot, data, env)
        
        -- Tenta recall se seguro
        if isSafe(data) and env.nearestEnemyHeroDist > cfg.RECALL_SAFE_DISTANCE then
            startRecall(data, bot)
            addEvent(BotThink, 300, cid)
            return
        end
        
        -- Foge pela lane
        retreatLane(bot, data)
        
        addEvent(BotThink, cfg.THINK_INTERVAL_CRITICAL, cid)
        return
    end

    -- ==========================================================
    -- PRIORIDADE 2.5: STUCK ALÉM DA TORRE OU PERDIDO
    -- ==========================================================
    if isLostFromLane(bot, data) then
        data.lostCount = (data.lostCount or 0) + 1
        logBot(data, "LOST", "Longe da lane, tentativa " .. data.lostCount)
        
        if data.lostCount >= 10 then
            bot:teleportTo(team.spawn)
            bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
            data.lostCount = 0
            data.stuckCount = 0
            data.wpIndex = 1
            setState(data, MOBA_BOTS.STATE.IN_BASE)
            logBot(data, "TELEPORT BASE", "Estava perdido")
            addEvent(BotThink, 500, cid)
            return
        end
        
        if not isUnderAttack(data) and not isUnderTowerAttack(data) then
            startRecall(data, bot)
            addEvent(BotThink, 300, cid)
            return
        end
    else
        data.lostCount = 0
    end
    
    if isStuckBeyondEnemyTower(data, env) then
        logBot(data, "STUCK", "Além da torre inimiga")
        
        if not isUnderAttack(data) and not isUnderTowerAttack(data) then
            if env.nearestEnemyHeroDist > cfg.RECALL_SAFE_DISTANCE then
                startRecall(data, bot)
                addEvent(BotThink, 300, cid)
                return
            end
        end
        
        retreatLane(bot, data)
        
        if (data.stuckCount or 0) >= 20 then
            bot:teleportTo(team.spawn)
            bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
            data.stuckCount = 0
            data.wpIndex = 1
            setState(data, MOBA_BOTS.STATE.IN_BASE)
            logBot(data, "TELEPORT BASE", "Stuck demais")
        end
        
        addEvent(BotThink, interval, cid)
        return
    end

    -- ==========================================================
    -- ESTADO: IN_BASE
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.IN_BASE then
        data.totalBaseTime = (data.totalBaseTime or 0) + interval / 1000
        data.allInDecided = nil
        data.allInTarget = nil
        data.inBase = true
        
        if not data.assignedLane then
            MOBA_BOTS.assignLaneToBot(cid, data)
        end
        
        -- Compra itens
        tryBuyItems(bot, data)
        
        -- Cura na base
        if env.inHealZone or env.inBaseZone then
            if env.hp < cfg.HP_PERFECT then
                bot:addHealth(env.maxHp * cfg.BASE_HEAL_RATE)
                addEvent(BotThink, cfg.BASE_HEAL_INTERVAL, cid)
                return
            end
        end
        
        -- HP cheio e tem lane = sai da base
        if data.assignedLane and env.hp >= cfg.HP_HEALTHY then
            data.wpIndex = 1
            data.stuckCount = 0
            data.totalBaseTime = 0
            data.inBase = false
            setState(data, MOBA_BOTS.STATE.GOING_TO_LANE)
            logBot(data, "SAINDO", "Indo para " .. data.assignedLane:upper())
            addEvent(BotThink, interval, cid)
            return
        end
        
        -- Timeout forçado
        if data.totalBaseTime > cfg.BASE_FORCE_EXIT_TIME then
            local wps = getWaypoints(data)
            if wps and #wps > 0 then
                bot:teleportTo(Position(wps[1].x, wps[1].y, wps[1].z))
                bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
            end
            data.wpIndex = 1
            data.stuckCount = 0
            data.totalBaseTime = 0
            data.inBase = false
            setState(data, MOBA_BOTS.STATE.GOING_TO_LANE)
        end
        
        addEvent(BotThink, interval, cid)
        return
    else
        data.totalBaseTime = 0
    end

    -- ==========================================================
    -- ESTADO: GOING_TO_LANE
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.GOING_TO_LANE then
        if not data.assignedLane then
            MOBA_BOTS.assignLaneToBot(cid, data)
        end
        
        -- Se encontrou inimigos, muda para laning
        if env.nearestEnemyDist <= cfg.VISION_RANGE then
            setState(data, MOBA_BOTS.STATE.LANING)
        else
            -- Avança pelos waypoints
            local wps = getWaypoints(data)
            if wps and data.wpIndex and data.wpIndex >= #wps then
                setState(data, MOBA_BOTS.STATE.LANING)
            else
                advanceLane(bot, data)
            end
            
            addEvent(BotThink, interval, cid)
            return
        end
    end

    -- ==========================================================
    -- ESTADO: FLEEING_TOWER
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.FLEEING_TOWER then
        -- Verifica se ainda precisa fugir
        if not isUnderTowerAttack(data) and (not env.underEnemyTower or env.allyMinionsTankingTower) then
            setState(data, MOBA_BOTS.STATE.LANING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        -- Continua fugindo
        if env.enemyTowerPos then
            moveAway(bot, env.enemyTowerPos, data)
        else
            retreatLane(bot, data)
        end
        
        addEvent(BotThink, cfg.THINK_INTERVAL_CRITICAL, cid)
        return
    end

    -- ==========================================================
    -- ESTADO: ALL-IN
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.ALL_IN then
        if checkResetAllIn(data, env) then
            setState(data, MOBA_BOTS.STATE.RETREATING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        local target = data.allInTarget
        if target and isValidTarget(target) then
            local targetPos = target:getPosition()
            local distToTarget = botDist(pos, targetPos)
            
            tryUseSupplies(bot, data, env)
            tryUseSpells(bot, data, env, target)
            
            if distToTarget <= class.range then
                if canAtk then
                    doAttack(bot, target, data)
                end
            else
                moveToAttackPosition(bot, targetPos, data, class)
            end
            
            addEvent(BotThink, cfg.THINK_INTERVAL_COMBAT, cid)
            return
        end
        
        -- Alvo inválido
        data.allInDecided = nil
        data.allInTarget = nil
        setState(data, MOBA_BOTS.STATE.LANING)
        addEvent(BotThink, interval, cid)
        return
    end

    -- ==========================================================
    -- ESTADO: KITING_FIGHT
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.KITING_FIGHT then
        if not env.nearestEnemyHero or env.nearestEnemyHeroDist > cfg.CHASE_GIVE_UP_DISTANCE then
            setState(data, MOBA_BOTS.STATE.LANING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        if env.hp < cfg.HP_CRITICAL then
            if shouldAllIn(data, env) then
                setState(data, MOBA_BOTS.STATE.ALL_IN)
            else
                setState(data, MOBA_BOTS.STATE.RETREATING)
            end
            addEvent(BotThink, interval, cid)
            return
        end
        
        if not env.duelAdvantage and env.hp < cfg.HP_LOW then
            setState(data, MOBA_BOTS.STATE.RETREATING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        local enemyPos = env.nearestEnemyHeroPos
        local distToEnemy = env.nearestEnemyHeroDist
        
        tryUseSupplies(bot, data, env)
        tryUseSpells(bot, data, env, env.nearestEnemyHero)
        
        if class.ranged then
            -- Ataca se em range
            if distToEnemy <= class.range and canAtk then
                doAttack(bot, env.nearestEnemyHero, data)
            end
            
            -- Kiting: afasta se muito perto
            if distToEnemy < cfg.RANGED_OPTIMAL_DISTANCE then
                moveAway(bot, enemyPos, data)
            elseif distToEnemy > class.range then
                moveToAttackPosition(bot, enemyPos, data, class)
            end
        else
            -- Melee
            if env.duelAdvantage or env.hp > env.nearestEnemyHeroHp then
                if distToEnemy <= class.range and canAtk then
                    doAttack(bot, env.nearestEnemyHero, data)
                end
                if distToEnemy > class.range then
                    moveToAttackPosition(bot, enemyPos, data, class)
                end
            else
                setState(data, MOBA_BOTS.STATE.RETREATING)
            end
        end
        
        addEvent(BotThink, cfg.THINK_INTERVAL_COMBAT, cid)
        return
    end

    -- ==========================================================
    -- ESTADO: DEFENDING_TOWER
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.DEFENDING_TOWER then
        if env.hp < cfg.DEFEND_MIN_HP then
            setState(data, MOBA_BOTS.STATE.RETREATING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        if not shouldDefendTower(data, env) then
            if env.hp < cfg.HP_LOW and isSafe(data) then
                local recallPos = getSafeRecallPosition(data, env)
                if botDist(pos, recallPos) <= 2 and env.nearestEnemyHeroDist > cfg.RECALL_SAFE_DISTANCE then
                    startRecall(data, bot)
                    addEvent(BotThink, 300, cid)
                    return
                end
            end
            setState(data, MOBA_BOTS.STATE.LANING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        tryUseSupplies(bot, data, env)
        
        -- Se tem herói inimigo perto da torre, fica mais defensivo
        if hasEnemyHeroNearTower(env) then
            if env.allyTowerPos then
                local safePos = getPosBehind(env.allyTowerPos, data.teamId, 3)
                if botDist(pos, safePos) > 2 then
                    moveTowards(bot, safePos, data)
                else
                    tryUseSpells(bot, data, env, env.nearestEnemyHero)
                    
                    if canAtk and #env.targetsInRange > 0 then
                        local t = selectTarget(env, data, false)
                        if t then
                            doAttack(bot, t, data)
                        end
                    end
                end
            end
        else
            -- Só minions, ataca eles
            if env.nearestEnemyMinionAtTower then
                local minionPos = env.nearestEnemyMinionAtTower:getPosition()
                local minionDist = botDist(pos, minionPos)
                
                tryUseSpells(bot, data, env, env.nearestEnemyMinionAtTower)
                
                if minionDist <= class.range then
                    if canAtk then
                        doAttack(bot, env.nearestEnemyMinionAtTower, data)
                    end
                else
                    moveToAttackPosition(bot, minionPos, data, class)
                end
            end
        end
        
        addEvent(BotThink, interval, cid)
        return
    end

    -- ==========================================================
    -- ESTADO: ASSISTING_ALLY
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.ASSISTING_ALLY then
        if not shouldAssistAlly(data, env) then
            setState(data, MOBA_BOTS.STATE.LANING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        local target = env.allyInCombatTarget
        if target and isValidTarget(target) then
            local targetPos = target:getPosition()
            local distToTarget = botDist(pos, targetPos)
            
            tryUseSupplies(bot, data, env)
            tryUseSpells(bot, data, env, target)
            
            if distToTarget <= class.range then
                if canAtk then
                    doAttack(bot, target, data)
                end
                
                if class.ranged and distToTarget < cfg.RANGED_MIN_DISTANCE then
                    moveAway(bot, targetPos, data)
                end
            else
                moveToAttackPosition(bot, targetPos, data, class)
            end
        else
            setState(data, MOBA_BOTS.STATE.LANING)
        end
        
        addEvent(BotThink, cfg.THINK_INTERVAL_COMBAT, cid)
        return
    end

    -- ==========================================================
    -- ESTADO: HEALING_ALLY (Druid)
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.HEALING_ALLY then
        if not shouldHealAlly(data, env) then
            setState(data, MOBA_BOTS.STATE.LANING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        -- Tenta curar
        tryUseSpells(bot, data, env, nil)
        
        -- Se precisa chegar mais perto do aliado
        if env.allyNeedingHeal then
            local healSpell = nil
            for _, spell in ipairs(class.spells) do
                if spell.type == "heal_ally" then
                    healSpell = spell
                    break
                end
            end
            
            if healSpell and env.allyNeedingHealDist > (healSpell.range or 7) then
                moveTowards(bot, env.allyNeedingHeal:getPosition(), data)
            end
        end
        
        addEvent(BotThink, interval, cid)
        return
    end

    -- ==========================================================
    -- ESTADO: WAITING_WAVE
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.WAITING_WAVE then
        -- Se já tem wave, avança
        if env.hasAllyWaveNearby then
            setState(data, MOBA_BOTS.STATE.LANING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        -- Recua para posição segura e espera
        local safePos = getBestRetreatPosition(data, env)
        if safePos and botDist(pos, safePos) > 3 then
            moveTowards(bot, safePos, data)
        end
        
        -- Pode atacar alvos em range enquanto espera
        if canAtk and #env.targetsInRange > 0 then
            local t = selectTarget(env, data, false)
            if t and isTargetSafeToAttack(t, data, env) then
                doAttack(bot, t, data)
            end
        end
        
        addEvent(BotThink, interval, cid)
        return
    end

    -- ==========================================================
    -- ESTADO: RETREATING
    -- ==========================================================
    if data.state == MOBA_BOTS.STATE.RETREATING then
        tryUseSupplies(bot, data, env)
        
        -- Tenta recall se seguro e HP baixo
        if shouldRecall(data, env) then
            local recallPos = getSafeRecallPosition(data, env)
            if botDist(pos, recallPos) <= 2 then
                startRecall(data, bot)
                addEvent(BotThink, 300, cid)
                return
            end
            moveTowards(bot, recallPos, data)
            addEvent(BotThink, interval, cid)
            return
        end
        
        -- Ainda precisa recuar?
        if shouldRetreat(data, env) or not isSafe(data) then
            retreatLane(bot, data)
            addEvent(BotThink, interval, cid)
            return
        end
        
        -- Está seguro
        if isSafe(data) then
            if env.hp < cfg.HP_LOW then
                -- Ainda com HP baixo, tenta recall
                local recallPos = getSafeRecallPosition(data, env)
                if botDist(pos, recallPos) <= 2 and env.nearestEnemyHeroDist > cfg.RECALL_SAFE_DISTANCE then
                    startRecall(data, bot)
                    addEvent(BotThink, 300, cid)
                    return
                end
                moveTowards(bot, recallPos, data)
                addEvent(BotThink, interval, cid)
                return
            end
            
            setState(data, MOBA_BOTS.STATE.LANING)
        end
        
        addEvent(BotThink, interval, cid)
        return
    end

    -- ==========================================================
    -- VERIFICAÇÕES DE PRIORIDADE (sem estado específico)
    -- ==========================================================
    
    -- Druid: prioriza cura de aliados
    if shouldHealAlly(data, env) then
        setState(data, MOBA_BOTS.STATE.HEALING_ALLY)
        addEvent(BotThink, interval, cid)
        return
    end
    
    -- Assistir aliado em combate
    if shouldAssistAlly(data, env) then
        setState(data, MOBA_BOTS.STATE.ASSISTING_ALLY)
        addEvent(BotThink, interval, cid)
        return
    end
    
    -- Defender torre
    if shouldDefendTower(data, env) then
        setState(data, MOBA_BOTS.STATE.DEFENDING_TOWER)
        addEvent(BotThink, interval, cid)
        return
    end
    
    -- All-in
    if shouldAllIn(data, env) then
        setState(data, MOBA_BOTS.STATE.ALL_IN)
        addEvent(BotThink, interval, cid)
        return
    end
    
    -- Esperar wave (não avança sem minions perto de torre)
    if env.shouldWaitForWave then
        setState(data, MOBA_BOTS.STATE.WAITING_WAVE)
        addEvent(BotThink, interval, cid)
        return
    end
    
    -- Recuo necessário
    if shouldRetreat(data, env) then
        setState(data, MOBA_BOTS.STATE.RETREATING)
        addEvent(BotThink, interval, cid)
        return
    end

    -- ==========================================================
    -- COMBATE
    -- ==========================================================
    
    -- Seleciona alvo
    local target = nil
    local targetDist = 999
    
    -- Prioridade 1: Herói inimigo em range
    if env.enemyHeroInRange and isTargetSafeToAttack(env.enemyHeroInRange, data, env) then
        target = env.enemyHeroInRange
        targetDist = env.enemyHeroInRangeDist
    end
    
    -- Prioridade 2: Minion com low HP (last hit)
    if not target and env.lowHpMinion and env.lowHpMinionDist <= class.range then
        if isTargetSafeToAttack(env.lowHpMinion, data, env) then
            target = env.lowHpMinion
            targetDist = env.lowHpMinionDist
        end
    end
    
    -- Prioridade 3: Qualquer minion em range
    if not target and env.nearestEnemyMinion and env.nearestEnemyMinionDist <= class.range then
        if isTargetSafeToAttack(env.nearestEnemyMinion, data, env) then
            target = env.nearestEnemyMinion
            targetDist = env.nearestEnemyMinionDist
        end
    end
    
    -- Prioridade 4: Torre (se minions tankando)
    if not target and env.enemyTower and env.allyMinionsTankingTower then
        if env.enemyTowerDist <= class.range then
            target = env.enemyTower
            targetDist = env.enemyTowerDist
        end
    end
    
    -- Se tem alvo, ataca
    if target and canAtk then
        setState(data, MOBA_BOTS.STATE.FIGHTING)
        tryUseSupplies(bot, data, env)
        tryUseSpells(bot, data, env, target)
        doAttack(bot, target, data)
        
        -- Kiting para ranged após atacar
        if class.ranged and targetDist < cfg.RANGED_KITE_DISTANCE and isHero(target) then
            kiteAway(bot, target:getPosition(), data, class)
        end
        
        addEvent(BotThink, cfg.THINK_INTERVAL_COMBAT, cid)
        return
    end

    -- ===== KNIGHT: APROXIMAR PARA USAR EXORI =====
    if data.class == "knight" and env.nearestEnemyHero and isTargetSafeToAttack(env.nearestEnemyHero, data, env) then
        local hasAdjacentSpellReady = false
        for _, spell in ipairs(class.spells) do
            if spell.pattern == "adjacent" and canCastSpell(data, spell) then
                hasAdjacentSpellReady = true
                break
            end
        end
        
        if hasAdjacentSpellReady and env.nearestEnemyHeroDist > 1 and env.nearestEnemyHeroDist <= cfg.ENGAGE_RANGE then
            setState(data, MOBA_BOTS.STATE.FIGHTING)
            moveToAttackPosition(bot, env.nearestEnemyHeroPos, data, class)
            addEvent(BotThink, cfg.THINK_INTERVAL_COMBAT, cid)
            return
        end
    end

    -- ==========================================================
    -- APROXIMAR DE ALVOS
    -- ==========================================================
    
    -- Verifica se é seguro avançar
    local canAdvance = true
    
    -- Não avança perto de torre sem minions
    if env.enemyTowerPos then
        local distToTower = botDist(pos, env.enemyTowerPos)
        if distToTower <= cfg.TOWER_SAFE_DISTANCE and not env.allyMinionsTankingTower then
            canAdvance = false
        end
    end
    
    -- Não avança sem wave se tem inimigos por perto
    if not env.hasAllyWaveNearby and env.nearestEnemyDist <= cfg.VISION_RANGE then
        canAdvance = false
    end
    
    if canAdvance then
        local approachTarget = nil
        
        -- Aproxima de herói inimigo (se seguro)
        if env.nearestEnemyHero and env.nearestEnemyHeroDist <= cfg.VISION_RANGE then
            if isTargetSafeToAttack(env.nearestEnemyHero, data, env) then
                approachTarget = env.nearestEnemyHeroPos
            end
        end
        
        -- Ou aproxima de minion
        if not approachTarget and env.nearestEnemyMinion then
            if isTargetSafeToAttack(env.nearestEnemyMinion, data, env) then
                approachTarget = env.nearestEnemyMinion:getPosition()
            end
        end
        
        -- Ou aproxima de torre (se minions tankando)
        if not approachTarget and env.enemyTower and env.allyMinionsTankingTower then
            approachTarget = env.enemyTowerPos
        end
        
        if approachTarget then
            setState(data, MOBA_BOTS.STATE.LANING)
            moveToAttackPosition(bot, approachTarget, data, class)
            addEvent(BotThink, interval, cid)
            return
        end
    end

    -- ==========================================================
    -- KITING PARA RANGED
    -- ==========================================================
    if class.ranged and env.nearestEnemyCreature and env.nearestEnemyCreatureDist <= cfg.RANGED_KITE_DISTANCE then
        if isEnemyTeam(env.nearestEnemyCreature, data) then
            tryUseSupplies(bot, data, env)
            
            -- Ataca se pode
            if canAtk and env.nearestEnemyCreatureDist <= class.range then
                tryUseSpells(bot, data, env, env.nearestEnemyCreature)
                doAttack(bot, env.nearestEnemyCreature, data)
            end
            
            -- Kita para trás
            moveAway(bot, env.nearestEnemyCreature:getPosition(), data)
            
            addEvent(BotThink, interval, cid)
            return
        end
    end

    -- ==========================================================
    -- DUELO 1v1
    -- ==========================================================
    if env.isDuelSituation and env.nearestEnemyHero then
        -- Se tem desvantagem de minions, recua
        if env.enemyMinions > 0 and env.allyMinions == 0 then
            setState(data, MOBA_BOTS.STATE.RETREATING)
            addEvent(BotThink, interval, cid)
            return
        end
        
        -- Sem minions envolvidos = kiting fight
        if env.enemyMinions == 0 then
            setState(data, MOBA_BOTS.STATE.KITING_FIGHT)
            addEvent(BotThink, interval, cid)
            return
        end
    end

    -- ==========================================================
    -- DESVANTAGEM NUMÉRICA SEVERA
    -- ==========================================================
    if env.enemyHeroes >= 2 and env.allyHeroes == 0 and env.hp < cfg.HP_HEALTHY then
        setState(data, MOBA_BOTS.STATE.RETREATING)
        addEvent(BotThink, interval, cid)
        return
    end

    -- ==========================================================
    -- SIEGE (atacar torre com minions tankando)
    -- ==========================================================
    if env.allyMinionsTankingTower and env.enemyTower then
        setState(data, MOBA_BOTS.STATE.SIEGING)
        
        tryUseSupplies(bot, data, env)
        tryUseSpells(bot, data, env, env.enemyTower)
        
        if env.enemyTowerDist <= class.range then
            if canAtk then
                doAttack(bot, env.enemyTower, data)
            end
        else
            if env.allyMinionsTankingTower then
                moveToAttackPosition(bot, env.enemyTowerPos, data, class)
            end
        end
        
        addEvent(BotThink, interval, cid)
        return
    end

    -- ==========================================================
    -- CHASE LOW HP ENEMY
    -- ==========================================================
    if canChase(data, env) then
        setState(data, MOBA_BOTS.STATE.CHASING)
        
        local targetPos = env.lowHpEnemy:getPosition()
        
        tryUseSupplies(bot, data, env)
        tryUseSpells(bot, data, env, env.lowHpEnemy)
        
        if botDist(pos, targetPos) <= class.range then
            if canAtk then
                doAttack(bot, env.lowHpEnemy, data)
            end
        else
            moveToAttackPosition(bot, targetPos, data, class)
        end
        
        addEvent(BotThink, cfg.THINK_INTERVAL_COMBAT, cid)
        return
    end

    -- ==========================================================
    -- ENGAGE
    -- ==========================================================
    if canEngage(data, env) then
        setState(data, MOBA_BOTS.STATE.FIGHTING)
        
        local targetPos = env.nearestEnemyHeroPos
        
        tryUseSupplies(bot, data, env)
        tryUseSpells(bot, data, env, env.nearestEnemyHero)
        
        if env.nearestEnemyHeroDist <= class.range then
            if canAtk then
                doAttack(bot, env.nearestEnemyHero, data)
            end
        else
            moveToAttackPosition(bot, targetPos, data, class)
        end
        
        addEvent(BotThink, cfg.THINK_INTERVAL_COMBAT, cid)
        return
    end

    -- ==========================================================
    -- LANING PADRÃO
    -- ==========================================================
    setState(data, MOBA_BOTS.STATE.LANING)
    
    if env.hasAllyWaveNearby then
        -- Acompanha a wave
        if env.allyFrontlinePos then
            local behindPos = getPosBehind(env.allyFrontlinePos, data.teamId, 2)
            if behindPos and botDist(pos, behindPos) > 2 then
                moveTowards(bot, behindPos, data)
            else
                advanceLane(bot, data)
            end
        else
            advanceLane(bot, data)
        end
    else
        -- Sem wave
        if env.nearestEnemyDist <= cfg.VISION_RANGE then
            -- Tem inimigos, espera ou recua um pouco
            if env.nearestEnemyDist < 5 then
                retreatLane(bot, data)
            end
            -- Senão fica parado esperando wave
        else
            -- Sem inimigos visíveis, avança
            advanceLane(bot, data)
        end
    end
    
    addEvent(BotThink, interval, cid)
end

-- ==========================================================
-- SPAWN / RESPAWN
-- ==========================================================

function MOBA_BOTS.spawn(teamId, className)
    return MOBA_BOTS.respawnClone(teamId, className, 8, MOBA_BOTS.EXP_TABLE[8], MOBA_BOTS.CONFIG.STARTING_GOLD)
end

function MOBA_BOTS.respawnClone(teamId, className, level, exp, gold, skill)
    if not MOBA then return false end
    
    local team = MOBA_BOTS.TEAMS[teamId]
    local class = MOBA_BOTS.CLASSES[className]
    if not team or not class then return false end
    
    local bot = Game.createMonster("Hero Bot", team.spawn, false, true)
    if not bot then return false end
    
    local cid = bot:getId()
    local mobaTeam = (teamId == 1) and MOBA.TEAMS.LEFT or MOBA.TEAMS.RIGHT
    
    bot:registerEvent("BotPrepareDeath")
    bot:registerEvent("MobaHealthChange")
    bot:changeSpeed(class.speed)
    
    -- Outfit
    local look = math.random(0, 1) == 0 and class.outfit.female or class.outfit.male
    local colors = {
        lookHead = math.random(0, 132),
        lookBody = math.random(0, 132),
        lookLegs = math.random(0, 132),
        lookFeet = math.random(0, 132)
    }
    local addon = level >= 18 and 3 or (level >= 13 and 1 or 0)
    
    bot:setOutfit({
        lookType = look,
        lookHead = colors.lookHead,
        lookBody = colors.lookBody,
        lookLegs = colors.lookLegs,
        lookFeet = colors.lookFeet,
        lookAddons = addon
    })
    
    bot:setSkull(mobaTeam.skull)
    
    local maxHp = class.hp + level * class.hpGain
    bot:setMaxHealth(maxHp)
    bot:addHealth(maxHp)
    
    local uid = tostring(teamId) .. "_" .. className .. "_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))

    MOBA_BOTS.Data[cid] = {
	towerFleeAttempts = 0,
	lostCount = 0,
        uniqueId = uid,
        teamId = teamId,
        class = className,
        enemySkull = mobaTeam.enemy_skull,
        level = level,
        exp = exp or 0,
        gold = gold or MOBA_BOTS.CONFIG.STARTING_GOLD,
        skill = skill,
        lastAtk = 0,
        stuckCount = 0,
        lastPosKey = 0,
        state = MOBA_BOTS.STATE.PREPARING,
        stateTime = os.clock(),
        stateLoops = 0,
        myId = cid,
        assignedLane = nil,
        wpIndex = 1,
        lastDefenseCheck = 0,
        lastEnemySeenTime = os.time(),
        lastDamageTime = nil,
        lastTowerDamageTime = nil,
        recentDamage = 0,
        recallStartTime = nil,
        recallPos = nil,
        recallInitialHp = nil,
        lastRecallEffect = 0,
        currentPath = nil,
        pathIndex = nil,
        totalBaseTime = 0,
        outfitColors = colors,
        outfitType = look,
        preparingTime = 0,
        allInDecided = nil,
        allInTarget = nil,
        bonusAtk = 0,
        bonusHp = 0,
        bonusSpeed = 0,
        bonusDef = 0,
        hpPots = 0,
        manaPots = 0,
        lastPotionUse = 0,
        lastSpellCast = 0,
        spellCooldowns = {},
        inBase = true,
        idleTime = 0,
        lastAttackTarget = nil,
        lastMoveTime = 0,
        lastMoveDir = nil,
        kills = 0,
        deaths = 0,
        assists = 0,
        totalDamageDealt = 0,
        totalDamageTaken = 0,
        totalHealingDone = 0
    }
    
    if MOBA.MinionState then
        MOBA.MinionState[cid] = {
            teamId = teamId,
            isBot = true,
            enemySkull = mobaTeam.enemy_skull
        }
    end
    
    bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    
    logBot(MOBA_BOTS.Data[cid], "SPAWN", string.format("Level %d com %d gold", level, gold or 0))

    addEvent(function(bc)
        local b = Creature(bc)
        if not b then return end
        local d = MOBA_BOTS.Data[bc]
        if not d then return end
        MOBA_BOTS.assignLaneToBot(bc, d)
    end, 100, cid)

    addEvent(BotThink, 500, cid)
    return cid
end

function MOBA_BOTS.handleBotDeath(cid, oldData)
    if not MOBA or not MOBA.matchActive or not oldData then return end
    
    local teamId = oldData.teamId
    local className = oldData.class
    local level = oldData.level
    local exp = oldData.exp
    local gold = oldData.gold
    local skill = oldData.skill
    local uid = oldData.uniqueId
    local assignedLane = oldData.assignedLane

    if uid and assignedLane then
        MOBA_BOTS.PersistentLanes[uid] = assignedLane
    end
    
    MOBA_BOTS.Data[cid] = nil
    if MOBA.MinionState then
        MOBA.MinionState[cid] = nil
    end

    -- Registra morte para o time inimigo
    local enemyTeamId = teamId == 1 and 2 or 1
    MOBA_BOTS.addScore(enemyTeamId, "kills", 1)
    MOBA_BOTS.addScore(teamId, "deaths", 1)

    local respawnTime = 10000 + level * 1000
    
    logBot(oldData, "DEATH", string.format("Respawn em %.1fs", respawnTime / 1000))

    addEvent(function(tId, cN, lv, xp, gd, sk, u, lane)
        if not MOBA or not MOBA.matchActive then return end
        
        local team = MOBA_BOTS.TEAMS[tId]
        local class = MOBA_BOTS.CLASSES[cN]
        if not team or not class then return end
        
        local bot = Game.createMonster("Hero Bot", team.spawn, false, true)
        if not bot then return end
        
        local nc = bot:getId()
        local mobaTeam = (tId == 1) and MOBA.TEAMS.LEFT or MOBA.TEAMS.RIGHT
        
        bot:registerEvent("BotPrepareDeath")
        bot:registerEvent("MobaHealthChange")
        bot:changeSpeed(class.speed)
        
        local look = math.random(0, 1) == 0 and class.outfit.female or class.outfit.male
        local colors = {
            lookHead = math.random(0, 132),
            lookBody = math.random(0, 132),
            lookLegs = math.random(0, 132),
            lookFeet = math.random(0, 132)
        }
        local addon = lv >= 18 and 3 or (lv >= 13 and 1 or 0)
        
        bot:setOutfit({
            lookType = look,
            lookHead = colors.lookHead,
            lookBody = colors.lookBody,
            lookLegs = colors.lookLegs,
            lookFeet = colors.lookFeet,
            lookAddons = addon
        })
        
        bot:setSkull(mobaTeam.skull)
        
        local maxHp = class.hp + lv * class.hpGain
        bot:setMaxHealth(maxHp)
        bot:addHealth(maxHp)

        MOBA_BOTS.Data[nc] = {
            uniqueId = u,
            teamId = tId,
            class = cN,
            enemySkull = mobaTeam.enemy_skull,
            level = lv,
            exp = xp,
            gold = gd or 0,
            skill = sk,
            lastAtk = 0,
            stuckCount = 0,
            lastPosKey = 0,
            state = MOBA_BOTS.STATE.IN_BASE,
            stateTime = os.clock(),
            stateLoops = 0,
            myId = nc,
            assignedLane = lane,
            wpIndex = 1,
            lastDefenseCheck = 0,
            lastEnemySeenTime = os.time(),
            lastDamageTime = nil,
            lastTowerDamageTime = nil,
            recentDamage = 0,
            recallStartTime = nil,
            recallPos = nil,
            recallInitialHp = nil,
            lastRecallEffect = 0,
            currentPath = nil,
            pathIndex = nil,
            totalBaseTime = 0,
            outfitColors = colors,
            outfitType = look,
            preparingTime = 0,
            allInDecided = nil,
            allInTarget = nil,
            bonusAtk = 0,
            bonusHp = 0,
            bonusSpeed = 0,
            bonusDef = 0,
            hpPots = 0,
            manaPots = 0,
            lastPotionUse = 0,
            lastSpellCast = 0,
            spellCooldowns = {},
            inBase = true,
            idleTime = 0,
            lastAttackTarget = nil,
            lastMoveTime = 0,
            lastMoveDir = nil,
            kills = 0,
            deaths = 0,
            assists = 0,
            totalDamageDealt = 0,
            totalDamageTaken = 0,
            totalHealingDone = 0
        }
        
        if MOBA.MinionState then
            MOBA.MinionState[nc] = {
                teamId = tId,
                isBot = true,
                enemySkull = mobaTeam.enemy_skull
            }
        end
        
        bot:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
        
        logBot(MOBA_BOTS.Data[nc], "RESPAWN", string.format("Level %d", lv))
        
        if not lane then
            addEvent(function(bc)
                local b = Creature(bc)
                if not b then return end
                local d = MOBA_BOTS.Data[bc]
                if d and not d.assignedLane then
                    MOBA_BOTS.assignLaneToBot(bc, d)
                end
            end, 100, nc)
        end
        
        addEvent(BotThink, 500, nc)
    end, respawnTime, teamId, className, level, exp, gold, skill, uid, assignedLane)
end

-- ==========================================================
-- CREATURE EVENTS - PREPARE DEATH
-- ==========================================================

function onPrepareDeath(creature, killer)
    local cid = creature:getId()
    local data = MOBA_BOTS.Data[cid]
    
    if data then
        creature:addHealth(1)  -- Previne morte real
        
        -- Salva dados antes de remover
        local oldData = {}
        for k, v in pairs(data) do
            oldData[k] = v
        end
        
        -- Efeito de morte
        creature:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
        creature:say("X_X", TALKTYPE_MONSTER_SAY)
        
        -- Remove o bot
        addEvent(function(c)
            local bot = Creature(c)
            if bot then
                bot:remove()
            end
        end, 100, cid)
        
        -- Processa respawn
        MOBA_BOTS.handleBotDeath(cid, oldData)
        
        return false
    end
    
    return true
end

-- ==========================================================
-- CREATURE EVENTS - HEALTH CHANGE (para tracking de dano)
-- ==========================================================

function onBotHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    local cid = creature:getId()
    local data = MOBA_BOTS.Data[cid]
    
    if data then
        local totalDamage = primaryDamage + secondaryDamage
        
        if totalDamage > 0 then
            data.lastDamageTime = os.clock()
            data.recentDamage = (data.recentDamage or 0) + totalDamage
            data.totalDamageTaken = (data.totalDamageTaken or 0) + totalDamage
            
            -- Reset recentDamage após um tempo
            addEvent(function(botId, dmg)
                local bd = MOBA_BOTS.Data[botId]
                if bd then
                    bd.recentDamage = math.max(0, (bd.recentDamage or 0) - dmg)
                end
            end, 3000, cid, totalDamage)
            
            -- Verifica se foi dano de torre
            if attacker then
                if isTower(attacker) or isNexus(attacker) then
                    data.lastTowerDamageTime = os.clock()
                end
            end
        end
    end
    
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

-- ==========================================================
-- DEBUG FUNCTIONS
-- ==========================================================

function MOBA_BOTS.debugBot(cid)
    local d = MOBA_BOTS.Data[cid]
    if not d then
        print("[BOT] " .. cid .. " not found")
        return
    end
    
    local b = Creature(cid)
    local p = b and b:getPosition() or {x = 0, y = 0, z = 0}
    local hp = b and (b:getHealth() / b:getMaxHealth()) or 0
    
    print("=== BOT " .. cid .. " ===")
    print("Class: " .. d.class .. " | Team: " .. d.teamId .. " | Level: " .. d.level)
    print("HP: " .. string.format("%.0f%%", hp * 100) .. " | Gold: " .. (d.gold or 0))
    print("State: " .. (MOBA_BOTS.STATE_NAMES[d.state] or "?"))
    print("Lane: " .. (d.assignedLane or "?") .. " | WP: " .. (d.wpIndex or 0))
    print("Pos: " .. p.x .. "," .. p.y .. " | Stuck: " .. (d.stuckCount or 0))
    print("HpPots: " .. (d.hpPots or 0) .. " | ManaPots: " .. (d.manaPots or 0))
    print("BonusAtk: " .. (d.bonusAtk or 0) .. " | BonusHp: " .. (d.bonusHp or 0))
    print("Kills: " .. (d.kills or 0) .. " | Deaths: " .. (d.deaths or 0) .. " | Assists: " .. (d.assists or 0))
    print("Dmg Dealt: " .. (d.totalDamageDealt or 0) .. " | Dmg Taken: " .. (d.totalDamageTaken or 0))
    print("=================")
end

function MOBA_BOTS.debugAllBots()
    print("=== ALL BOTS ===")
    for cid, d in pairs(MOBA_BOTS.Data) do
        local b = Creature(cid)
        local alive = b and b:getHealth() > 0
        local hp = alive and string.format("%.0f%%", (b:getHealth() / b:getMaxHealth()) * 100) or "DEAD"
        local p = b and b:getPosition() or {x = 0, y = 0, z = 0}
        
        print(string.format("[%d] %s T%d %s S:%s HP:%s @%d,%d G:%d K:%d D:%d",
            cid, d.class, d.teamId, d.assignedLane or "?",
            MOBA_BOTS.STATE_NAMES[d.state] or "?", hp, p.x, p.y,
            d.gold or 0, d.kills or 0, d.deaths or 0))
    end
    print("================")
end

function MOBA_BOTS.debugEnvironment(cid)
    local b = Creature(cid)
    if not b then
        print("[ENV] Bot " .. cid .. " not found")
        return
    end
    
    local d = MOBA_BOTS.Data[cid]
    if not d then
        print("[ENV] Data for " .. cid .. " not found")
        return
    end
    
    local e = scanEnvironment(b, d)
    if not e then
        print("[ENV] Failed to scan environment")
        return
    end
    
    print("=== ENVIRONMENT " .. cid .. " ===")
    print("HP: " .. string.format("%.0f%%", e.hp * 100))
    print("Allies: " .. e.allyMinions .. "m " .. e.allyHeroes .. "h")
    print("Enemies: " .. e.enemyMinions .. "m " .. e.enemyHeroes .. "h")
    print("NearestEnemy: " .. e.nearestEnemyDist)
    print("NearestEnemyHero: " .. e.nearestEnemyHeroDist)
    print("AllyTower: " .. e.allyTowerDist .. " | EnemyTower: " .. e.enemyTowerDist)
    print("UnderEnemyTower: " .. tostring(e.underEnemyTower))
    print("AllyMinionsTankingTower: " .. tostring(e.allyMinionsTankingTower))
    print("HasAllyWaveNearby: " .. tostring(e.hasAllyWaveNearby))
    print("IsBeyondLastTower: " .. tostring(e.isBeyondLastTower))
    print("ShouldWaitForWave: " .. tostring(e.shouldWaitForWave))
    print("DangerLevel: " .. e.dangerLevel .. " | AdvantageLevel: " .. e.advantageLevel)
    print("TargetsInRange: " .. #e.targetsInRange)
    print("AlliesNeedingHeal: " .. #e.alliesNeedingHeal)
    print("========================")
end

function MOBA_BOTS.debugTeamScores()
    print("=== TEAM SCORES ===")
    for teamId, scores in pairs(MOBA_BOTS.TeamScores) do
        local teamName = teamId == 1 and "LUZ" or "SOMBRA"
        print(string.format("[%s] K:%d D:%d A:%d | Towers:%d | Gold:%d | Minions:%d",
            teamName,
            scores.kills or 0,
            scores.deaths or 0,
            scores.assists or 0,
            scores.towersDestroyed or 0,
            scores.totalGold or 0,
            scores.minionsKilled or 0
        ))
    end
    print("===================")
end

function MOBA_BOTS.debugMovement(cid)
    local d = MOBA_BOTS.Data[cid]
    if not d then
        print("[MOVE] Bot " .. cid .. " not found")
        return
    end
    
    local b = Creature(cid)
    if not b then
        print("[MOVE] Creature " .. cid .. " not found")
        return
    end
    
    local pos = b:getPosition()
    local wps = getWaypoints(d)
    
    print("=== MOVEMENT " .. cid .. " ===")
    print("Position: " .. pos.x .. "," .. pos.y)
    print("Lane: " .. (d.assignedLane or "?"))
    print("WPIndex: " .. (d.wpIndex or 0))
    print("StuckCount: " .. (d.stuckCount or 0))
    print("LastMoveDir: " .. tostring(d.lastMoveDir))
    
    if wps and d.wpIndex then
        local wp = wps[d.wpIndex]
        if wp then
            print("Target WP: " .. wp.x .. "," .. wp.y .. " (dist: " .. botDist(pos, wp) .. ")")
        end
        print("Total WPs: " .. #wps)
    else
        print("No waypoints")
    end
    print("======================")
end

-- ==========================================================
-- ADMIN COMMANDS
-- ==========================================================

function MOBA_BOTS.spawnTestBot(teamId, className)
    className = className or randomElement({"knight", "paladin", "sorcerer", "druid"})
    
    local cid = MOBA_BOTS.spawn(teamId, className)
    if cid then
        print("[MOBA_BOTS] Spawned " .. className .. " for team " .. teamId .. " (ID: " .. cid .. ")")
    else
        print("[MOBA_BOTS] Failed to spawn " .. className .. " for team " .. teamId)
    end
    
    return cid
end

function MOBA_BOTS.removeAllBots()
    local count = 0
    for cid, _ in pairs(MOBA_BOTS.Data) do
        local bot = Creature(cid)
        if bot then
            bot:remove()
            count = count + 1
        end
    end
    MOBA_BOTS.Data = {}
    print("[MOBA_BOTS] Removed " .. count .. " bots")
end

function MOBA_BOTS.healAllBots()
    for cid, data in pairs(MOBA_BOTS.Data) do
        local bot = Creature(cid)
        if bot then
            bot:addHealth(bot:getMaxHealth())
            print("[MOBA_BOTS] Healed bot " .. cid)
        end
    end
end

function MOBA_BOTS.giveGoldToAllBots(amount)
    amount = amount or 1000
    for cid, data in pairs(MOBA_BOTS.Data) do
        data.gold = (data.gold or 0) + amount
        print("[MOBA_BOTS] Gave " .. amount .. " gold to bot " .. cid .. " (Total: " .. data.gold .. ")")
    end
end

function MOBA_BOTS.levelUpAllBots(levels)
    levels = levels or 1
    for cid, data in pairs(MOBA_BOTS.Data) do
        local bot = Creature(cid)
        if bot and data.level < 25 then
            for i = 1, levels do
                if data.level >= 25 then break end
                data.level = data.level + 1
                local class = MOBA_BOTS.CLASSES[data.class]
                local newMax = class.hp + data.level * class.hpGain + (data.bonusHp or 0)
                bot:setMaxHealth(newMax)
                bot:addHealth(bot:getMaxHealth())
            end
            bot:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
            print("[MOBA_BOTS] Bot " .. cid .. " leveled up to " .. data.level)
        end
    end
end

function MOBA_BOTS.teleportBotToWaypoint(cid, wpIndex)
    local data = MOBA_BOTS.Data[cid]
    if not data then
        print("[MOBA_BOTS] Bot " .. cid .. " not found")
        return
    end
    
    local bot = Creature(cid)
    if not bot then
        print("[MOBA_BOTS] Creature " .. cid .. " not found")
        return
    end
    
    local wps = getWaypoints(data)
    if not wps or not wps[wpIndex] then
        print("[MOBA_BOTS] Invalid waypoint " .. wpIndex)
        return
    end
    
    local wp = wps[wpIndex]
    bot:teleportTo(Position(wp.x, wp.y, wp.z))
    data.wpIndex = wpIndex
    data.stuckCount = 0
    print("[MOBA_BOTS] Teleported bot " .. cid .. " to waypoint " .. wpIndex)
end

function MOBA_BOTS.setDebug(enabled)
    MOBA_BOTS.CONFIG.DEBUG_ENABLED = enabled
    MOBA_BOTS.CONFIG.DEBUG_MOVEMENT = enabled
    MOBA_BOTS.CONFIG.DEBUG_COMBAT = enabled
    MOBA_BOTS.CONFIG.DEBUG_DECISIONS = enabled
    print("[MOBA_BOTS] Debug mode: " .. (enabled and "ON" or "OFF"))
end

-- ==========================================================
-- INITIALIZATION
-- ==========================================================

print("[MOBA_BOTS v47] Sistema de bots carregado!")
print("[MOBA_BOTS] Estados: " .. #MOBA_BOTS.STATE_NAMES)
print("[MOBA_BOTS] Classes: knight, paladin, sorcerer, druid")
print("[MOBA_BOTS] Comandos: debugBot(id), debugAllBots(), debugEnvironment(id)")