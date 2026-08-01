-- Função auxiliar para colocar letras maiúsculas
local function capAll(str)
	return str:gsub("(%l)(%w*)", function(a, b)
		return a:upper() .. b:lower()
	end)
end

-- Janela Principal (Escolha de Vocação)
function Player:sendMainCraftWindow(config)
	local function buttonCallback(button, choice)
		if button.text == "Selecionar" then
			self:sendVocCraftWindow(config, choice.id)
		end
	end

	local window = ModalWindow {
		title = config.mainTitleMsg,
		message = config.mainMsg .. "\n\n"
	}

	window:addButton("Selecionar", buttonCallback)
	window:addButton("Sair")

	for i = 1, #config.system do
		window:addChoice(config.system[i].vocation)
	end

	window:setDefaultEnterButton("Selecionar")
	window:setDefaultEscapeButton("Sair")
	window:sendToPlayer(self)
end

-- Janela de Detalhes
function Player:sendDetailsWindow(config, lastChoice, itemIndex)
	local craftItem = config.system[lastChoice].items[itemIndex]
	
	if craftItem.header then 
		self:sendVocCraftWindow(config, lastChoice)
		return 
	end

	-- O preço é o 'count' do primeiro item requerido
	local price = craftItem.reqItems[1].count
	
	local text = "Item: " .. craftItem.item .. "\n"
	text = text .. "Preco: " .. price .. " Gold Coins\n"
	text = text .. "----------------\n"
	
	if craftItem.stats then
		text = text .. "Atributos:\n" .. craftItem.stats .. "\n"
	end

	local function buttonCallback(button)
		if button.text == "Voltar" then
			self:sendVocCraftWindow(config, lastChoice)
		end
	end

	local window = ModalWindow {
		title = "Detalhes",
		message = text
	}

	window:addButton("Voltar", buttonCallback)
	window:setDefaultEnterButton("Voltar")
	window:setDefaultEscapeButton("Voltar")
	window:sendToPlayer(self)
end

-- Janela da Loja Específica
function Player:sendVocCraftWindow(config, lastChoice)
	local function buttonCallback(button, choice)
		if button.text == "Voltar" then
			self:sendMainCraftWindow(config)
			return false
		end
		
		local selectedItem = config.system[lastChoice].items[choice.id]

		if selectedItem.header then
			self:sendVocCraftWindow(config, lastChoice)
			return true
		end

		if button.text == "Detalhes" then
			self:sendDetailsWindow(config, lastChoice, choice.id)
			return false
		end

		if button.text == "Comprar" then
			-- Pega o preço
			local price = selectedItem.reqItems[1].count

			-- Verifica se o player tem dinheiro (Total: Crystal + Platinum + Gold)
			if self:getMoney() < price then
				self:say(config.noMoneyMsg .. price .. " gp.", TALKTYPE_MONSTER_SAY)
				return true
			end

			-- Remove o dinheiro e dá o item
			if self:removeMoney(price) then
				local count = selectedItem.count or 1
				self:addItem(selectedItem.itemID, count)
				self:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
				self:sendTextMessage(MESSAGE_INFO_DESCR, "Voce comprou " .. count .. "x " .. selectedItem.item .. " por " .. price .. " gp.")
			else
				-- Caso raro onde getMoney diz que tem, mas removeMoney falha
				self:say("Erro ao processar transacao.", TALKTYPE_MONSTER_SAY)
			end
			
			-- Reabre a janela para comprar mais coisas
			self:sendVocCraftWindow(config, lastChoice)
			return true
		end
	end

	-- Pega o dinheiro total do jogador para exibir
	local playerMoney = self:getMoney()
	
	-- Substitui a tag {balance} pelo dinheiro atual
	local msg = config.craftMsg:gsub("{balance}", playerMoney)

	local window = ModalWindow {
		title = config.craftTitle .. config.system[lastChoice].vocation,
		message = msg
	}

	window:addButton("Voltar", buttonCallback)
	window:addButton("Sair")
	window:addButton("Detalhes", buttonCallback)
	window:addButton("Comprar", buttonCallback)

	window:setDefaultEnterButton("Comprar")
	window:setDefaultEscapeButton("Sair")

	for i = 1, #config.system[lastChoice].items do
		local item = config.system[lastChoice].items[i]
		
		if item.header then
			window:addChoice(item.item)
		else
			local price = item.reqItems[1].count
			window:addChoice(item.item .. " [" .. price .. " gp]")
		end
	end

	window:sendToPlayer(self)
end