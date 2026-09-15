on new me
  return me
end

on destroy me
  return VOID
end

on newArray me, size, val
  l = []
  repeat with i = 1 to size
    l.append(val)
  end repeat
  return l
end

on findMember me, memName, memCast
  mem = member(memName, memCast)
  if mem.number > 0 then
    return mem
  else
    return member(0)
  end if
end

on toUpper me, s
  repeat with i = 1 to s.length
    c = charToNum(s.char[i])
    if (c >= 97) and (c <= 122) then
      put numToChar(c - 32) into char i of s
    end if
  end repeat
  return s
end

on isLetter me, c
  i = charToNum(c)
  return ((i >= 97) and (i <= 122)) or ((i >= 65) and (i <= 90))
end

on ceiling me, f
  i = integer(f)
  if float(i) = f then
    return i
  else
    if f > 0.0 then
      return integer(f + 0.5)
    else
      if f < 0.0 then
        return integer(f - 0.5)
      else
        return 0
      end if
    end if
  end if
end

on sameSigns me, i1, i2
  if (i1 < 0) and (i2 < 0) then
    return 1
  else
    if (i1 > 0) and (i2 > 0) then
      return 1
    else
      return 0
    end if
  end if
end

on getLineIntersection me, x1, y1, x2, y2, x3, y3, x4, y4, retList
  Ax = x2 - x1
  Bx = x3 - x4
  if Ax < 0 then
    x1lo = x2
    x1hi = x1
  else
    x1lo = x1
    x1hi = x2
  end if
  if Bx > 0 then
    if (x1hi < x4) or (x3 < x1lo) then
      return 0
    end if
  else
    if (x1hi < x3) or (x4 < x1lo) then
      return 0
    end if
  end if
  Ay = y2 - y1
  By = y3 - y4
  if Ay < 0 then
    y1lo = y2
    y1hi = y1
  else
    y1hi = y2
    y1lo = y1
  end if
  if By > 0 then
    if (y1hi < y4) or (y3 < y1lo) then
      return 0
    end if
  else
    if (y1hi < y3) or (y4 < y1lo) then
      return 0
    end if
  end if
  Cx = x1 - x3
  Cy = y1 - y3
  d = (By * Cx) - (Bx * Cy)
  f = (Ay * Bx) - (Ax * By)
  if f > 0 then
    if (d < 0) or (d > f) then
      return 0
    end if
  else
    if (d > 0) or (d < f) then
      return 0
    end if
  end if
  e = (Ax * Cy) - (Ay * Cx)
  if f > 0 then
    if (e < 0) or (e > f) then
      return 0
    end if
  else
    if (e > 0) or (e < f) then
      return 0
    end if
  end if
  if f = 0 then
    return 0
  end if
  retList[1] = x1 + (d * Ax / f)
  retList[2] = y1 + (d * Ay / f)
  return 1
end
