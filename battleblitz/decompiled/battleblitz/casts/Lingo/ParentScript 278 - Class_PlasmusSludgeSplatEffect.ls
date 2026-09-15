property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.PLASMUS.PLASMUS_SLUDGE_01, g.assets.PLASMUS.PLASMUS_SLUDGE_02, g.assets.PLASMUS.PLASMUS_SLUDGE_03, g.assets.PLASMUS.PLASMUS_SLUDGE_04, g.assets.PLASMUS.PLASMUS_SLUDGE_05, g.assets.PLASMUS.PLASMUS_SLUDGE_06, g.assets.PLASMUS.PLASMUS_SLUDGE_07, g.assets.PLASMUS.PLASMUS_SLUDGE_08, g.assets.PLASMUS.PLASMUS_SLUDGE_09, g.assets.PLASMUS.PLASMUS_SLUDGE_10, g.assets.PLASMUS.PLASMUS_SLUDGE_11, g.assets.PLASMUS.PLASMUS_SLUDGE_12, g.assets.PLASMUS.PLASMUS_SLUDGE_13, g.assets.PLASMUS.PLASMUS_SLUDGE_14, g.assets.PLASMUS.PLASMUS_SLUDGE_15, g.assets.PLASMUS.PLASMUS_SLUDGE_16]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
