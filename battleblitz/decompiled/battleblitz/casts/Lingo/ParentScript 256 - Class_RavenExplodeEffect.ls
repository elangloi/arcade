property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  me.visSprite.blend = 100
  vis = [g.assets.RAVEN.FX_RAVEN_BOOM_01, g.assets.RAVEN.FX_RAVEN_BOOM_02, g.assets.RAVEN.FX_RAVEN_BOOM_03, g.assets.RAVEN.FX_RAVEN_BOOM_04, g.assets.RAVEN.FX_RAVEN_BOOM_05, g.assets.RAVEN.FX_RAVEN_BOOM_06, g.assets.RAVEN.FX_RAVEN_BOOM_07, g.assets.RAVEN.FX_RAVEN_BOOM_08, g.assets.RAVEN.FX_RAVEN_BOOM_09, g.assets.RAVEN.FX_RAVEN_BOOM_10, g.assets.RAVEN.FX_RAVEN_BOOM_11, g.assets.RAVEN.FX_RAVEN_BOOM_12]
  order = [1, 2, 3, 4, 4, 5, 6, 7, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
