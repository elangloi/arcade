property ancestor, STATE_STUN, STATE_SLIDE, STATE_RECOVER, stunDuration, initState, moveState, delayFrames
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(1)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.PLASMUS.PLASMUS_HIT_01, g.assets.PLASMUS.PLASMUS_FIST_CLENCH_03, g.assets.PLASMUS.PLASMUS_FIST_CLENCH_02, g.assets.PLASMUS.PLASMUS_FIST_CLENCH_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.PLASMUS.PLASMUS_HIT_01D, g.assets.PLASMUS.PLASMUS_STAND_01D, g.assets.PLASMUS.PLASMUS_STAND_01D, g.assets.PLASMUS.PLASMUS_STAND_01D]
  order = [1, 2, 2, 3, 3, 4, 4, 2, 2, 3, 3, 4, 4]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  stunDuration = 0
  STATE_STUN = 1
  STATE_SLIDE = 2
  STATE_RECOVER = 3
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on reset me, arg
  ancestor.reset()
  if voidp(arg) then
    stunDuration = 0
  else
    stunDuration = arg
  end if
  moveState = 1
  initState = 1
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  if me.owner.getPosY() > 0.0 then
    me.owner.setPosY(0.0)
  end if
  me.owner.setVel(0.0, 0.0)
end

on advanceState
  initState = 1
  moveState = moveState + 1
end

on update me
  me.age = me.age + 1
  if not me.moveDone then
    case moveState of
      STATE_STUN:
        if initState then
          initState = 0
        end if
        if me.age >= stunDuration then
          me.advanceState()
        end if
      STATE_SLIDE:
        if initState then
          initState = 0
          g.main.screen.addEffect(new(g.classes.Class_PlasmusHitSplatterEffect, me.owner, me.owner.pos + point(0.0, -175.0), point(-35.0 * me.owner.dir, 0.0), me.owner.dir))
          me.owner.setVelX(-20.0 * me.owner.dir)
        end if
        me.owner.accelerate(point(1.5 * me.owner.dir, 0.0))
        if me.owner.dir > 0 then
          if me.owner.getVelX() >= 0.0 then
            me.owner.setVelX(0.0)
            me.advanceState()
          end if
        else
          if me.owner.getVelX() <= 0.0 then
            me.owner.setVelX(0.0)
            me.advanceState()
          end if
        end if
      STATE_RECOVER:
        if initState then
          initState = 0
          delayFrames = 6
          if random(2) = 1 then
            g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_ROAR_SMALL, 100, g.SFX_EVENT_PRIORITY_LOW)
          end if
        end if
        me.animation.advance()
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.moveDone = 1
        end if
    end case
  end if
end
