property ancestor, STATE_LAUNCH, STATE_FALLING, STATE_LAND, STATE_STANDUP, moveState, initState, delayFrames, stunDuration
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(0)
  me.setVulnerable(0)
  me.setInitOwnerDir(1)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.BEASTBOY.BEASTBOY_HIT_01, g.assets.BEASTBOY.BEASTBOY_FALL_01, g.assets.BEASTBOY.BEASTBOY_FALL_02, g.assets.BEASTBOY.BEASTBOY_STANDUP_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.BEASTBOY.BEASTBOY_HIT_01D, g.assets.BEASTBOY.BEASTBOY_FALL_01D, g.assets.BEASTBOY.BEASTBOY_FALL_02D, g.assets.BEASTBOY.BEASTBOY_STANDUP_01D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_FALLING = 2
  STATE_LAND = 3
  STATE_STANDUP = 4
  moveState = 1
  initState = 1
  delayFrames = 0
  stunDuration = 0
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
    stunDuration = 0
  else
    stunDuration = arg
  end if
  if me.owner.getPosY() > 0.0 then
    me.owner.setPosY(0.0)
  end if
  me.owner.setVel(0.0, 0.0)
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
          delayFrames = stunDuration
          if delayFrames < 1 then
            delayFrames = 1
          end if
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_FALLING:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setVel(g.KNOCK_DOWN_VELOCITY * point(me.owner.dir, 1))
          me.owner.setOnGround(0)
        end if
        me.owner.accelerate(g.gravity)
        if ((me.owner.getPosY() + me.owner.getVelY()) >= 0.0) and (me.owner.getVelY() > 0) then
          me.owner.setPosY(0.0)
          me.owner.setVel(0.0, 0.0)
          advanceState()
        end if
      STATE_LAND:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 6
          me.owner.setPosY(0.0)
          me.owner.setOnGround(1)
          g.main.screen.addEffect(new(g.classes.Class_DustFallEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_SLUMP_TO_FLOOR, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_STANDUP:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 4
          me.setVulnerable(1)
          g.main.screen.addEffect(new(g.classes.Class_DustSkidEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.moveDone = 1
        end if
    end case
  end if
end
