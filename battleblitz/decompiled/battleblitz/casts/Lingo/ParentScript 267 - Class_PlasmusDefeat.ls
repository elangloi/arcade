property ancestor, STATE_LAUNCH, STATE_FALLING, moveState, initState, delayFrames, stunDuration, initStateAge
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(0)
  me.setVulnerable(0)
  me.setInitOwnerDir(1)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.PLASMUS.PLASMUS_HIT_01, g.assets.PLASMUS.PLASMUS_DEFEAT_01, g.assets.PLASMUS.PLASMUS_DEFEAT_02, g.assets.PLASMUS.PLASMUS_DEFEAT_03]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.PLASMUS.PLASMUS_HIT_01D, g.assets.PLASMUS.PLASMUS_DEFEAT_01D, g.assets.PLASMUS.PLASMUS_DEFEAT_02D, g.assets.PLASMUS.PLASMUS_DEFEAT_03D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_FALLING = 2
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
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
end

on setState me, i
  initState = 1
  initStateAge = me.age
  moveState = i
end

on advanceState me
  me.setState(moveState + 1)
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
          g.main.screen.addEffect(new(g.classes.Class_PlasmusHitSplatterEffect, me.owner, me.owner.pos + point(0.0, -175.0), point(-30.0 * me.owner.dir, 0.0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_TRANSFORM, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.advanceState()
        end if
      STATE_FALLING:
        if initState then
          initState = 0
        end if
        if ((me.age - initStateAge) mod 10) = 0 then
          if me.animation.isDone() then
            me.owner.setAlive(0)
            me.moveDone = 1
          else
            me.animation.advance()
          end if
        end if
    end case
  end if
end
