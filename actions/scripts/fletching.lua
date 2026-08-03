local cfg = {
	msgType = MESSAGE_INFO_DESCR,
	cancel = "Voce nao possui o nivel necessario."
}	
local t = {
	[{1, 200}] = {level = 1, item = 2389, name = "spear"},
	[{201, 300}] = {level = 1, item = 2544, name = "arrow"},
	[{301, 400}] = {level = 1, item = 2543, name = "bolt"},
	[{401, 500}] = {level = 1, item = 2547, name = "power bolt"},
	[{501, 1000}] = {level = 1, destroy = "Voce falhou em criar um item e a madeira quebrou."},
	[{1001, 1200}] = {level = 1, item = 7363, name = "piercing bolt"},
	[{1201, 1300}] = {level = 1, item = 7365, name = "onyx arrow"},
	[{1301, 1400}] = {level = 1, item = 7364, name = "sniper arrow"},
	[{1401, 1500}] = {level = 1, destroyknife = "Sua faca quebrou."}
}	

function onUse(cid, item, frompos, item2, item3, topos)
  if item2.itemid == 0 then
  return 0
  end
	if item2.itemid == 5901 then
		local r = math.random(1500), 1, nil	
		local level = getPlayerLevel(cid)
		for i, k in pairs(t) do
			if r >= i[1] and r <= i[2] then
				if level >= k.level then
					if k.item then
						doPlayerAddItem(cid, k.item, 1)
						doRemoveItem(item2.uid, 1)
						doPlayerSendTextMessage(cid, cfg.msgType, "Voce criou "..k.name..".")
					end
					if k.destroy then
						doRemoveItem(item2.uid, 1)
						doPlayerSendTextMessage(cid, cfg.msgType, k.destroy)
					end
					if k.destroyknife then
						doRemoveItem(item2.uid, 1)
						doRemoveItem(item.uid, 1)
						doPlayerSendTextMessage(cid, cfg.msgType, k.destroyknife)
					end	
				else
					doPlayerSendCancel(cid, cfg.cancel)
				end
			end
		end		
	else
	return 0
	end
return 1
end