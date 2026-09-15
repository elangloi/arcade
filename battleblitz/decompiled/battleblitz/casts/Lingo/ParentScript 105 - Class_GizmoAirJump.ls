property ancestor, STATE_CROUCH, STATE_ASCENT, STATE_DESCENT, STATE_LAND, moveState, initState, delayFrames, jumpDir
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.GIZMO.GIZMO_HOVER_01, g.assets.GIZMO.GIZMO_HOVER_01, g.assets.GIZMO.GIZMO_HOVER_01, g.assets.GIZMO.GIZMO_HOVER_01, g.assets.GIZMO.GIZMO_HOVER_01, g.assets.GIZMO.GIZMO_HOVER_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.GIZMO.GIZMO_HOVER_01D, g.assets.GIZMO.GIZMO_HOVER_01D, g.assets.GIZMO.GIZMO_HOVER_01D, g.assets.GIZMO.GIZMO_HOVER_01D, g.assets.GIZMO.GIZMO_HOVER_01D, g.assets.GIZMO.GIZMO_HOVER_01D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_CROUCH = 1
  STATE_ASCENT = 2
  STATE_DESCENT = 3
  STATE_LAND = 4
  moveState = 1
  initState = 1
  delayFrames = 0
  jumpDir = 0
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
  if voidp(arg) then
    jumpDir = 0
  else
    if arg < 0 then
      jumpDir = -1
    else
      if arg > 0 then
        jumpDir = 1
      else
        jumpDir = 0
      end if
    end if
  end if
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
      STATE_CROUCH:
        if initState then
          initState = 0
          delayFrames = 2
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_JUMP_1, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        me.owner.moveBy(0.0, 15.0)
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_ASCENT:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setVel(g.JUMP_VELOCITY.locH * jumpDir, g.JUMP_VELOCITY.locV)
          if jumpDir = 0 then
            dir = me.owner.dir
          else
            dir = jumpDir
          end if
          g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, point(me.owner.getPosX(), 0.0), point(0, 0), dir))
        end if
        me.owner.accelerate(g.gravity * 0.75)
        if me.owner.getVelY() > 0 then
          advanceState()
        end if
      STATE_DESCENT:
        if initState then
          initState = 0
          me.animation.advance()
        end if
        me.owner.accelerate(g.gravity * 0.5)
        if (me.owner.getPosY() + me.owner.getVelY()) >= (me.owner.HOVER_HEIGHT + 12.0) then
          me.owner.setVel(0.0, 0.0)
          me.owner.setPosY(12.0)
          advanceState()
        end if
      STATE_LAND:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setVel(0.0, -10.0)
          g.main.screen.addEffect(new(g.classes.Class_DustFallEffect, me.owner, point(me.owner.getPosX(), 0.0), point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_LANDING_SMALL_PERSON, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if me.owner.getPosY() <= me.owner.HOVER_HEIGHT then
          me.owner.setVel(0.0, 0.0)
          me.owner.setPosY(me.owner.HOVER_HEIGHT)
          me.moveDone = 1
        end if
    end case
  end if
end
