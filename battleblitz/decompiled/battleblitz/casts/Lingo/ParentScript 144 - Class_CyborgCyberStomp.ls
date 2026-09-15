property ancestor, STATE_CROUCH, STATE_ASCENT, STATE_APEX, STATE_DESCENT, STATE_LAND, moveState, initState, stateAge, attackX, visAnim, visAltAnim
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_CYBORG_CYBER_STOMP
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.CYBORG.CYBORG_CROUCH_01, g.assets.CYBORG.CYBORG_JUMP_01, g.assets.CYBORG.CYBORG_JUMP_02]
  visAlt = [g.assets.CYBORG.CYBORG_CROUCH_ALT_01, g.assets.CYBORG.CYBORG_JUMP_ALT_01, g.assets.CYBORG.CYBORG_JUMP_ALT_02]
  att = [g.MEMBER_0, g.MEMBER_0, g.assets.CYBORG.CYBORG_JUMP_02D]
  def = [g.assets.CYBORG.CYBORG_CROUCH_01D, g.assets.CYBORG.CYBORG_JUMP_01D, g.MEMBER_0]
  order = [1, 2, 3, 1]
  visAnim = new(g.classes.Class_IndexedAnimation, vis, order)
  visAltAnim = new(g.classes.Class_IndexedAnimation, visAlt, order)
  me.animation = visAnim
  me.attackMasks = att
  me.defenseMasks = def
  STATE_CROUCH = 1
  STATE_ASCENT = 2
  STATE_APEX = 3
  STATE_DESCENT = 4
  STATE_LAND = 5
  moveState = 1
  initState = 1
  stateAge = 0
  return me
end

on stop me
  ancestor.stop()
  me.owner.setShowingTrails(0)
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  stateAge = 0
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
  attackX = 0.0
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

on setState me, i
  initState = 1
  moveState = i
  stateAge = 0
end

on advanceState me
  me.setState(moveState + 1)
end

on update me
  me.age = me.age + 1
  stateAge = stateAge + 1
  if not me.moveDone then
    case moveState of
      STATE_CROUCH:
        if initState then
          initState = 0
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_JUMP_1, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge = 4 then
          me.advanceState()
        end if
      STATE_ASCENT:
        if initState then
          initState = 0
          me.owner.setVel(0.0, -85.0)
          me.animation.advance()
          me.owner.setOnGround(0)
          me.owner.setShowingTrails(1)
          g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, me.owner.pos - point(30.0 * me.owner.dir, 0.0), point(-10.0 * me.owner.dir, 0.0), me.owner.dir))
          g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, me.owner.pos - point(-30.0 * me.owner.dir, 0.0), point(10.0 * me.owner.dir, 0.0), -me.owner.dir))
          attackX = me.owner.opponent.getPosX()
        end if
        if (me.owner.getPosY() + me.owner.getVelY()) <= -600.0 then
          me.advanceState()
        end if
      STATE_APEX:
        if initState then
          initState = 0
          me.owner.setVel((me.owner.opponent.getPosX() - me.owner.getPosX()) * 0.125, 0.0)
        end if
        if stateAge = 8 then
          me.advanceState()
        end if
      STATE_DESCENT:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setPosX(attackX)
          me.owner.setVel(0.0, 85.0)
        end if
        if me.owner.fallCheck() then
          me.owner.setVel(0.0, 0.0)
          me.advanceState()
        end if
      STATE_LAND:
        if initState then
          me.animation.advance()
          initState = 0
          me.owner.setOnGround(1)
          me.owner.setShowingTrails(0)
          g.main.screen.addEffect(new(g.classes.Class_CyborgFlareEffect, me.owner, me.owner.pos - point(30.0 * me.owner.dir, 0.0), point(-10.0 * me.owner.dir, 0.0), me.owner.dir))
          g.main.screen.addEffect(new(g.classes.Class_CyborgFlareEffect, me.owner, me.owner.pos - point(-30.0 * me.owner.dir, 0.0), point(10.0 * me.owner.dir, 0.0), -me.owner.dir))
          g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_CYBERSTOMP_HIT, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge = 4 then
          me.moveDone = 1
        end if
    end case
  end if
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_FLYINGPUNCHMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_CyborgExplodeEffect, me.owner, me.owner.opponent.pos + point(0.0, -100.0), point(0, 0), me.owner.dir))
    g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_FLYINGPUNCH, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
