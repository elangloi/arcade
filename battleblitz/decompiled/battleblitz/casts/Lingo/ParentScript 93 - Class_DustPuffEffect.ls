property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, -initDir)
  vis = [g.assets.CHAR_SHARED.FX_PUFF_01, g.assets.CHAR_SHARED.FX_PUFF_02, g.assets.CHAR_SHARED.FX_PUFF_03, g.assets.CHAR_SHARED.FX_PUFF_04, g.assets.CHAR_SHARED.FX_PUFF_05, g.assets.CHAR_SHARED.FX_PUFF_06]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
