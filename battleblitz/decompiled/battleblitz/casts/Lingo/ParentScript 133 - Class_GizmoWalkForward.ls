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
  vis = [g.assets.GIZMO.GIZMO_WALK_01, g.assets.GIZMO.GIZMO_WALK_02, g.assets.GIZMO.GIZMO_WALK_03, g.assets.GIZMO.GIZMO_WALK_04, g.assets.GIZMO.GIZMO_WALK_05, g.assets.GIZMO.GIZMO_WALK_06]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.GIZMO.GIZMO_STAND_01D, g.assets.GIZMO.GIZMO_STAND_01D, g.assets.GIZMO.GIZMO_STAND_01D, g.assets.GIZMO.GIZMO_STAND_01D, g.assets.GIZMO.GIZMO_STAND_01D, g.assets.GIZMO.GIZMO_STAND_01D]
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
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(me.owner.dir * me.owner.WALK_SPEED, 0.0)
end

on update me
  ancestor.update()
  if (me.age mod 3) = 1 then
    if random(2) = 1 then
      g.main.audioMgr.playSound(g.assets.AUDIO.SFX_WALKING_SMALL_PERSON_1, 50, g.SFX_EVENT_PRIORITY_LOW)
    else
      g.main.audioMgr.playSound(g.assets.AUDIO.SFX_WALKING_SMALL_PERSON_2, 50, g.SFX_EVENT_PRIORITY_LOW)
    end if
  end if
end
