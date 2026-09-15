property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_STARFIRE_BOLT_03, g.assets.CHAR_SHARED.FX_STARFIRE_BOLT_04, g.assets.CHAR_SHARED.FX_STARFIRE_SWEEP_02]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
