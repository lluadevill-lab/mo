local cfg = {
		level = 15,
		soul = 4,
		Mon = "Rat",
		Lx = "You do not meet the level required to plow the land.",
		Sx = "You do not have enough soul to plow the land.",
		soil = 103
		}
function onUse(cid, item, fromposition, item2, toposition)
local R = math.random(1,500)
local S = getPlayerSoul(cid)
local L = getPlayerLevel(cid)
	if (L >= cfg.level) and (S >= cfg.soul) and (item2.itemid == cfg.soil) then
		if R <= 100 then
			doSummonCreature(cfg.Mon, toposition)
			doPlayerAddSoul(cid, -cfg.soul)
			doTransformItem(item2.uid, 804)
			doDecayItem(item2.uid)
		
		elseif R <= 200 then
			doPlayerAddItem(cid, 3976, 3)
			doPlayerAddSoul(cid, -cfg.soul)
			doTransformItem(item2.uid, 804)
			doDecayItem(item2.uid)
			
		elseif R <= 500 then
			doTransformItem(item2.uid, 804)
			doDecayItem(item2.uid)
			doPlayerAddSoul(cid, -cfg.soul)
		end
	elseif(L < cfg.level) then
		doPlayerSendCancel(cid, cfg.Lx)
	elseif(S < cfg.soul) then
		doPlayerSendCancel(cid, cfg.Sx)
	
	end
  return true
end