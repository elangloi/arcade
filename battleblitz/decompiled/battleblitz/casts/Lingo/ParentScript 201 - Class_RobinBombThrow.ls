property ancestor, STATE_LAUNCH, STATE_WAIT, STATE_FINISH, moveState, initState, delayFrames, projectile
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Move, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_ROBIN_DISC_THROW
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(1)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.ROBIN.ROBIN_THROW_01, g.assets.ROBIN.ROBIN_THROW_02, g.assets.ROBIN.ROBIN_BOMBTHROW_03, g.assets.ROBIN.ROBIN_BOMBTHROW_04, g.assets.ROBIN.ROBIN_BOMBTHROW_05, g.assets.ROBIN.ROBIN_BOMBTHROW_06, g.assets.ROBIN.ROBIN_BOMBTHROW_07, g.assets.ROBIN.ROBIN_THROW_08, g.assets.ROBIN.ROBIN_THROW_09]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.ROBIN.ROBIN_THROW_01D, g.assets.ROBIN.ROBIN_THROW_02D, g.assets.ROBIN.ROBIN_BOMBTHROW_03D, g.assets.ROBIN.ROBIN_BOMBTHROW_03D, g.assets.ROBIN.ROBIN_BOMBTHROW_03D, g.assets.ROBIN.ROBIN_BOMBTHROW_03D, g.assets.ROBIN.ROBIN_BOMBTHROW_03D, g.assets.ROBIN.ROBIN_BOMBTHROW_03D, g.assets.ROBIN.ROBIN_BOMBTHROW_03D]
  order = [1, 2, 3, 4, 5, 6, 6, 7, 8, 9]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_WAIT = 2
  STATE_FINISH = 3
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
      STATE_LAUNCH:
        if initState then
          initState = 0
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_WOOSH, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if me.age > 1 then
          me.animation.advance()
        end if
        if me.animation.orderIndex = 8 then
          advanceState()
        end if
      STATE_WAIT:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 10
          projectile = new(g.classes.Class_RobinBombProjectile, me.owner, me.owner.pos + point(80 * me.owner.dir, -40), point(0, 0), me.owner.dir)
          g.main.screen.addProjectile(projectile)
          g.main.audioMgr.playSound(g.assets.ROBIN.SFX_ROBIN_BOMB_FLYING, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          projectile = VOID
          advanceState()
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
