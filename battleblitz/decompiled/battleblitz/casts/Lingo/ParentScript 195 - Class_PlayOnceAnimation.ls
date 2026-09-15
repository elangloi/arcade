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
  if not me.done then
    me.repeatCount = me.repeatCount - 1
    if me.repeatCount < 0 then
      me.repeatCount = 0
    end if
    if me.repeatCount = 0 then
      if me.currIndex = me.animList.count then
        me.done = 1
      else
        me.currIndex = me.currIndex + 1
        me.repeatCount = me.frameRepeat
      end if
    end if
  end if
end
