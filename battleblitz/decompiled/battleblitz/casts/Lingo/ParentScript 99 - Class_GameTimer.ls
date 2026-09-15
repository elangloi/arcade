property initTime, currTime, frames
global g

on new me, i
  initTime = i
  currTime = initTime
  frames = 0
  return me
end

on destroy me
  return VOID
end

on reset me, initTime
  currTime = initTime
  frames = 0
end

on update me
  frames = frames + 1
  currTime = initTime - (frames / g.FRAME_RATE)
  if currTime < 0 then
    currTime = 0
  end if
end

on getTime me
  return currTime
end
