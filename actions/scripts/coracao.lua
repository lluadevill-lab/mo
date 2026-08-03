function onUse(player, item, fromPosition, itemEx, toPosition, isHotkey)
  local hunger = player:getStorageValue(50000)
  local thirst = player:getStorageValue(50001)
  local fatigue = player:getStorageValue(50002)
  local oxygen = player:getStorageValue(50009) -- NOVO
  local temperature = player:getStorageValue(50010) -- NOVO

  if hunger < 0 then hunger = 100 end
  if thirst < 0 then thirst = 100 end
  if fatigue < 0 then fatigue = 100 end
  if oxygen < 0 then oxygen = 100 end -- NOVO
  if temperature < 0 then temperature = 50 end -- NOVO
    
  player:sendTextMessage(MESSAGE_INFO_DESCR,
    string.format("Fome: %d%%\nSede: %d%%\nFadiga: %d%%\nOxigenio: %d%%\nTemperatura: %d", 
    hunger, thirst, fatigue, oxygen, temperature))
    return true
end