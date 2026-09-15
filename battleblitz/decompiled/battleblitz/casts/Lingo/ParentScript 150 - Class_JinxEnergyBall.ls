property ancestor, STATE_LAUNCH, STATE_CONJURE, STATE_WAIT, STATE_FINISH, moveState, initState, stateAge, delayFrames, projectile, effect
global g

on new me, owner
  ancestor = new(g.classes.Class_Move, owner)
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  vis = [g.assets.JINX.JINX_PUNCH_01, g.assets.JINX.JINX_PUNCH_02, g.assets.JINX.JINX_PUNCH_03]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.JINX.JINX_PUNCH_01D, g.assets.JINX.JINX_PUNCH_02D, g.assets.JINX.JINX_PUNCH_03D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
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
    g.main.audioMgr.stopSound(g.assets.JINX.SFX_JINX_MAKE_ENERGY_BALL)
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
          delayFrames = 2
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_CONJURE:
        if initState then
          initState = 0
          delayFrames = 2
          effect = new(g.classes.Class_JinxConjureEffect, me.owner, me.owner.pos + point(67 * me.owner.dir, -87), point(0, 0), me.owner.dir)
          g.main.screen.addEffect(effect)
          g.main.audioMgr.playSound(g.assets.JINX.SFX_JINX_MAKE_ENERGY_BALL, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if effect.isAlive() then
          effect.setPos(me.owner.pos + point(67 * me.owner.dir, -87))
        else
          effect = VOID
          advanceState()
        end if
      STATE_WAIT:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 5
          projectile = new(g.classes.Class_JinxBallProjectile, me.owner, me.owner.pos + point(67 * me.owner.dir, -87), point(15.0 * me.owner.dir, 0.0), me.owner.dir)
          g.main.screen.addProjectile(projectile)
          g.main.audioMgr.playSound(g.assets.JINX.SFX_JINX_RELEASE_ENERGY_BALL, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          projectile = VOID
          advanceState()
        end if
      STATE_FINISH:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 2
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.moveDone = 1
        end if
    end case
  end if
end
