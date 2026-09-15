property ancestor
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(1)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.GIZMO.GIZMO_TAKEOFF_09]
  att = [g.MEMBER_0]
  def = [g.assets.GIZMO.GIZMO_TAKEOFF_09D]
  me.animation = new(g.classes.Class_LoopedAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on stop me
  ancestor.stop()
  me.owner.setHovering(0)
end

on reset me
  ancestor.reset()
  me.owner.setVel(me.owner.dir * me.owner.WALK_SPEED, 0.0)
  me.owner.setOnGround(0)
  me.owner.setShaking(0)
  me.owner.setHovering(1)
  me.owner.setShowingTrails(0)
end
