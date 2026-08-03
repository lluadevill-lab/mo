-- Tabela para armazenar as escolhas do NPC atual
player_npc_choices = {}

function Player:createNpcModal(id, title, msg, choices)
    local window = ModalWindow(id, title, msg)
    window:addButton(100, "Select")
    window:addButton(101, "Close")
    window:setDefaultEnterButton(100)
    window:setDefaultEscapeButton(101)

    player_npc_choices[self:getId()] = choices

    for i = 1, #choices do
        window:addChoice(i, choices[i].text)
    end

    window:sendToPlayer(self)
end

function onModalWindow(player, modalId, buttonId, choiceId)
    -- Se apertar Close ou fechar no X
    if buttonId == 101 or buttonId == 255 then
        player:say("bye", TALKTYPE_SAY)
        return true
    end

    -- Se apertar Select
    if buttonId == 100 then
        local choices = player_npc_choices[player:getId()]
        if choices and choices[choiceId] then
            local msg = choices[choiceId].execute_say
            player:say(msg, TALKTYPE_SAY)
        end
    end
    return true
end