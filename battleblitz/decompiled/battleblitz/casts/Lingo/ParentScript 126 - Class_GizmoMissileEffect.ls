property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.GIZMO.GIZMO_MISSILE02_00, g.assets.GIZMO.GIZMO_MISSILE02_01, g.assets.GIZMO.GIZMO_MISSILE02_02, g.assets.GIZMO.GIZMO_MISSILE02_03, g.assets.GIZMO.GIZMO_MISSILE02_04, g.assets.GIZMO.GIZMO_MISSILE02_05, g.assets.GIZMO.GIZMO_MISSILE02_06, g.assets.GIZMO.GIZMO_MISSILE02_07, g.assets.GIZMO.GIZMO_MISSILE02_08, g.assets.GIZMO.GIZMO_MISSILE02_09, g.assets.GIZMO.GIZMO_MISSILE02_10, g.assets.GIZMO.GIZMO_MISSILE02_11, g.assets.GIZMO.GIZMO_MISSILE02_12, g.assets.GIZMO.GIZMO_MISSILE02_13, g.assets.GIZMO.GIZMO_MISSILE02_14]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
