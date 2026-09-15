property ancestor, STATE_TRANSFORM, STATE_FLY, STATE_ATTACK, STATE_UNTRANSFORM, moveState, initState, stateAge, transformAnim, transformAttMembers, transformDefMembers, attackAnim, attackAttMembers, attackDefMembers, untransformAnim, untransformAttMembers, untransformDefMembers
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_BEASTBOY_PTERODACTYL_SWOOP
  me.stunDuration = 10
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.BEASTBOY.BEASTBOY_STAND_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_STAND_01, g.assets.BEASTBOY.BEASTBOY_CROUCH_01, g.assets.BEASTBOY.BEASTBOY_CROUCH_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_PTERODACTYL_TRANSFORM_01, g.assets.CHAR_SHARED.BEASTBOY_PTERODACTYL_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.BEASTBOY.BEASTBOY_STAND_01D, g.assets.BEASTBOY.BEASTBOY_STAND_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D, g.assets.BEASTBOY.BEASTBOY_PTERODACTYL_01D, g.assets.BEASTBOY.BEASTBOY_PTERODACTYL_01D]
  order = [1, 2, 3, 4, 3, 4, 5, 6, 5, 6]
  transformVisMembers = vis
  transformAttMembers = att
  transformDefMembers = def
  transformAnim = new(g.classes.Class_IndexedAnimation, transformVisMembers, order)
  vis = [g.assets.CHAR_SHARED.BEASTBOY_PTERODACTYL_02, g.assets.CHAR_SHARED.BEASTBOY_PTERODACTYL_03]
  att = [g.assets.BEASTBOY.BEASTBOY_PTERODACTYL_02A, g.assets.BEASTBOY.BEASTBOY_PTERODACTYL_02A]
  def = [g.assets.BEASTBOY.BEASTBOY_PTERODACTYL_02D, g.assets.BEASTBOY.BEASTBOY_PTERODACTYL_02D]
  attackVisMembers = vis
  attackAttMembers = att
  attackDefMembers = def
  attackAnim = new(g.classes.Class_PlayOnceAnimation, attackVisMembers)
  vis = [g.assets.BEASTBOY.BEASTBOY_PTERODACTYL_TRANSFORM_02, g.assets.CHAR_SHARED.BEASTBOY_PTERODACTYL_02, g.assets.BEASTBOY.BEASTBOY_JUMP_TRANSFORM_02, g.assets.BEASTBOY.BEASTBOY_JUMP_02]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D, g.assets.BEASTBOY.BEASTBOY_RHINO_RUN_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D]
  order = [1, 2, 1, 3, 4, 3, 4]
  untransformVisMembers = vis
  untransformAttMembers = att
  untransformDefMembers = def
  untransformAnim = new(g.classes.Class_IndexedAnimation, untransformVisMembers, order)
  me.animation = transformAnim
  me.attackMasks = transformAttMembers
  me.defenseMasks = transformDefMembers
  STATE_TRANSFORM = 1
  STATE_FLY = 2
  STATE_ATTACK = 3
  STATE_UNTRANSFORM = 4
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
      STATE_FLY:
        if initState then
          initState = 0
          me.animation = attackAnim
          me.attackMasks = attackAttMembers
          me.defenseMasks = attackDefMembers
          me.owner.setOnGround(0)
          me.owner.setShowingTrails(1)
          me.owner.setVel(35.0 * me.owner.dir, 0.0)
          g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_BEASTBOY_PTERODACTYL, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if (stateAge mod 3) = 1 then
          me.animation.advance()
        end if
        if stateAge >= 12 then
          me.setState(STATE_UNTRANSFORM)
        else
          if stateAge > 10 then
            me.owner.setVel(me.owner.getVel() * 0.5)
          else
            me.owner.accelerate(-g.gravity)
          end if
        end if
      STATE_UNTRANSFORM:
        if initState then
          initState = 0
          me.animation = untransformAnim
          me.attackMasks = untransformAttMembers
          me.defenseMasks = untransformDefMembers
          me.owner.setVel(0.0, 0.0)
          g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_TRANSFORMBACK, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge > 1 then
          me.animation.advance()
        end if
        if me.animation.isDone() then
          me.moveDone = 1
        end if
    end case
  end if
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_BLOCK, 100, g.SFX_EVENT_PRIORITY_HIGH)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.pos + point(75.0 * me.owner.dir, -100.0), me.owner.vel, me.owner.dir))
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_LANDING, 100, g.SFX_EVENT_PRIORITY_HIGH)
    return 1
  end if
end
