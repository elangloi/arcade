property ancestor, STATE_LAUNCH, STATE_CONJURE, STATE_WAIT, STATE_FINISH, moveState, initState, stateAge, delayFrames, projectile, effect
global g

on new me, owner
  ancestor = new(g.classes.Class_Move, owner)
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  vis = [g.assets.STARFIRE.STARFIRE_PUNCH_01, g.assets.STARFIRE.STARFIRE_PUNCH_02, g.assets.STARFIRE.STARFIRE_PUNCH_03]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.STARFIRE.STARFIRE_PUNCH_01D, g.assets.STARFIRE.STARFIRE_PUNCH_02D, g.assets.STARFIRE.STARFIRE_PUNCH_03D]
  order = [1, 2, 3, 1]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_CONJURE = 2
  STATE_WAIT = 3
  STATE_FINISH = 4
  moveState = 1
  initState = 1
  delayFrames = 0
  stateAge = 0
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
  projectile = VOID
  effect = VOID
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on stop me
  ancestor.stop()
  if not voidp(effect) then
    g.game.killEffect(effect)
    effect = VOID
  end if
end

on advanceState
  initState = 1
  moveState = moveState + 1
  stateAge = 0
end

on update me
  me.age = me.age + 1
  stateAge = stateAge + 1
  if not me.moveDone then
    case moveState of
      STATE_LAUNCH:
        if initState then
          initState = 0
          delayFrames = 4
        end if
        me.owner.moveBy(-3.0 * me.owner.dir, 0.0)
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_CONJURE:
        if initState then
          initState = 0
          delayFrames = 7
          effect = new(g.classes.Class_StarfireConjureEffect, me.owner, me.owner.pos + point(-28 * me.owner.dir, -130), point(0, 0), me.owner.dir)
          g.main.screen.addEffect(effect)
          g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_STARFIRE_MAKINGSTARBOLT, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        me.owner.moveBy(-2.0 * me.owner.dir, 0.0)
        if effect.isAlive() then
          effect.setPos(me.owner.pos + point(-28 * me.owner.dir, -130))
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          effect = VOID
          advanceState()
        end if
      STATE_WAIT:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 10
          projectile = new(g.classes.Class_StarfireBallProjectile, me.owner, me.owner.pos + point(75 * me.owner.dir, -138), point(17.0 * me.owner.dir, 0.0), me.owner.dir)
          g.main.screen.addProjectile(projectile)
          g.main.screen.addEffect(new(g.classes.Class_StarfireFistEffect, me.owner, me.owner.pos + point(85 * me.owner.dir, -138), point(0.0, 0.0), me.owner.dir))
        end if
        delayFrames = delayFrames - 1
        if delayFrames >= 6 then
          me.owner.moveBy(12.0 * me.owner.dir, 0.0)
        else
          if delayFrames = 0 then
            projectile = VOID
            advanceState()
          end if
        end if
      STATE_FINISH:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 3
        end if
        me.owner.moveBy(-10.0 * me.owner.dir, 0.0)
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.moveDone = 1
        end if
    end case
  end if
end
