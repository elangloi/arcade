property ancestor, mirrorEffect
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_DustJumpEffect, owner, initPos, initVel, -initDir)
  mirrorEffect = new(g.classes.Class_DustJumpEffect, owner, initPos, initVel, initDir)
  me.moveBy(100.0 * initDir, 0.0)
  mirrorEffect.moveBy(-100.0 * initDir, 0.0)
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
