property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.GIZMO.FX_EXPLODE_01, g.assets.GIZMO.FX_EXPLODE_02, g.assets.GIZMO.FX_EXPLODE_03, g.assets.GIZMO.FX_EXPLODE_04, g.assets.GIZMO.FX_EXPLODE_05, g.assets.GIZMO.FX_EXPLODE_06, g.assets.GIZMO.FX_EXPLODE_07, g.assets.GIZMO.FX_EXPLODE_08, g.assets.GIZMO.FX_EXPLODE_09, g.assets.GIZMO.FX_EXPLODE_10, g.assets.GIZMO.FX_EXPLODE_11, g.assets.GIZMO.FX_EXPLODE_12, g.assets.GIZMO.FX_EXPLODE_13]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
