property ancestor, STATE_LAUNCH, STATE_WAIT, STATE_FINISH, moveState, initState, delayFrames, projectile
global g

on new me, owner
  ancestor = new(g.classes.Class_Move, owner)
  me.attackDamage = g.DAMAGE_GIZMO_CANNON
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.GIZMO.GIZMO_TAKEOFF_11, g.assets.GIZMO.GIZMO_TAKEOFF_10, g.assets.GIZMO.GIZMO_TAKEOFF_09, g.assets.GIZMO.GIZMO_TAKEOFF_08, g.assets.GIZMO.GIZMO_HOVER_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.GIZMO.GIZMO_TAKEOFF_11D, g.assets.GIZMO.GIZMO_TAKEOFF_10D, g.assets.GIZMO.GIZMO_TAKEOFF_09D, g.assets.GIZMO.GIZMO_TAKEOFF_08D, g.assets.GIZMO.GIZMO_HOVER_01D]
  order = [1, 2, 3, 4, 4, 4, 4, 2, 5]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_WAIT = 2
  STATE_FINISH = 3
  moveState = 1
  initState = 1
  delayFrames = 0
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  delayFrames = 0
  me.owner.setVel(0.0, 0.0)
  me.owner.setOnGround(0)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
end

on advanceState
  initState = 1
  moveState = moveState + 1
end

on update me
  me.age = me.age + 1
  if not me.moveDone then
    case moveState of
      STATE_LAUNCH:
        if initState then
          initState = 0
        end if
        if me.age > 1 then
          me.animation.advance()
        end if
        if me.animation.orderIndex = 8 then
          advanceState()
        end if
      STATE_WAIT:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 10
          g.main.screen.addEffect(new(g.classes.Class_GizmoMissileEffect, me.owner, me.owner.pos + point(50 * me.owner.dir, -75), point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_MISSILEFIRE, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          g.main.screen.addEffect(new(g.classes.Class_GroundExplode1Effect, me.owner, point(me.owner.getPosX() + (275 * me.owner.dir), 10.0), point(0, 0), me.owner.dir))
          g.main.screen.addProjectile(new(g.classes.Class_GizmoMissileProjectile, me.owner, point(me.owner.getPosX() + (275 * me.owner.dir), 0.0), point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_MISSILEHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
          advanceState()
        end if
      STATE_FINISH:
        if initState then
          initState = 0
        end if
        me.animation.advance()
        if me.animation.isDone() then
          me.moveDone = 1
        end if
    end case
  end if
end
