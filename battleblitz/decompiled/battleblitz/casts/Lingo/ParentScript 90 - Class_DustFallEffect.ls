property ancestor, mirrorEffect
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_DustSkidEffect, owner, initPos, initVel, initDir)
  mirrorEffect = new(g.classes.Class_DustSkidEffect, owner, initPos, initVel, -initDir)
  return me
end

on destroy me
  ancestor.destroy()
  mirrorEffect.destroy()
  return VOID
end

on update me
  ancestor.update()
  mirrorEffect.update()
end

on kill me
  ancestor.kill()
  mirrorEffect.kill()
end

on paint me
  ancestor.paint()
  mirrorEffect.paint()
end
