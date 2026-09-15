property ancestor, STATE_CROUCH, STATE_ATTACK, STATE_PUSH, STATE_SLIDE, moveState, initState, delayFrames, crouchAnim, crouchAttMembers, crouchDefMembers, attackAnim, attackAttMembers, attackDefMembers, shake
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_MAMMOTH_SHOULDER_BARGE
  me.stunDuration = 10
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.MAMMOTH.MAMMOTH_JUMP_01]
  att = [g.MEMBER_0]
  def = [g.assets.MAMMOTH.MAMMOTH_JUMP_01D]
  crouchVisMembers = vis
  crouchAttMembers = att
  crouchDefMembers = def
  crouchAnim = new(g.classes.Class_LoopedAnimation, crouchVisMembers)
  vis = [g.assets.MAMMOTH.MAMMOTH_WALK_01, g.assets.MAMMOTH.MAMMOTH_WALK_02, g.assets.MAMMOTH.MAMMOTH_WALK_03, g.assets.MAMMOTH.MAMMOTH_WALK_04, g.assets.MAMMOTH.MAMMOTH_WALK_05, g.assets.MAMMOTH.MAMMOTH_WALK_06]
  att = [g.assets.MAMMOTH.MAMMOTH_SHOULDERBARGE_01A, g.assets.MAMMOTH.MAMMOTH_SHOULDERBARGE_01A, g.assets.MAMMOTH.MAMMOTH_SHOULDERBARGE_01A, g.assets.MAMMOTH.MAMMOTH_SHOULDERBARGE_01A, g.assets.MAMMOTH.MAMMOTH_SHOULDERBARGE_01A, g.assets.MAMMOTH.MAMMOTH_SHOULDERBARGE_01A]
  def = [g.assets.MAMMOTH.MAMMOTH_STAND_01D, g.assets.MAMMOTH.MAMMOTH_STAND_01D, g.assets.MAMMOTH.MAMMOTH_STAND_01D, g.assets.MAMMOTH.MAMMOTH_STAND_01D, g.assets.MAMMOTH.MAMMOTH_STAND_01D, g.assets.MAMMOTH.MAMMOTH_STAND_01D]
  attackVisMembers = vis
  attackAttMembers = att
  attackDefMembers = def
  attackAnim = new(g.classes.Class_LoopedAnimation, attackVisMembers)
  me.animation = crouchAnim
  me.attackMasks = crouchAttMembers
  me.defenseMasks = crouchDefMembers
  STATE_CROUCH = 1
  STATE_ATTACK = 2
  STATE_PUSH = 3
  STATE_SLIDE = 4
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
  crouchAnim.reset()
  attackAnim.reset()
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on stop me
  ancestor.stop()
  g.main.audioMgr.stopSound(g.assets.MAMMOTH.SFX_MAMMOTH_SHOULDER_BARGE_RUN)
  me.owner.setShaking(0)
  me.owner.setShowingTrails(0)
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
      STATE_CROUCH:
        if initState then
          initState = 0
          me.animation = crouchAnim
          me.attackMasks = crouchAttMembers
          me.defenseMasks = crouchDefMembers
          me.owner.setShaking(1)
          delayFrames = 5
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
          me.animation = attackAnim
          me.attackMasks = attackAttMembers
          me.defenseMasks = attackDefMembers
          me.owner.setVel(35.0 * me.owner.dir, 0.0)
          me.owner.setShaking(0)
          me.owner.setShowingTrails(1)
          g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_SHOULDER_BARGE_RUN, 100, g.SFX_EVENT_PRIORITY_HIGH)
        end if
        me.animation.advance()
        if (me.age mod 3) = 0 then
          g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, point(me.owner.getPosX(), 0.0), point(0, 0), me.owner.dir))
        end if
        if me.age > 75 then
          setState(STATE_SLIDE)
        else
          if ((me.owner.dir < 0) and (me.owner.pos <= me.owner.opponent.pos)) or ((me.owner.dir > 0) and (me.owner.pos >= me.owner.opponent.pos)) then
            setState(STATE_SLIDE)
          else
            if me.hitOpponent then
              advanceState()
            end if
          end if
        end if
      STATE_PUSH:
        if initState then
          initState = 0
          delayFrames = me.stunDuration - 1
        end if
        me.animation.advance()
        me.owner.opponent.setPos(me.owner.getPos() + point(100 * me.owner.dir, 0))
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_SLIDE:
        if initState then
          initState = 0
          me.animation = crouchAnim
          me.attackMasks = crouchAttMembers
          me.defenseMasks = crouchDefMembers
          me.animation.reset()
          if me.hitOpponent then
            me.owner.setVelX(me.owner.dir * 20.0)
            me.owner.opponent.setVelX(20.0 * me.owner.dir)
          end if
          me.owner.setShowingTrails(0)
          g.main.audioMgr.stopSound(g.assets.MAMMOTH.SFX_MAMMOTH_SHOULDER_BARGE_RUN)
        end if
        if abs(me.owner.getVelX()) > 5.0 then
          me.owner.accelerate(point(-1.0 * me.owner.dir, 0.0))
        else
          me.owner.setVel(0.0, 0.0)
          me.moveDone = 1
        end if
    end case
  end if
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_SHOULDERBARGEMISS, 100, g.SFX_EVENT_PRIORITY_HIGH)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.pos + point(75.0 * me.owner.dir, -100.0), me.owner.vel, me.owner.dir))
    g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_SHOULDERBARGEHIT, 100, g.SFX_EVENT_PRIORITY_HIGH)
    return 1
  end if
end
