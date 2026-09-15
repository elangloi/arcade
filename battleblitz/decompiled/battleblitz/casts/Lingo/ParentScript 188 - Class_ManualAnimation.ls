property ancestor
global g

on new me, memList
  ancestor = new(g.classes.Class_Animation, memList)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on advance me
  nothing()
end

on setIndex me, i
  if i > me.animList.count then
    me.currIndex = i
  end if
end

on getIndex me
  return me.currIndex
end
