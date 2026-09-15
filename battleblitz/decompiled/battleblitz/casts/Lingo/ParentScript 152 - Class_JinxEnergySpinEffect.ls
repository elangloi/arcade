property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.JINX.FX_JINX_TWIRL_06, g.assets.JINX.FX_JINX_TWIRL_07, g.assets.JINX.FX_JINX_TWIRL_08, g.assets.JINX.FX_JINX_TWIRL_09, g.assets.JINX.FX_JINX_TWIRL_10, g.assets.JINX.FX_JINX_TWIRL_11, g.assets.JINX.FX_JINX_TWIRL_12, g.assets.JINX.FX_JINX_TWIRL_13, g.assets.JINX.FX_JINX_TWIRL_14, g.assets.JINX.FX_JINX_TWIRL_15, g.assets.JINX.FX_JINX_TWIRL_16, g.assets.JINX.FX_JINX_TWIRL_17, g.assets.JINX.FX_JINX_TWIRL_18, g.assets.JINX.FX_JINX_TWIRL_19]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
