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
  me.repeatCount = me.repeatCount - 1
  if me.repeatCount = 0 then
    me.currIndex = me.currIndex + 1
    if me.currIndex > me.animList.count then
      me.reset()
    end if
    me.repeatCount = me.frameRepeat
  end if
end
