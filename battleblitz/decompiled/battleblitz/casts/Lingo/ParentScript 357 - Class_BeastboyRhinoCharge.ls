property ancestor, STATE_TRANSFORM, STATE_RUSH, STATE_SLIDE, STATE_ATTACK, STATE_SKID, STATE_UNTRANSFORM, moveState, initState, stateAge, transformAnim, transformAttMembers, transformDefMembers, rushAnim, rushAttMembers, rushDefMembers, attackAnim, attackAttMembers, attackDefMembers, untransformAnim, untransformAttMembers, untransformDefMembers
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_BEASTBOY_RHINO_CHARGE
  me.stunDuration = 10
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.BEASTBOY.BEASTBOY_STAND_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_STAND_01, g.assets.BEASTBOY.BEASTBOY_CROUCH_01, g.assets.BEASTBOY.BEASTBOY_CROUCH_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_RHINO_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.BEASTBOY.BEASTBOY_STAND_01D, g.assets.BEASTBOY.BEASTBOY_STAND_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D]
  order = [1, 2, 3, 4, 3, 4, 5, 6, 5, 6]
  transformVisMembers = vis
  transformAttMembers = att
  transformDefMembers = def
  transformAnim = new(g.classes.Class_IndexedAnimation, transformVisMembers, order)
  vis = [g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_02, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_03, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_04, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01]
  att = [g.assets.BEASTBOY.BEASTBOY_RHINO_ATTACK_02A, g.assets.BEASTBOY.BEASTBOY_RHINO_ATTACK_02A, g.assets.BEASTBOY.BEASTBOY_RHINO_ATTACK_02A, g.assets.BEASTBOY.BEASTBOY_RHINO_ATTACK_02A]
  def = [g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D]
  rushVisMembers = vis
  rushAttMembers = att
  rushDefMembers = def
  rushAnim = new(g.classes.Class_LoopedAnimation, rushVisMembers)
  vis = [g.assets.BEASTBOY.BEASTBOY_RHINO_ATTACK_01, g.assets.BEASTBOY.BEASTBOY_RHINO_ATTACK_02]
  att = [g.assets.BEASTBOY.BEASTBOY_RHINO_ATTACK_02A, g.assets.BEASTBOY.BEASTBOY_RHINO_ATTACK_02A]
  def = [g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D]
  attackVisMembers = vis
  attackAttMembers = att
  attackDefMembers = def
  attackAnim = new(g.classes.Class_PlayOnceAnimation, attackVisMembers)
  vis = [g.assets.BEASTBOY.BEASTBOY_RHINO_TRANSFORM_02, g.assets.BEASTBOY.BEASTBOY_RHINO_ATTACK_02, g.assets.BEASTBOY.BEASTBOY_CROUCH_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_CROUCH_01, g.assets.BEASTBOY.BEASTBOY_STAND_01, g.assets.BEASTBOY.BEASTBOY_STAND_TRANSFORM_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D, g.assets.BEASTBOY.BEASTBOY_STAND_01D, g.assets.BEASTBOY.BEASTBOY_STAND_01D]
  order = [1, 2, 1, 3, 4, 3, 4, 5, 6, 5]
  untransformVisMembers = vis
  untransformAttMembers = att
  untransformDefMembers = def
  untransformAnim = new(g.classes.Class_IndexedAnimation, untransformVisMembers, order)
  me.animation = transformAnim
  me.attackMasks = transformAttMembers
  me.defenseMasks = transformDefMembers
  STATE_TRANSFORM = 1
  STATE_RUSH = 2
  STATE_SLIDE = 3
  STATE_ATTACK = 4
  STATE_SKID = 5
  STATE_UNTRANSFORM = 6
  moveState = 1
  initState = 1
  delayFrames = 0
  return me
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  stateAge = 0
  transformAnim.reset()
  rushAnim.reset()
  attackAnim.reset()
  untransformAnim.reset()
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on stop me
  ancestor.stop()
  g.main.audioMgr.stopSound(g.assets.BEASTBOY.SFX_BEASTBOY_RHINOGALLOP)
  me.owner.setShaking(0)
  me.owner.setShowingTrails(0)
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
      STATE_TRANSFORM:
        if initState then
          initState = 0
          me.animation = transformAnim
          me.attackMasks = transformAttMembers
          me.defenseMasks = transformDefMembers
          g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_TRANSFORM, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge > 1 then
          me.animation.advance()
        end if
        if me.animation.isDone() then
          me.advanceState()
        end if
      STATE_RUSH:
        if initState then
          initState = 0
          me.animation = rushAnim
          me.attackMasks = rushAttMembers
          me.defenseMasks = rushDefMembers
          me.owner.setShowingTrails(1)
          me.owner.setVel(35.0 * me.owner.dir, 0.0)
          g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_RHINOGALLOP, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge > 1 then
          me.animation.advance()
        end if
        if (stateAge mod 3) = 0 then
          g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, point(me.owner.getPosX(), 0.0), point(0, 0), me.owner.dir))
        end if
        if me.hitOpponent then
          me.owner.opponent.moveBy(me.owner.getVelX(), 0.0)
        end if
        if not me.owner.groundCheck(me.owner.pos + me.owner.vel) then
          me.setState(STATE_UNTRANSFORM)
        else
          if ((me.owner.dir < 0) and (me.owner.pos < me.owner.opponent.pos)) or ((me.owner.dir > 0) and (me.owner.pos > me.owner.opponent.pos)) or me.hitOpponent or (stateAge >= 60) then
            me.advanceState()
          end if
        end if
      STATE_SLIDE:
        if initState then
          initState = 0
          me.animation = attackAnim
          me.attackMasks = attackAttMembers
          me.defenseMasks = attackDefMembers
          g.main.audioMgr.stopSound(g.assets.BEASTBOY.SFX_BEASTBOY_RHINOGALLOP)
        end if
        if abs(me.owner.getVelX()) > 0.0 then
          me.owner.accelerate(-2.0 * me.owner.dir)
        end if
        if me.hitOpponent then
          me.owner.opponent.moveBy(me.owner.getVelX(), 0.0)
        end if
        if not me.owner.groundCheck(me.owner.pos + me.owner.vel) then
          me.setState(STATE_UNTRANSFORM)
        else
          if stateAge > 6 then
            if me.hitOpponent then
              me.setState(STATE_ATTACK)
            else
              me.setState(STATE_SKID)
            end if
          end if
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
          me.animation.advance()
        end if
        if abs(me.owner.getVelX()) > 0.0 then
          me.owner.accelerate(-2.0 * me.owner.dir)
        end if
        if me.hitOpponent then
          me.owner.opponent.moveBy(me.owner.getVelX(), 0.0)
        end if
        if stateAge >= 10 then
          me.advanceState()
        end if
      STATE_SKID:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setShowingTrails(0)
        end if
        if abs(me.owner.getVelX()) < 2.0 then
          me.owner.setVelX(0.0)
          me.advanceState()
        else
          me.owner.accelerate(-2.0 * me.owner.dir)
        end if
      STATE_UNTRANSFORM:
        if initState then
          initState = 0
          me.animation = untransformAnim
          me.attackMasks = untransformAttMembers
          me.defenseMasks = untransformDefMembers
          g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_TRANSFORMBACK, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge > 1 then
          me.animation.advance()
        end if
        if me.animation.isDone() then
          me.owner.setVel(0.0, 0.0)
          me.moveDone = 1
        end if
    end case
  end if
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_RHINOMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.pos + point(75.0 * me.owner.dir, -100.0), me.owner.vel, me.owner.dir))
    g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_RHINOHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
