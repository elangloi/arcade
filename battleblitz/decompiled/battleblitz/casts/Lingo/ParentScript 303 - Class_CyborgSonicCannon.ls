property ancestor, STATE_LAUNCH, STATE_WAIT, STATE_FINISH, moveState, initState, stateAge, projectile, visAnim, visAltAnim
global g

on new me, owner
  ancestor = new(g.classes.Class_Move, owner)
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(1)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.CYBORG.CYBORG_CANNON_01, g.assets.CYBORG.CYBORG_CANNON_02, g.assets.CYBORG.CYBORG_CANNON_03]
  visAlt = [g.assets.CYBORG.CYBORG_CANNON_ALT_01, g.assets.CYBORG.CYBORG_CANNON_ALT_02, g.assets.CYBORG.CYBORG_CANNON_ALT_03]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.CYBORG.CYBORG_CANNON_01D, g.assets.CYBORG.CYBORG_CANNON_02D, g.assets.CYBORG.CYBORG_CANNON_03D]
  order = [1, 2, 3, 2, 1]
  visAnim = new(g.classes.Class_IndexedAnimation, vis, order)
  visAltAnim = new(g.classes.Class_IndexedAnimation, visAlt, order)
  me.animation = visAnim
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

on stop me
  ancestor.stop()
  if not voidp(projectile) then
    projectile = projectile.destroy()
  end if
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  stateAge = 0
  projectile = VOID
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
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

on advanceState
  initState = 1
  moveState = moveState + 1
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
          g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_CANNON_OUT, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge = 3 then
          me.animation.advance()
        else
          if stateAge = 6 then
            me.animation.advance()
            g.main.screen.addEffect(new(g.classes.Class_CyborgPowerUpEffect, me.owner, me.owner.pos + point(82 * me.owner.dir, -112), point(0, 0), me.owner.dir))
          else
            if stateAge = 14 then
              advanceState()
            end if
          end if
        end if
      STATE_WAIT:
        if initState then
          initState = 0
          projectile = new(g.classes.Class_CyborgCannonProjectile, me.owner, me.owner.pos + point(82 * me.owner.dir, -112), point(0, 0), me.owner.dir)
          g.main.screen.addProjectile(projectile)
        end if
        if stateAge = 15 then
          projectile.kill()
          projectile = VOID
          advanceState()
        end if
      STATE_FINISH:
        if initState then
          initState = 0
          me.animation.advance()
          g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_CANNON_IN, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge = 4 then
          me.animation.advance()
        else
          if stateAge = 8 then
            me.moveDone = 1
          end if
        end if
    end case
  end if
end
