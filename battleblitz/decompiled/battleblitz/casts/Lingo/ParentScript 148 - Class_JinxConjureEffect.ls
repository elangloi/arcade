property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.JINX.FX_JINX_ENERGYBALL_01, g.assets.JINX.FX_JINX_ENERGYBALL_02, g.assets.JINX.FX_JINX_ENERGYBALL_03, g.assets.JINX.FX_JINX_ENERGYBALL_04, g.assets.JINX.FX_JINX_ENERGYBALL_05, g.assets.JINX.FX_JINX_ENERGYBALL_06, g.assets.JINX.FX_JINX_ENERGYBALL_07, g.assets.JINX.FX_JINX_ENERGYBALL_08, g.assets.JINX.FX_JINX_ENERGYBALL_09, g.assets.JINX.FX_JINX_ENERGYBALL_10, g.assets.JINX.FX_JINX_ENERGYBALL_11]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
