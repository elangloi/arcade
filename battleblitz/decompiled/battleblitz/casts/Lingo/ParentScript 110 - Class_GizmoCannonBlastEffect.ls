property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.GIZMO.FX_GIZMO_CANNON_BLAST_01, g.assets.GIZMO.FX_GIZMO_CANNON_BLAST_02, g.assets.GIZMO.FX_GIZMO_CANNON_BLAST_03, g.assets.GIZMO.FX_GIZMO_CANNON_BLAST_04]
  order = [1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
