property memList

on new me, names, srcCast
  memList = []
  repeat with i = 1 to names.count
    mem = member(names[i], srcCast)
    if mem.number > 0 then
      memList.append(mem)
      next repeat
    end if
    memList.append(member(0))
  end repeat
  return me
end

on destroy me
  return VOID
end

on getList me
  return memList
end
