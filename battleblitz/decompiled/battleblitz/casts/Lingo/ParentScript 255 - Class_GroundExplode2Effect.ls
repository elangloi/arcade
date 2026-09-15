property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_01, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_02, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_03, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_04, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_05, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_06, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_07, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_08, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_09, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_02_10]
  order = [1, 2, 3, 4, 4, 5, 6, 7, 7, 7, 8, 8, 9, 9, 10, 10]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
