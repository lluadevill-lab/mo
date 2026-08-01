-- 

function onThink(interval, lastExecution)
	local messages = {
	"Os Deuses estão vigiando... Comportem-se.",
	"*Trovão* A chuva está vindo e Thor bate seu martelo."
}

    Game.broadcastMessage(messages[math.random(#messages)], MESSAGE_EVENT_ADVANCE) 
    return true
end

