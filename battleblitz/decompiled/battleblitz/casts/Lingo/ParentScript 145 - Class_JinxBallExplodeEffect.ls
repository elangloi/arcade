property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.JINX.FX_JINX_ENERGYBALL_14, g.assets.JINX.FX_JINX_ENERGYBALL_15, g.assets.JINX.FX_JINX_ENERGYBALL_16, g.assets.JINX.FX_JINX_ENERGYBALL_17, g.assets.JINX.FX_JINX_ENERGYBALL_18, g.assets.JINX.FX_JINX_ENERGYBALL_19, g.assets.JINX.FX_JINX_ENERGYBALL_20, g.assets.JINX.FX_JINX_ENERGYBALL_21, g.assets.JINX.FX_JINX_ENERGYBALL_22, g.assets.JINX.FX_JINX_ENERGYBALL_23, g.assets.JINX.FX_JINX_ENERGYBALL_24, g.assets.JINX.FX_JINX_ENERGYBALL_25, g.assets.JINX.FX_JINX_ENERGYBALL_26, g.assets.JINX.FX_JINX_ENERGYBALL_27, g.assets.JINX.FX_JINX_ENERGYBALL_28, g.assets.JINX.FX_JINX_ENERGYBALL_29, g.assets.JINX.FX_JINX_ENERGYBALL_30, g.assets.JINX.FX_JINX_ENERGYBALL_31, g.assets.JINX.FX_JINX_ENERGYBALL_32, g.assets.JINX.FX_JINX_ENERGYBALL_33, g.assets.JINX.FX_JINX_ENERGYBALL_34, g.assets.JINX.FX_JINX_ENERGYBALL_35]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.animation.setRepeat(2)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
