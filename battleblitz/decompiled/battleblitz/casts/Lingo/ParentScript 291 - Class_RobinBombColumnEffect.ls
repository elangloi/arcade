property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.ROBIN.FX_ROBIN_COLUMN_01, g.assets.ROBIN.FX_ROBIN_COLUMN_02, g.assets.ROBIN.FX_ROBIN_COLUMN_03, g.assets.ROBIN.FX_ROBIN_COLUMN_04, g.assets.ROBIN.FX_ROBIN_COLUMN_05, g.assets.ROBIN.FX_ROBIN_COLUMN_06]
  order = [1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 5, 5, 6, 6]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.visSprite.locZ = g.SPRITE_LOCZ_EFFECTS_BACKGROUND
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
