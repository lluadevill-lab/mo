function onUse(cid, item, fromPosition, itemEx, toPosition)
   if isInArray({0, 45535}, toPosition.x) then
       return doPlayerSendCancel(cid, "Sorry, not possible.")
   elseif getTileItemById(toPosition, 1428).uid == 0 then
       return doPlayerSendCancel(cid, "You must put your ingredients in the campfire.")
   end

   local obj = RecipeFromPosition(toPosition)
   if obj then
       obj:forge(cid, toPosition)
       if _FORGESYSTEM.useSkill == true then addForgeTry(cid) end
   else
       doPlayerSendCancel(cid, _FORGESYSTEM.prompt.invalidRecipe)
   end
   return true
end