property ancestor, STATE_LAUNCH, STATE_ASCENT, STATE_WAIT, STATE_FALL, STATE_FINISH, moveState, initState, delayFrames, projectile
global g

on new me, owner
  ancestor = new(g.classes.Class_Move, owner)
  me.attackDamage = g.DAMAGE_RAVEN_TELEKINETIC_SPIN
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(1)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.RAVEN.RAVEN_SPECIAL_01, g.assets.RAVEN.RAVEN_SPECIAL_02, g.assets.CHAR_SHARED.RAVEN_SPECIAL_03, g.assets.CHAR_SHARED.RAVEN_SPECIAL_07, g.assets.RAVEN.RAVEN_JUMP_02, g.assets.RAVEN.RAVEN_DUCK_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.RAVEN.RAVEN_SPECIAL_01D, g.assets.RAVEN.RAVEN_SPECIAL_02D, g.assets.RAVEN.RAVEN_SPECIAL_03D, g.assets.RAVEN.RAVEN_SPECIAL_07D, g.assets.RAVEN.RAVEN_JUMP_02D, g.assets.RAVEN.RAVEN_DUCK_01D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_ASCENT = 2
  STATE_WAIT = 3
  STATE_FALL = 4
  STATE_FINISH = 5
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
  if not voidp(projectile) then
    g.game.removeProjectile(projectile)
    projectile = projectile.destroy()
  end if
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  delayFrames = 0
  projectile = VOID
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
      STATE_LAUNCH:
        if initState then
          initState = 0
          delayFrames = 2
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.advanceState()
        end if
      STATE_ASCENT:
        if initState then
          initState = 0
          me.animation.advance()
          g.main.screen.addEffect(new(g.classes.Class_DustSkidEffect, me.owner, me.owner.pos + (40 * me.owner.pos), point(0, 0), me.owner.dir))
          g.main.screen.addEffect(new(g.classes.Class_DustSkidEffect, me.owner, me.owner.pos - (40 * me.owner.pos), point(0, 0), -me.owner.dir))
          delayFrames = 6
          me.owner.setOnGround(0)
          g.main.audioMgr.playSound(g.assets.RAVEN.SFX_RAVEN_FLOATUP, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        me.owner.moveBy(0.0, -7.0)
        if delayFrames = 4 then
          me.animation.advance()
        else
          if delayFrames = 2 then
            g.game.addEffect(new(g.classes.Class_RavenSwirlEffect, me.owner, me.owner.pos + point(0.0, -110.0), point(0, 0), me.owner.dir))
            g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_RAVEN_VORTEX, 100, g.SFX_EVENT_PRIORITY_LOW)
            projectile = new(g.classes.Class_RavenTelekineticSpinProjectile, me.owner, me.owner.pos + point(0.0, -20.0), point(0, 0), me.owner.dir)
            g.game.addProjectile(projectile)
          end if
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.advanceState()
        end if
      STATE_WAIT:
        if initState then
          initState = 0
          me.owner.moveBy(0.0, -7.0)
          me.animation.advance()
          delayFrames = 12
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.advanceState()
        end if
      STATE_FALL:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 2
          g.game.removeProjectile(projectile)
          projectile = projectile.destroy()
          g.main.audioMgr.playSound(g.assets.RAVEN.SFX_RAVEN_FLOATDOWN, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        me.owner.accelerate(g.gravity)
        if me.owner.fallCheck() then
          me.owner.setVel(0.0, 0.0)
          advanceState()
        end if
      STATE_FINISH:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setOnGround(1)
          delayFrames = 4
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_LANDING_SMALL_PERSON, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.moveDone = 1
        end if
    end case
  end if
end
