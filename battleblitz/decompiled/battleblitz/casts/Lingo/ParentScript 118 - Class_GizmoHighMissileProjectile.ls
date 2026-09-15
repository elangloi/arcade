property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_GizmoMissileProjectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_GIZMO_HIGH_AIR_MISSILE
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
