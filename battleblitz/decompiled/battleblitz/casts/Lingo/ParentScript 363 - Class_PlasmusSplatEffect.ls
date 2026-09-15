property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.PLASMUS.FX_PLASMUS_BLOWUP_01, g.assets.PLASMUS.FX_PLASMUS_BLOWUP_02, g.assets.PLASMUS.FX_PLASMUS_BLOWUP_03, g.assets.PLASMUS.FX_PLASMUS_BLOWUP_04, g.assets.PLASMUS.FX_PLASMUS_BLOWUP_05, g.assets.PLASMUS.FX_PLASMUS_BLOWUP_06]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.animation.setRepeat(2)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
