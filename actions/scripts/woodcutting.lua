local config = {
	trees = {2701,2702,2703,2704,2705,2706,2707,2708,2709,2710,2712,2717,2718,2720,2722},
	t = {
		[{1, 100}] = {tree = 2701},
		[{101, 200}] = {tree = 2702},
		[{201, 300}] = {tree = 2703},
		[{301, 400}] = {tree = 2704},
		[{401, 500}] = {tree = 2705},
		[{501, 600}] = {tree = 2706},
		[{601, 700}] = {tree = 2707},
		[{701, 800}] = {tree = 2708},
		[{801, 900}] = {tree = 2709},
		[{901, 1000}] = {tree = 2710},
		[{1001, 1100}] = {tree = 2712},
		[{1101, 1200}] = {tree = 2717},
		[{1201, 1300}] = {tree = 2718},
		[{1301, 1400}] = {tree = 2720},
		[{1401, 1500}] = {tree = 2722}
		},
	level = 15,
	skill = SKILL_AXE,
	skillReq = 10,
	effect = CONST_ME_BLOCKHIT,
	addTries = 100,
	branches = 6432,
	msgType = MESSAGE_EVENT_ADVANCE,
	soul = 3,
	minutes = 5
}

local t = {
	[{1, 500}] = {msg = "You choped the tree and got some wood", item = 5901, amountmax = 3},
	[{501, 750}] = {msg = "You have damaged your axe and it broke!", destroy = true},
	[{751, 1550}] = {msg = "You choped the tree down, but the the wood was not good."},
	[{1551, 1650}] = {msg = "oh no the tree had a Wasps nest in it!", summon = "Wasp"},
	[{1651, 1750}] = {msg = "You hurt your self while choping the tree down", damage = {1, 100}},
	[{1751, 2000}] = {msg = "You choped the tree and got some wood", item = 5901, amountmax = 5},
	[{2001, 2250}] = {msg = "A cat that was stuck jumped from the choped tree", summon = "Cat"},
	[{2251, 2500}] = {msg = "There was a bird's nest in the tree and you took some eggs from the nest", item = 2695, amountmax = 5},
	[{2501, 2750}] = {msg = "Hahaa! You found a sack with coins in it!", item = 2148, amountmax = 50},
	[{2751, 3000}] = {msg = "A rat jumped at you!", summon = "Rat"}
	}

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if isInArray(config.trees, itemEx.itemid) and config.level <= getPlayerLevel(cid) and config.skillReq <= getPlayerSkill(cid, config.skill) and config.soul <= getPlayerSoul(cid) then
		local v, amount, damage = math.random(3000), 1, nil
		for i, k in pairs(t) do
			if v >= i[1] and v <= i[2] then
				if k.destroy then
					doRemoveItem(item.uid)
				end
				if k.summon then
					doCreateMonster(k.summon, toPosition)
				end
				if k.damage then
					damage = math.random(k.damage[1], k.damage[2])
					doCreatureAddHealth(cid, - damage)
					doSendMagicEffect(getThingPos(cid), CONST_ME_DRAWBLOOD)
					doSendAnimatedText(getThingPos(cid), damage, TEXTCOLOR_RED)

				end
				if k.item then
					if k.amountmax then
						amount = math.random(k.amountmax)
					end
					doPlayerAddItem(cid, k.item, amount)
				end
				if k.msg then
					local msg = k.msg
					doPlayerSendTextMessage(cid, config.msgType, msg)
				end
				
				local function newTrees(parameter)
					local tree = getThingfromPos{x = parameter.position.x, y = parameter.position.y, z = parameter.position.z, stackpos = 1}
					for i2, k2 in pairs(config.t) do
						local v2 = math.random(1500), 1, nil
						if v2 >= i2[1] and v2 <= i2[2] then
							if k2.tree then
								if (tree.itemid == config.branches) then
									doTransformItem(tree.uid, k2.tree)
								end
							end
						end		
					end
				end	
				addEvent(newTrees, config.minutes*60*1000, {position = toPosition, cid = cid})	
				doTransformItem(itemEx.uid, config.branches)
				doPlayerAddSoul(cid, -config.soul)
				doSendMagicEffect(toPosition, k.destroy and CONST_ME_HITAREA or config.effect)	
				return doPlayerAddSkillTry(cid, config.skill, config.addTries)
			end
		end

  end	
	return doPlayerSendCancel(cid, "Either this tree can't be choped or you don't have enough experience, skill or soul to chop this tree.")
end