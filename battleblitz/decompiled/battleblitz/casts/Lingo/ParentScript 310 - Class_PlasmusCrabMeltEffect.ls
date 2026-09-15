property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.PLASMUS.PLASMUS_CRAB_MELT_01, g.assets.PLASMUS.PLASMUS_CRAB_MELT_02, g.assets.PLASMUS.PLASMUS_CRAB_MELT_03, g.assets.PLASMUS.PLASMUS_CRAB_MELT_04, g.assets.PLASMUS.PLASMUS_CRAB_MELT_05, g.assets.PLASMUS.PLASMUS_CRAB_MELT_06, g.assets.PLASMUS.PLASMUS_CRAB_MELT_07, g.assets.PLASMUS.PLASMUS_CRAB_MELT_08, g.assets.PLASMUS.PLASMUS_CRAB_MELT_09, g.assets.PLASMUS.PLASMUS_CRAB_MELT_10, g.assets.PLASMUS.PLASMUS_CRAB_MELT_11, g.assets.PLASMUS.PLASMUS_CRAB_MELT_12, g.assets.PLASMUS.PLASMUS_CRAB_MELT_13]
  order = [1, 1, 1, 2, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  return me
end
