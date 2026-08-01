-- ============================================================================
-- CONFIGURAÇÃO DOS SONS GLOBAIS
-- ============================================================================
local SOUND_OPCODE = 51

local DISTANCE_SOUNDS = {
    [CONST_ANI_ARROW] = "arrow.ogg",
    [CONST_ANI_BOLT] = "bolt.ogg",
    [CONST_ANI_SPEAR] = "spear.ogg",
    [CONST_ANI_FIRE] = "fire_shoot.ogg",
    [CONST_ANI_ENERGY] = "energy_shoot.ogg",
    [CONST_ANI_ICE] = "ice_shoot.ogg",
    [CONST_ANI_SMALLSTONE] = "stone_throw.ogg",
    [CONST_ANI_SUDDENDEATH] = "sd_shoot.ogg",
    -- Adicione outros aqui
}

local EFFECT_SOUNDS = {
    [CONST_ME_FIREAREA] = "fire_area.ogg",
    [CONST_ME_ENERGYAREA] = "energy_area.ogg",
    [CONST_ME_EXPLOSIONAREA] = "explosion.ogg",
    [CONST_ME_BLOCKHIT] = "armor_clank.ogg",
    