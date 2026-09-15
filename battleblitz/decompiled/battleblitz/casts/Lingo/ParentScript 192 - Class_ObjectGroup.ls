property objList
global g

on new me
  objList = []
  return me
end

on destroy me
  return VOID
end

on addToGroup me, obj
  repeat with i = 1 to objList.count
    if objList[i] = obj then
      exit
    end if
  end repeat
  objList.append(obj)
end

on removeFromGroup me, obj
  repeat with i = 1 to objList.count
    if objList[i] = obj then
      objList.deleteAt(i)
      exit
    end if
  end repeat
end

on isInGroup me, obj
  repeat with i = 1 to objList.count
    if objList[i] = obj then
      return 1
    end if
  end repeat
  return 0
end

on getList me
  return objList
end

on reset me
  objList = []
end

on getIndex me, i
  return objList[i]
end

on getCount me
  return objList.count
end
