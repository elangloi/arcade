property animList, currIndex, repeatCount, frameRepeat, done

on new me, memList
  if listp(memList) then
    animList = memList
  else
    animList = []
  end if
  currIndex = 1
  frameRepeat = 1
  repeatCount = frameRepeat
  done = 0
  return me
end

on destroy me
  return VOID
end

on setRepeat me, i
  frameRepeat = i
  repeatCount = i
end

on setMembers me, l
  if listp(l) then
    animList = l
    reset()
  end if
end

on reset me
  currIndex = 1
  done = 0
end

on advance me
  nothing()
end

on getMember me
  if animList.count = 0 then
    return member(0)
  else
    return animList[currIndex]
  end if
end

on isDone me
  return done
end
