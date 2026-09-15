property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_FIST_IN_06, g.assets.CHAR_SHARED.FX_FIST_IN_05, g.assets.CHAR_SHARED.FX_FIST_IN_04, g.assets.CHAR_SHARED.FX_FIST_IN_03, g.assets.CHAR_SHARED.FX_FIST_IN_02, g.assets.CHAR_SHARED.FX_FIST_IN_01]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
