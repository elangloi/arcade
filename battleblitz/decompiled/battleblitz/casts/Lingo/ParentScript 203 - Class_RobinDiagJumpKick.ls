property ancestor, STATE_LAUNCH, STATE_ATTACK, STATE_HIT, STATE_DESCENT, STATE_LAND, STATE_STANDUP, moveState, initState, delayFrames
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_ROBIN_DIAG_JUMP_KICK
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.CHAR_SHARED.ROBIN_FLYINGKICK_01, g.assets.ROBIN.ROBIN_KICK_03, g.assets.ROBIN.ROBIN_KICK_04, g.assets.ROBIN.ROBIN_SOFTLANDING_01, g.assets.ROBIN.ROBIN_STANDUP_01]
  att = [g.MEMBER_0, g.assets.ROBIN.ROBIN_KICK_03A, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.ROBIN.ROBIN_FLYINGKICK_01D, g.assets.ROBIN.ROBIN_KICK_03D, g.assets.ROBIN.ROBIN_KICK_04D, g.assets.ROBIN.ROBIN_SOFTLANDING_01D, g.assets.ROBIN.ROBIN_STANDUP_01D]
  order = [1, 2, 3, 4, 5]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_ATTACK = 2
  STATE_HIT = 3
  STATE_DESCENT = 4
  STATE_LAND = 5
  STATE_STANDUP = 6
  moveState = 1
  initState = 1
  delayFrames = 0
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on stop me
  ancestor.stop()
  me.owner.setShowingTrails(0)
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
  me.owner.setVel(0.0, 0.0)
end

on advanceState
  initState = 1
  moveState = moveState + 1
end

on setState state
  initState = 1
  moveState = state
end

on update me
  me.age = me.age + 1
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
      STATE_ATTACK:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setVel(26.0 * me.owner.dir, 26.0)
          g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_ROBIN_FLYING_KICK_WOOSH, 100, g.SFX_EVENT_PRIORITY_LOW)
          me.owner.setShowingTrails(1)
        end if
        if me.hitOpponent then
          me.owner.setVel(0.0, 0.0)
          advanceState()
        else
          if (me.owner.getPosY() + me.owner.getVelY()) >= 30.0 then
            me.owner.setPosY(30.0)
            me.owner.setVel(0.0, 0.0)
            setState(STATE_LAND)
          end if
        end if
      STATE_HIT:
        if initState then
          initState = 0
          delayFrames = 5
          me.owner.setShowingTrails(0)
          if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
            g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
          else
            g.main.screen.addEffect(new(g.classes.Class_HitHorizBurstEffect, me.owner, me.owner.pos + point(74.0 * me.owner.dir, -52.0), point(0, 0), me.owner.dir))
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          end if
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
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
          advanceState()
        end if
      STATE_LAND:
        if initState then
          initState = 0
          if not me.hitOpponent then
            me.animation.advance()
          end if
          me.animation.advance()
          me.owner.setPosY(0.0)
          delayFrames = 6
          me.owner.setOnGround(1)
          me.owner.setShowingTrails(0)
          g.main.screen.addEffect(new(g.classes.Class_DustFallEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_LANDING_SMALL_PERSON, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.moveDone = 1
        end if
      STATE_STANDUP:
        if initState then
          me.animation.advance()
          initState = 0
          delayFrames = 6
          g.main.screen.addEffect(new(g.classes.Class_DustSkidEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.moveDone = 1
        end if
    end case
  end if
end
