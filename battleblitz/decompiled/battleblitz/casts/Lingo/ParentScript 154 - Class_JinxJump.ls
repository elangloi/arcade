property ancestor, STATE_CROUCH, STATE_ASCENT, STATE_FLIP_1, STATE_FLIP_2, STATE_DESCENT, STATE_LAND, moveState, initState, delayFrames, jumpDir
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.JINX.JINX_JUMP_01, g.assets.JINX.JINX_JUMP_02, g.assets.JINX.JINX_JUMP_03, g.assets.JINX.JINX_JUMP_04, g.assets.JINX.JINX_JUMP_05, g.assets.JINX.JINX_JUMP_06]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.JINX.JINX_JUMP_01D, g.assets.JINX.JINX_JUMP_02D, g.assets.JINX.JINX_JUMP_03D, g.assets.JINX.JINX_JUMP_04D, g.assets.JINX.JINX_JUMP_05D, g.assets.JINX.JINX_JUMP_06D]
  order = [1, 2, 3, 4, 5, 1]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_CROUCH = 1
  STATE_ASCENT = 2
  STATE_FLIP_1 = 3
  STATE_FLIP_2 = 4
  STATE_DESCENT = 5
  STATE_LAND = 6
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
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
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
      STATE_CROUCH:
        if initState then
          initState = 0
          delayFrames = 2
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_JUMP_2, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_ASCENT:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setVel(g.JUMP_VELOCITY.locH * jumpDir, g.JUMP_VELOCITY.locV)
          me.owner.setOnGround(0)
          if jumpDir = 0 then
            dir = me.owner.dir
          else
            dir = jumpDir
          end if
          g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, me.owner.pos, point(0, 0), dir))
        end if
        me.owner.accelerate(g.gravity)
        if me.owner.getVelY() > -15.0 then
          advanceState()
        end if
      STATE_FLIP_1:
        if initState then
          initState = 0
          me.animation.advance()
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_JUMP_0, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        me.owner.accelerate(g.gravity)
        if me.owner.getVelY() > -5.0 then
          advanceState()
        end if
      STATE_FLIP_2:
        if initState then
          initState = 0
          me.animation.advance()
        end if
        me.owner.accelerate(g.gravity)
        if me.owner.fallCheck() then
          me.owner.setVel(0.0, 0.0)
          setState(STATE_LAND)
        else
          if me.owner.getVelY() > 5.0 then
            advanceState()
          end if
        end if
      STATE_DESCENT:
        if initState then
          initState = 0
          me.animation.advance()
        end if
        me.owner.accelerate(g.gravity)
        if me.owner.fallCheck() then
          me.owner.setVel(0.0, 0.0)
          advanceState()
        end if
      STATE_LAND:
        if initState then
          initState = 0
          me.animation.advance()
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
