----------------Script Structure By Nirer/Kakashi~Sensei-----------------
  -------------Enhancements and configurablility by 375311-------------
    -----------Ask before you re-distribute to other sites-----------
local config = {
	grounds = {804},
	sMin = 0
	}
	--To add more plants to grow just copy this example:
	--[{XXXX}] = {NFTree = XXXX, bloomInSec = XX, t_DthInSec = XX, FTree = XXXX, tname = ""},--
	--Ref: NFTree = Non Fruit Tree, FTree = Fruit Tree, bloomInSec = time that it takes to bloom, t_DthInSec = time that it takes for plant to die,
	--tname = tree name and [{XXXX}] = Seed(fruit) itemid, all XXXX are itemids--
	--and paste it under:
local t = { --HERE--
		[{2675}] = {NFTree = 4008, bloomInSec = 20, t_DthInSec = 360000, FTree = 4006, tname = "orange tree"},
		[{2676}] = {NFTree = 5092, bloomInSec = 45, t_DthInSec = 360000, FTree = 5094, tname = "banana tree"},
		[{2678}] = {NFTree = 2726, bloomInSec = 70, t_DthInSec = 360000, FTree = 5096, tname = "coconut tree"},
		[{2677}] = {NFTree = 2786, bloomInSec = 20, t_DthInSec = 360000, FTree = 2785, tname = "blueberry bush"},
		[{5097}] = {NFTree = 5156, bloomInSec = 40, t_DthInSec = 360000, FTree = 5157, tname = "mango tree"}
		}
function onUse(cid, item, fromPosition, itemEx, toPosition) 
local soul = getPlayerSoul(cid)
		for i, k in pairs(t) do
				if (isInArray(i, itemEx.itemid) == true) and itemEx.type == 1 and (soul >= config.sMin) then 
local ground_position = {x = toPosition.x, y = toPosition.y, z = toPosition.z, stackpos = 0}
local ground_information = getThingfromPos(ground_position)
						if(isInArray(config.grounds, ground_information.itemid) == TRUE) then
							doPlayerAddSoul(cid, -config.sMin)
							doTransformItem(itemEx.uid, k.NFTree)
							doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Your "..k.tname.." has grown!")
							addEvent(Bloom, k.bloomInSec*1000, {position = toPosition, cid = cid, t_Dth = k.t_DthInSec})
                         
						else
							doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "This is not the proper ground for farming.")
						end	
				elseif(soul < config.sMin) then
					doPlayerSendCancel(cid, "You do not have enough soul to farm.")
				elseif(itemEx.type ~= 1) then
					doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You may only grow one plant at a time.")
				end		
		end
  return TRUE
end
function Bloom(parameter)
 
local tree = getThingfromPos{x = parameter.position.x, y = parameter.position.y, z = parameter.position.z, stackpos = 1}
	for i, k in pairs(t) do
		if (tree.itemid == k.NFTree) then
			doTransformItem(tree.uid, k.FTree)
			doPlayerSendTextMessage(parameter.cid, MESSAGE_INFO_DESCR, "Your "..k.tname.." has fully grown! Harvest it before it withers!")
			addEvent(t_Die, parameter.t_Dth*1000, {position = {x = parameter.position.x, y = parameter.position.y, z = parameter.position.z }, cid = parameter.cid})
		end
	end
end	
function t_Die(parameter)
local tree = getThingfromPos{x = parameter.position.x, y = parameter.position.y, z = parameter.position.z, stackpos = 1}
			doRemoveItem(tree.uid)
			doPlayerSendTextMessage(parameter.cid, MESSAGE_INFO_DESCR, "Your crop has withered.")
end