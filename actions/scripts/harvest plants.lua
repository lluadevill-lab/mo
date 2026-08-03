local cfg = {
		soul = 0,
		level = 1
			}
local t = {
		[{4006}] = {fruit = 2675, NFTree = 4008, amount = 3, fName = "Orange"},
		[{5094}] = {fruit = 2676, NFTree = 5092, amount = 3, fName = "Banana"},
		[{5096}] = {fruit = 2678, NFTree = 2726, amount = 3, fName = "Coconut"},
		[{5157}] = {fruit = 5097, NFTree = 5156, amount = 3, fName = "Mango"}
		  }
function onUse(cid, item, frompos, item2, topos)
local S = getPlayerSoul(cid)
local L = getPlayerLevel(cid)
	for i, k in pairs(t) do
		if (isInArray(i, item.itemid) == true) and (S >= cfg.soul) and	(L >= cfg.level) then
			doTransformItem(item.uid, k.NFTree)
			doPlayerAddItem(cid, k.fruit, k.amount)
			doPlayerAddSoul(cid, -cfg.soul)
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You got some "..k.fName..".")
		elseif (S < cfg.soul) then
			doPlayerSendCancel(cid, "You do not have soul to harvest the plant.")
		elseif (L < cfg.level) then
			doPLayerSendCancel(cid, "You are not in the requiered level to harvest.")
		end
	end	
end