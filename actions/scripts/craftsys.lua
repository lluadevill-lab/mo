function onUse(player, item, fromPosition, itemEx, toPosition)
   local found = 0
   local recipes = craftingProfessionsConfig[item.actionid].skillRecipes
   local modal = ModalWindow(item.actionid, ""..craftingProfessionsConfig[item.actionid].skillName.." (Crafting Skill: "..player:getCustomSkill(item.actionid).."/"..craftingProfessionsConfig.maxSkill..")", craftingProfessionsConfig[item.actionid].message)

   if item.itemid == 8046 and isInArray({50501, 50502, 50503, 50504, 50505, 50506}, item.actionid) then
     if getCreatureCondition(player, CONDITION_SPELLCOOLDOWN, 160) then --I don't really know how to use :getCreatureCondition, it never works for me.
       return player:sendCancelMessage("You are already crafting.")
     end

     if not player:isProfession(item.actionid) then
       return player:sendCancelMessage("You need to learn "..craftingProfessionsConfig[item.actionid].skillName.." before using this.")
     end

     for i = 1, #recipes do
       if player:getStorageValue(craftingProfessionsConfig.baseRecipeStorage + recipes[i].storage) == 1 then
         modal:addChoice(i, capAll(getItemName(recipes[i].item))--[[.." ["..recipes[i].skill.."]"]])
       end
     end

     craftingProfessionsConfig.extraData[player:getId()] = {
       lastPos = Item(item.uid):getPosition()
     }

     if modal:getChoiceCount() ~= 0 then
       modal:addButton(1, "Create")
       modal:setDefaultEnterButton(1)
       modal:addButton(2, "Exit")
       modal:setDefaultEscapeButton(2)
       modal:addButton(3, "Materials")
       modal:sendToPlayer(player)
     else
       player:sendCancelMessage("You need to learn some "..craftingProfessionsConfig[item.actionid].skillName.." recipes first.")
     end
   elseif item.itemid == 1967 and item.actionid >= craftingProfessionsConfig.baseRecipeStorage then
     for i = 1, #recipes do
       if recipes[i].storage == tonumber(Item(item.uid):getAttribute(ITEM_ATTRIBUTE_TEXT)) then
         found = i
       end
     end
     if found == 0 then return player:sendCancelMessage(RETURNVALUE_CANNOTUSETHISOBJECT) end
     if player:getStorageValue(craftingProfessionsConfig.baseRecipeStorage + recipes[found].storage) == -1 then
       if player:getCustomSkill(item.actionid) >= recipes[found].skill then
         player:setStorageValue(craftingProfessionsConfig.baseRecipeStorage + recipes[found].storage, 1)
         player:sendTextMessage(MESSAGE_EVENT_DEFAULT, "You learned how to make "..capAll(getItemName(recipes[found].item))..".")
         player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
         Item(item.uid):remove(1)
       else
         player:sendCancelMessage("You require "..recipes[found].skill.." crafting skill in "..craftingProfessionsConfig[item.actionid].skillName.." to learn this recipe.")
       end
     else
       player:sendCancelMessage("You have already learned this recipe.")
     end
   elseif item.itemid == 2217 and item.actionid >= craftingProfessionsConfig.baseRecipeStorage then
     if player:getStorageValue(item.actionid) == -1 then
       player:sendTextMessage(MESSAGE_EVENT_DEFAULT, "You have learned "..craftingProfessionsConfig[item.actionid].skillName..", then the book burned to ashes after learning it's secrets.")
       player:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONHIT)
       player:setStorageValue(item.actionid, 10)
       Item(item.uid):remove(1)
     else
       player:sendCancelMessage("You already know "..craftingProfessionsConfig[item.actionid].skillName..".")
     end
   end
   return true
end