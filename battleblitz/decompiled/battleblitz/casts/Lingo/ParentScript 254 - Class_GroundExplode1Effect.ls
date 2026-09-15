property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_01, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_02, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_03, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_04, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_05, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_06, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_07, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_08, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_09, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_10, g.assets.CHAR_SHARED.FX_GROUND_EXPLODE_01_11]
  order = [1, 2, 3, 4, 4, 5, 6, 7, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
