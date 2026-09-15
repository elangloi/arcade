property ancestor, STATE_LAUNCH, STATE_ATTACK, STATE_HIT, STATE_DESCENT, STATE_LAND, moveState, initState, stateAge, linesEffect, visAnim, visAltAnim
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_CYBORG_FLYING_PUNCH
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.CHAR_SHARED.CYBORG_JUMP_PUNCH_01, g.assets.CHAR_SHARED.CYBORG_JUMP_PUNCH_02, g.assets.CYBORG.CYBORG_JUMP_02, g.assets.CYBORG.CYBORG_CROUCH_01]
  visAlt = [g.assets.CHAR_SHARED.CYBORG_JUMP_PUNCH_ALT_01, g.assets.CHAR_SHARED.CYBORG_JUMP_PUNCH_ALT_02, g.assets.CYBORG.CYBORG_JUMP_ALT_02, g.assets.CYBORG.CYBORG_CROUCH_ALT_01]
  att = [g.assets.CYBORG.CYBORG_JUMP_PUNCH_02A, g.assets.CYBORG.CYBORG_JUMP_PUNCH_02A, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.CYBORG.CYBORG_JUMP_PUNCH_01D, g.assets.CYBORG.CYBORG_JUMP_PUNCH_02D, g.assets.CYBORG.CYBORG_JUMP_02D, g.assets.CYBORG.CYBORG_CROUCH_01D]
  visAnim = new(g.classes.Class_PlayOnceAnimation, vis)
  visAltAnim = new(g.classes.Class_PlayOnceAnimation, visAlt)
  me.animation = visAnim
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_ATTACK = 2
  STATE_HIT = 3
  STATE_DESCENT = 4
  STATE_LAND = 5
  moveState = 1
  initState = 1
  stateAge = 0
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on stop me
  ancestor.stop()
  if objectp(linesEffect) then
    linesEffect.destroy()
  end if
  me.owner.setShowingTrails(0)
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  stateAge = 0
  me.owner.setVel(0.0, 0.0)
  me.owner.setOnGround(0)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.dirChanged()
end

on dirChanged me
  if me.owner.dir > 0 then
    me.animation = visAnim
  else
    me.animation = visAltAnim
  end if
  me.animation.reset()
end

on advanceState me
  me.setState(moveState + 1)
end

on setState me, state
  initState = 1
  moveState = state
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
        end if
        if stateAge = 2 then
          g.main.screen.addEffect(new(g.classes.Class_WhiteBurstReverseEffect, me.owner, me.owner.pos + point(0.0, -200.0), point(0, 0), me.owner.dir))
        else
          if stateAge = 8 then
            me.advanceState()
          end if
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
          me.owner.setVel(20.0 * me.owner.dir, 29.19999999999999929)
          me.owner.setShowingTrails(1)
          linesEffect = new(g.classes.Class_CyborgDiagLinesEffect, me.owner, point(me.owner.getPosX() - (me.owner.dir * me.owner.getPosY() * 0.68489999999999995), 0.0), point(0, 0), me.owner.dir)
          g.main.screen.addEffect(linesEffect)
          g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_FLYINGPUNCHWOOSH, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if (me.owner.getPosY() + me.owner.getVelY()) >= 30.0 then
          me.owner.setPosY(30.0)
          me.owner.setVel(0.0, 0.0)
          me.setState(STATE_LAND)
        end if
      STATE_HIT:
        if initState then
          initState = 0
          me.owner.setVel(0.0, 0.0)
          if objectp(linesEffect) then
            linesEffect.destroy()
          end if
          me.owner.setShowingTrails(0)
        end if
        if stateAge = 10 then
          me.advanceState()
        end if
      STATE_DESCENT:
        if initState then
          me.owner.setVel(-5.0 * me.owner.dir, -10.0)
          me.animation.advance()
          initState = 0
        end if
        me.owner.accelerate(g.gravity)
        if (me.owner.getPosY() + me.owner.getVelY()) >= 0.0 then
          me.owner.setPosY(0.0)
          me.owner.setVel(0.0, 0.0)
          me.advanceState()
        end if
      STATE_LAND:
        if initState then
          initState = 0
          if not me.hitOpponent then
            me.animation.advance()
          end if
          me.animation.advance()
          me.animation.advance()
          me.owner.setPosY(0.0)
          me.owner.setOnGround(1)
          me.owner.setShowingTrails(0)
          if objectp(linesEffect) then
            linesEffect.destroy()
          end if
          g.main.screen.addEffect(new(g.classes.Class_DustFallEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_LANDING_SMALL_PERSON, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge = 6 then
          me.moveDone = 1
        end if
    end case
  end if
end

on opponentHit me
  me.hitOpponent = 1
  me.animation.advance()
  me.setState(STATE_HIT)
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_FLYINGPUNCHMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitHorizBurstEffect, me.owner, me.owner.pos + point(100.0 * me.owner.dir, -40.0), point(0, 0), me.owner.dir))
    g.main.screen.addEffect(new(g.classes.Class_WhiteBurstEffect, me.owner, me.owner.pos + point(100.0 * me.owner.dir, -40.0), point(0, 0), me.owner.dir))
    g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_FLYINGPUNCH, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
