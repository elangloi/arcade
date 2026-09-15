property ancestor
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(1)
  me.setVulnerable(1)
  me.setInitOwnerDir(1)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.GIZMO.GIZMO_HOVER_01]
  att = [g.MEMBER_0]
  def = [g.assets.GIZMO.GIZMO_HOVER_01D]
  me.animation = new(g.classes.Class_LoopedAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on reset me
  ancestor.reset()
  me.owner.setVel(0.0, 0.0)
  me.owner.setPosY(me.owner.HOVER_HEIGHT)
  me.owner.setOnGround(0)
  me.owner.setShaking(0)
  me.owner.setHovering(1)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on stop me
  me.owner.setHovering(0)
end

on update me
  ancestor.update()
  if (me.age mod 20) = 1 then
    if random(2) = 1 then
      g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_FLY, 100, g.SFX_EVENT_PRIORITY_LOW)
    else
      g.main.audioMgr.playSound(g.assets.GIZMO.sfx_gizmo_fly2, 100, g.SFX_EVENT_PRIORITY_LOW)
    end if
  end if
end
