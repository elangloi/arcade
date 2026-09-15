property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.GIZMO.GIZMO_MISSILE01_00, g.assets.GIZMO.GIZMO_MISSILE01_01, g.assets.GIZMO.GIZMO_MISSILE01_02, g.assets.GIZMO.GIZMO_MISSILE01_03, g.assets.GIZMO.GIZMO_MISSILE01_04, g.assets.GIZMO.GIZMO_MISSILE01_05, g.assets.GIZMO.GIZMO_MISSILE01_06, g.assets.GIZMO.GIZMO_MISSILE01_07, g.assets.GIZMO.GIZMO_MISSILE01_08, g.assets.GIZMO.GIZMO_MISSILE01_09, g.assets.GIZMO.GIZMO_MISSILE01_10, g.assets.GIZMO.GIZMO_MISSILE01_11, g.assets.GIZMO.GIZMO_MISSILE01_12, g.assets.GIZMO.GIZMO_MISSILE01_13, g.assets.GIZMO.GIZMO_MISSILE01_14, g.assets.GIZMO.GIZMO_MISSILE01_15, g.assets.GIZMO.GIZMO_MISSILE01_16, g.assets.GIZMO.GIZMO_MISSILE01_17, g.assets.GIZMO.GIZMO_MISSILE01_18, g.assets.GIZMO.GIZMO_MISSILE01_19, g.assets.GIZMO.GIZMO_MISSILE01_20, g.assets.GIZMO.GIZMO_MISSILE01_21, g.assets.GIZMO.GIZMO_MISSILE01_22]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
