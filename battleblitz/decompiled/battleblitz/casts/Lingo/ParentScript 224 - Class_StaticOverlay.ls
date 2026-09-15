property ancestor
global g

on new me, initMember, initPos, initLocZ
  ancestor = new(g.classes.Class_Overlay, initPos, initLocZ)
  me.setMember(initMember)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on update me
end
