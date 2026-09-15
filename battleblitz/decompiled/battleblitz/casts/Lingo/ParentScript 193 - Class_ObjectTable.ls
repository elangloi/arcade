property table

on new me
  table = [:]
  return me
end

on reset me
  table = [:]
end

on addObject me, o
  if voidp(table.getaProp(o)) then
    table.addProp(o, 1)
  else
    table[o] = table[o] + 1
  end if
end

on hasObject me, o
  return not voidp(table.getaProp(o))
end
