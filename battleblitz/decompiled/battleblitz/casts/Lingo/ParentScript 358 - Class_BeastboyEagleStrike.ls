property ancestor, STATE_LAUNCH, STATE_ATTACK, STATE_HIT, STATE_UNTRANSFORM, STATE_DESCENT, STATE_LAND, STATE_STANDUP, moveState, initState, stateAge
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_BEASTBOY_EAGLE_STRIKE
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.BEASTBOY.BEASTBOY_JUMP_02, g.assets.BEASTBOY.BEASTBOY_JUMP_TRANSFORM_02, g.assets.BEASTBOY.BEASTBOY_EAGLE_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_EAGLE_01, g.assets.BEASTBOY.BEASTBOY_EAGLE_02, g.assets.BEASTBOY.BEASTBOY_EAGLE_03, g.assets.BEASTBOY.BEASTBOY_EAGLE_TRANSFORM_03, g.assets.BEASTBOY.BEASTBOY_JUMP_04, g.assets.BEASTBOY.BEASTBOY_STANDUP_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.assets.BEASTBOY.BEASTBOY_EAGLE_02A, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.BEASTBOY.BEASTBOY_JUMP_02D, g.assets.BEASTBOY.BEASTBOY_JUMP_02D, g.assets.BEASTBOY.BEASTBOY_EAGLE_01D, g.assets.BEASTBOY.BEASTBOY_EAGLE_01D, g.assets.BEASTBOY.BEASTBOY_EAGLE_01D, g.assets.BEASTBOY.BEASTBOY_EAGLE_01D, g.assets.BEASTBOY.BEASTBOY_EAGLE_01D, g.assets.BEASTBOY.BEASTBOY_JUMP_04D, g.assets.BEASTBOY.BEASTBOY_STANDUP_01D]
  order = [1, 2, 1, 3, 4, 5, 6, 7, 6, 7, 6, 2, 1, 2, 1, 8, 9]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_ATTACK = 2
  STATE_HIT = 3
  STATE_UNTRANSFORM = 4
  STATE_DESCENT = 5
  STATE_LAND = 6
  STATE_STANDUP = 7
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
  me.owner.setShowingTrails(0)
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  stateAge = 0
  me.owner.setOnGround(0)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
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
          g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_TRANSFORM, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge > 1 then
          me.animation.advance()
        end if
        if stateAge = 5 then
          me.advanceState()
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setVel(30.0 * me.owner.dir, 30.0)
          g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_BIRD, 100, g.SFX_EVENT_PRIORITY_LOW)
          me.owner.setShowingTrails(1)
        end if
        if me.hitOpponent then
          me.owner.setVel(0.0, 0.0)
          me.animation.advance()
          me.advanceState()
        else
          if (me.owner.getPosY() + me.owner.getVelY()) >= 30.0 then
            me.owner.setPosY(30.0)
            me.owner.setVel(0.0, 0.0)
            me.setState(STATE_UNTRANSFORM)
          else
            me.owner.accelerate(point(3.0 * me.owner.dir, 0.0))
          end if
        end if
      STATE_HIT:
        if initState then
          initState = 0
          me.owner.setShowingTrails(0)
          if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
            g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
          else
            g.main.screen.addEffect(new(g.classes.Class_HitHorizBurstEffect, me.owner, me.owner.pos + point(74.0 * me.owner.dir, -52.0), point(0, 0), me.owner.dir))
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          end if
        end if
        if stateAge = 5 then
          me.advanceState()
        end if
      STATE_UNTRANSFORM:
        if initState then
          initState = 0
          g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_TRANSFORMBACK, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge > 1 then
          me.animation.advance()
        end if
        if stateAge = 8 then
          if me.hasHitOpponent() then
            me.advanceState()
          else
            me.setState(STATE_LAND)
          end if
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
          me.owner.setPosY(0.0)
          me.owner.setOnGround(1)
          me.owner.setShowingTrails(0)
          me.animation.orderIndex = 15
          me.animation.advance()
          g.main.screen.addEffect(new(g.classes.Class_DustFallEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_LANDING_SMALL_PERSON, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge = 6 then
          me.moveDone = 1
        end if
      STATE_STANDUP:
        if initState then
          me.animation.advance()
          initState = 0
          g.main.screen.addEffect(new(g.classes.Class_DustSkidEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
        end if
        if stateAge = 6 then
          me.moveDone = 1
        end if
    end case
  end if
end
