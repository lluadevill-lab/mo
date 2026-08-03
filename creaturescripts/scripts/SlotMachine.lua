local OPCODE_SLOT_MACHINE = 12
local COST = 100

function onExtendedOpcode(cid, opcode, buffer)
	if opcode ~= OPCODE_SLOT_MACHINE then
		return true
	end

	if getPlayerMoney(cid) < COST then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "Dinheiro insuficiente.")
		return true
	end

	doPlayerRemoveMoney(cid, COST)

	if buffer ~= 1 then
		doPlayerAddItem(cid, buffer, 1)
	end

	return true
end
