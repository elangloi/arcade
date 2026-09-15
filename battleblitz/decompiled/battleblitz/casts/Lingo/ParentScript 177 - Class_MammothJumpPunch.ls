property ancestor, STATE_CROUCH, STATE_ASCENT_1, STATE_ASCENT_2, STATE_ASCENT_3, STATE_ATTACK, STATE_DESCENT, STATE_LAND, moveState, initState, delayFrames
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_MAMMOTH_JUMP_PUNCH
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.MAMMOTH.MAMMOTH_JUMP_01, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_01, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_02, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_03, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_04, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_05, g.assets.MAMMOTH.MAMMOTH_JUMP_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_04A, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.MAMMOTH.MAMMOTH_JUMP_01D, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_01D, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_02D, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_03D, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_04D, g.assets.MAMMOTH.MAMMOTH_JUMPPUNCH_05D, g.assets.MAMMOTH.MAMMOTH_JUMP_01D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_CROUCH = 1
  STATE_ASCENT_1 = 2
  STATE_ASCENT_2 = 3
  STATE_ASCENT_3 = 4
  STATE_ATTACK = 5
  STATE_DESCENT = 6
  STATE_LAND = 7
  moveState = 1
  initState = 1
  delayFrames = 0
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
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
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
      STATE_CROUCH:
        if initState then
          initState = 0
          delayFrames = 4
          g.main.screen.addEffect(new(g.classes.Class_WhiteBurstReverseEffect, me.owner, me.owner.pos + point(-66.0 * me.owner.dir, -41.0), point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_JUMPSPIN, 80, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_ASCENT_1:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setOnGround(0)
          delayFrames = 2
          g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_JUMP_0, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        me.owner.moveBy(0.0, -10.0)
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_ASCENT_2:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 2
        end if
        me.owner.moveBy(0.0, -10.0)
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_ASCENT_3:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 2
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 6
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_DESCENT:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 4
        end if
        me.owner.moveBy(0.0, 10.0)
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_LAND:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setOnGround(1)
          delayFrames = 3
          g.main.screen.addEffect(new(g.classes.Class_DustFallEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_LANDING_BIG_PERSON, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.moveDone = 1
        end if
    end case
  end if
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_JUMPSPINMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitHorizBurstEffect, me.owner, me.owner.pos + point(107.0 * me.owner.dir, -94.0), point(0, 0), me.owner.dir))
    g.main.screen.addEffect(new(g.classes.Class_WhiteBurstReverseEffect, me.owner, me.owner.pos + point(107.0 * me.owner.dir, -94.0), point(0, 0), me.owner.dir))
    g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_JUMPSPINHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
