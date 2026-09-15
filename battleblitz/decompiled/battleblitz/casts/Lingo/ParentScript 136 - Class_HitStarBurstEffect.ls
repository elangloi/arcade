property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_HIT_02_01, g.assets.CHAR_SHARED.FX_HIT_02_02, g.assets.CHAR_SHARED.FX_HIT_02_03]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
