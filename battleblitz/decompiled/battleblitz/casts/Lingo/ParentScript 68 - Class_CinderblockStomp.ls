property ancestor, STATE_WIND_UP_1, STATE_WIND_UP_2, STATE_ATTACK, STATE_FINISH, moveState, initState, delayFrames, projectile
global g

on new me, owner
  ancestor = new(g.classes.Class_Move, owner)
  me.attackDamage = g.DAMAGE_CINDERBLOCK_STOMP
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_01, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_02, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_03, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_04]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_01D, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_02D, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_03D, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_04D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_WIND_UP_1 = 1
  STATE_WIND_UP_2 = 2
  STATE_ATTACK = 3
  STATE_FINISH = 4
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
      STATE_WIND_UP_1:
        if initState then
          initState = 0
          delayFrames = 3
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_WIND_UP_2:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 10
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        else
          if delayFrames = 8 then
            g.main.screen.addEffect(new(g.classes.Class_CinderblockEnergyEffect, me.owner, me.owner.pos + point(58 * me.owner.dir, -73), point(0, 0), me.owner.dir))
            g.main.screen.addEffect(new(g.classes.Class_WhiteBurstEffect, me.owner, me.owner.pos + point(58 * me.owner.dir, -73), point(0, 0), me.owner.dir))
          end if
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 10
          projectile = new(g.classes.Class_CinderblockWaveProjectile, me.owner, me.owner.pos + point(100 * me.owner.dir, 0), point(0, 0), me.owner.dir)
          g.main.screen.addProjectile(projectile)
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_LANDING_BIG_PERSON, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
          projectile = VOID
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
