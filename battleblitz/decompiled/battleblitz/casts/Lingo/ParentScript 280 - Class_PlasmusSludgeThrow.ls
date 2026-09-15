property ancestor, STATE_LAUNCH, STATE_WAIT, STATE_FINISH, moveState, initState, delayFrames, projectile
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
  vis = [g.assets.PLASMUS.PLASMUS_TOSS_01, g.assets.PLASMUS.PLASMUS_TOSS_02, g.assets.PLASMUS.PLASMUS_TOSS_03, g.assets.PLASMUS.PLASMUS_TOSS_04, g.assets.PLASMUS.PLASMUS_TOSS_05, g.assets.PLASMUS.PLASMUS_TOSS_06]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.PLASMUS.PLASMUS_TOSS_01D, g.assets.PLASMUS.PLASMUS_TOSS_02D, g.assets.PLASMUS.PLASMUS_TOSS_03D, g.assets.PLASMUS.PLASMUS_TOSS_04D, g.assets.PLASMUS.PLASMUS_TOSS_05D, g.assets.PLASMUS.PLASMUS_TOSS_06D]
  order = [1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 4, 4, 5, 5, 6]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_WAIT = 2
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
        end if
        if me.age > 1 then
          me.animation.advance()
        end if
        case me.animation.orderIndex of
          3:
            g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_STRETCH_1, 100, g.SFX_EVENT_PRIORITY_LOW)
          10:
            g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_STRETCH_2, 100, g.SFX_EVENT_PRIORITY_LOW)
          18:
            me.advanceState()
        end case
      STATE_WAIT:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 15
          projectile = new(g.classes.Class_PlasmusSludgeProjectile, me.owner, me.owner.pos + point(50 * me.owner.dir, -105), point(15.0 * me.owner.dir, -40.0), me.owner.dir)
          g.main.screen.addProjectile(projectile)
          g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_SLUDGE_THROW, 100, g.SFX_EVENT_PRIORITY_LOW)
          if random(2) = 1 then
            g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_ROAR_BIG, 100, g.SFX_EVENT_PRIORITY_LOW)
          end if
        end if
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          projectile = VOID
          me.moveDone = 1
        end if
    end case
  end if
end
