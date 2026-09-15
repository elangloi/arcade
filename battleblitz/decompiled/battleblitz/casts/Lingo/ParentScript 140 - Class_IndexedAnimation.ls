property ancestor, order, orderIndex
global g

on new me, memList, orderList
  ancestor = new(g.classes.Class_Animation, memList)
  order = orderList
  orderIndex = 1
  me.currIndex = order[orderIndex]
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
      if orderIndex = order.count then
        me.done = 1
      else
        orderIndex = orderIndex + 1
        me.currIndex = order[orderIndex]
        me.repeatCount = me.frameRepeat
      end if
    end if
  end if
end

on reset me
  ancestor.reset()
  orderIndex = 1
  me.currIndex = order[orderIndex]
end
