property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CINDERBLOCK.FX_CINDERBLOCK_ENERGY_01, g.assets.CINDERBLOCK.FX_CINDERBLOCK_ENERGY_02, g.assets.CINDERBLOCK.FX_CINDERBLOCK_ENERGY_03, g.assets.CINDERBLOCK.FX_CINDERBLOCK_ENERGY_04, g.assets.CINDERBLOCK.FX_CINDERBLOCK_ENERGY_05, g.assets.CINDERBLOCK.FX_CINDERBLOCK_ENERGY_06, g.assets.CINDERBLOCK.FX_CINDERBLOCK_ENERGY_07, g.assets.CINDERBLOCK.FX_CINDERBLOCK_ENERGY_08]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.animation.setRepeat(2)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
