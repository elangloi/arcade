property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_CYBORG_LINES_01, g.assets.CHAR_SHARED.FX_CYBORG_LINES_02, g.assets.CHAR_SHARED.FX_CYBORG_LINES_03, g.assets.CHAR_SHARED.FX_CYBORG_LINES_04, g.assets.CHAR_SHARED.FX_CYBORG_LINES_05]
  order = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.getSprite().locZ = g.SPRITE_LOCZ_EFFECTS_BACKGROUND
  return me
end
