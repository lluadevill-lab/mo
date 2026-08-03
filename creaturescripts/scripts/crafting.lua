function onModalWindow(player, modalWindowId, buttonId, choiceId)
   if not isInArray({50501, 50502, 50503, 50504, 50505, 50506}, modalWindowId) or buttonId == 2 then
     return false
   end
   local count = 0
   local recipes = craftingProfessionsConfig[modalWindowId].skillRecipes
   local str = ""..capAll(getItemName(recipes[choiceId].item)).."\n  Skill Needed: "..recipes[choiceId].skill.." - Point Cost: 1p\n\nMaterials:"
   if buttonId == 3 then
     for i = 1, #recipes[choiceId].mats do
       str = str.."\n- "..capAll(getItemName(recipes[choiceId].mats[i][1])).." ("..player:getItemCount(recipes[choiceId].mats[i][1]).."/"..recipes[choiceId].mats[i][2]..")"
     end
     if str ~= "" then
       player:showTextDialog(recipes[choiceId].item, str)
     end
     return true
   end
   for i = 1, #recipes[choiceId].mats do
     if player:getItemCount(recipes[choiceId].mats[i][1]) >= recipes[choiceId].mats[i][2] then
       count = count + 1
     end
   end
   if count == #recipes[choiceId].mats then
     local craftCD = Condition(CONDITION_SPELLCOOLDOWN)
     craftCD:setParameter(COMBAT_PARAM_AGGRESSIVE, 0)
     craftCD:setParameter(CONDITION_PARAM_SUBID, 160)
     craftCD:setParameter(CONDITION_PARAM_TICKS, recipes[choiceId].time * 1000)
     player:addCondition(craftCD)
     player:allowMovement(false)
     player:say("Crafting...", TALKTYPE_MONSTER_SAY)
     local itemPos = craftingProfessionsConfig.extraData[player:getId()].lastPos
     function sendAnimation(times) --This needs to be improved
       itemPos:sendMagicEffect(CONST_ME_BLOCKHIT)
       if times == 0 then
         return true
       end
       addEvent(sendAnimation, 1000, times - 1)
     end
     sendAnimation(recipes[choiceId].time)
     for i = 1, count do
       player:removeItem(recipes[choiceId].mats[i][1], recipes[choiceId].mats[i][2])
     end
     addEvent(function(id)
       local player = Player(id)
       if player then
         local craftedItem = player:addItem(recipes[choiceId].item, 1)
         if craftedItem then
           player:sendTextMessage(MESSAGE_EVENT_DEFAULT, "You've successfully crafted "..craftedItem:getArticle().." "..capAll(craftedItem:getName())..".")
           craftedItem:setAttribute(ITEM_ATTRIBUTE_NAME, "crafted "..craftedItem:getName())
           player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_RED)
           --doWriteLogFile("data/logs/craf.log", player:getName() .." crafted the following item: ".. craftedItem:getName() .." [".. craftedItem:getId() .."].")
           if craftedItem:getType():getDescription() ~= "" then
             craftedItem:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, craftedItem:getType():getDescription().."\nCrafted by "..player:getName()..".")
           else
             craftedItem:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Crafted by "..player:getName()..".")
           end
           if craftedItem:getType():getAttack() > 0 and recipes[choiceId].attr ~= nil and recipes[choiceId].attr.attack ~= nil then
             craftedItem:setAttribute(ITEM_ATTRIBUTE_ATTACK, craftedItem:getType():getAttack() + recipes[choiceId].attr.attack)
           end
           if craftedItem:getType():getDefense() > 0 and recipes[choiceId].attr ~= nil and recipes[choiceId].attr.defense ~= nil then
             craftedItem:setAttribute(ITEM_ATTRIBUTE_DEFENSE, craftedItem:getType():getDefense() + recipes[choiceId].attr.defense)
           end
           if craftedItem:getType():getExtraDefense() > 0 and recipes[choiceId].attr ~= nil and recipes[choiceId].attr.extradefense ~= nil then
             craftedItem:setAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE, craftedItem:getType():getExtraDefense() + recipes[choiceId].attr.extradefense)
           end
           if craftedItem:getType():getArmor() > 0 and recipes[choiceId].attr ~= nil and recipes[choiceId].attr.armor ~= nil then
             craftedItem:setAttribute(ITEM_ATTRIBUTE_ARMOR, craftedItem:getType():getArmor() + recipes[choiceId].attr.armor)
           end
           if craftedItem:getType():getHitChance() > 0 and recipes[choiceId].attr ~= nil and recipes[choiceId].attr.hitchance ~= nil then
             craftedItem:setAttribute(ITEM_ATTRIBUTE_HITCHANCE, craftedItem:getType():getHitChance() + recipes[choiceId].attr.hitchance)
           end
           if craftedItem:getType():getShootRange() > 0 and recipes[choiceId].attr ~= nil and recipes[choiceId].attr.shootrange ~= nil then
             craftedItem:setAttribute(ITEM_ATTRIBUTE_SHOOTRANGE, craftedItem:getType():getShootRange() + recipes[choiceId].attr.shootrange)
           end
         end
         skillGain = (recipes[choiceId].difficulty / 10)
         for i = 1, skillGain do
           player:addCustomSkillTry(craftingProfessionsConfig[modalWindowId].skillName, modalWindowId)
         end
         player:allowMovement(true)
       end
     end, recipes[choiceId].time * 1000, player:getId())
   else
     player:sendCancelMessage("You don't have all the materials to craft this item.")
   end
   return true
end