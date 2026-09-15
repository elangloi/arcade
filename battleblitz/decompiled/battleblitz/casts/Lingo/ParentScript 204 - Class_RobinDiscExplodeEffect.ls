property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_01, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_02, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_03, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_04, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_05, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_06, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_07, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_08, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_09, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_10, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_11, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_12, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_13, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_14, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_15, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_16, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_17, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_18, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_19, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_20, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_21, g.assets.ROBIN.FX_ROBIN_DISC_EXPLODE_22]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
