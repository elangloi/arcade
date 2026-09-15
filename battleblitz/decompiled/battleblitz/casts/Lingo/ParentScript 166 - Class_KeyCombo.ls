property COMBO_KEYDOWN_INTERVAL_MIN, COMBO_KEYDOWN_INTERVAL_MAX, combo, index

on new me, keyList
  COMBO_KEYDOWN_INTERVAL_MIN = 10
  COMBO_KEYDOWN_INTERVAL_MAX = 250
  combo = keyList
  index = 1
  return me
end

on destroy me
  return VOID
end

on reset me
  index = 1
end

on checkKey me, comboKey, time
  if voidp(time) then
    time = COMBO_KEYDOWN_INTERVAL_MAX
  end if
  acceptKey = 0
  if index > combo.count then
    index = 1
  end if
  if comboKey = combo[index] then
    if index = 1 then
      acceptKey = 1
    else
      if (time <= COMBO_KEYDOWN_INTERVAL_MAX) and (time >= COMBO_KEYDOWN_INTERVAL_MIN) then
        acceptKey = 1
      end if
    end if
  end if
  if acceptKey then
    if index = combo.count then
      index = 1
      return 1
    else
      index = index + 1
    end if
  else
    index = 1
  end if
  return 0
end
