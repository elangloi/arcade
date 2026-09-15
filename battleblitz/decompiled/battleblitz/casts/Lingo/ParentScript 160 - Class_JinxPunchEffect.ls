property ancestor, wave2effect, wave3effect
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_JinxFistEffect, owner, initPos, initVel, initDir)
  wave2effect = new(g.classes.Class_JinxFistEffect, owner, initPos, initVel, initDir)
  wave3effect = new(g.classes.Class_JinxFistEffect, owner, initPos, initVel, initDir)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on update me
  ancestor.update()
  if me.age >= 3 then
    wave2effect.update()
  end if
  if me.age >= 5 then
    wave3effect.update()
  end if
end

on paint me
  ancestor.paint()
  if me.age >= 3 then
    wave2effect.paint()
  end if
  if me.age >= 5 then
    wave3effect.paint()
  end if
end

on isAlive me
  return wave3effect.isAlive()
end
