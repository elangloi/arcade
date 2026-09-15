property ancestor, effect1, effect2
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_DustPuffEffect, owner, initPos, initVel, -initDir)
  effect1 = new(g.classes.Class_DustPuffEffect, owner, initPos, initVel, -initDir)
  effect2 = new(g.classes.Class_DustPuffEffect, owner, initPos, initVel, -initDir)
  me.setVel(point((random(150) / 10.0) - 2.0, (random(150) / 10.0) - 2.0))
  effect1.setVel(point((random(150) / 10.0) - 2.0, (random(150) / 10.0) - 2.0))
  effect2.setVel(point((random(150) / 10.0) - 2.0, (random(150) / 10.0) - 2.0))
  return me
end

on destroy me
  ancestor.destroy()
  effect1.destroy()
  effect2.destroy()
  return VOID
end

on update me
  ancestor.update()
  effect1.update()
  effect2.update()
end

on kill me
  ancestor.kill()
  effect1.kill()
  effect2.kill()
end

on paint me
  ancestor.paint()
  effect1.paint()
  effect2.paint()
end
