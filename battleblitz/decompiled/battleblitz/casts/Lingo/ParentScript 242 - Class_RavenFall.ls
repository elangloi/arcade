property ancestor, STATE_DESCENT_1, STATE_DESCENT_2, STATE_LAND, moveState, initState, delayFrames, jumpDir
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.RAVEN.RAVEN_JUMP_02, g.assets.RAVEN.RAVEN_JUMP_03, g.assets.RAVEN.RAVEN_JUMP_04]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.RAVEN.RAVEN_JUMP_02D, g.assets.RAVEN.RAVEN_JUMP_03D, g.assets.RAVEN.RAVEN_JUMP_04D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_DESCENT_1 = 1
  STATE_DESCENT_2 = 2
  STATE_LAND = 3
  moveState = 1
  initState = 1
  delayFrames = 0
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on setState i
  initState = 1
  moveState = i
end

on advanceState
  initState = 1
  moveState = moveState + 1
end

on update me
  me.age = me.age + 1
  if not me.moveDone then
    case moveState of
      STATE_DESCENT_1:
        if initState then
          initState = 0
          delayFrames = 8
        end if
        delayFrames = delayFrames - 1
        me.owner.accelerate(g.gravity)
        if me.owner.fallCheck() then
          me.owner.setVel(0.0, 0.0)
          setState(STATE_LAND)
        else
          if delayFrames = 0 then
            advanceState()
          end if
        end if
      STATE_DESCENT_2:
        if initState then
          me.animation.advance()
          initState = 0
        end if
        me.owner.accelerate(g.gravity)
        if me.owner.fallCheck() then
          me.owner.setVel(0.0, 0.0)
          advanceState()
        end if
      STATE_LAND:
        if initState then
          me.animation.advance()
          initState = 0
          delayFrames = 3
          me.owner.setOnGround(1)
          g.main.screen.addEffect(new(g.classes.Class_DustFallEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_LANDING_SMALL_PERSON, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.moveDone = 1
        end if
    end case
  end if
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  delayFrames = 0
  me.owner.setOnGround(0)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
end
