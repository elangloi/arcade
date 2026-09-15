property ancestor, STATE_LAUNCH, STATE_BOB, STATE_CONJURE, STATE_ATTACK, STATE_FINISH, moveState, initState, stateAge, projectile, effect, launchHeight, boltLaunchVel, boltRightLaunchOffset, boltLeftLaunchOffset, boltRightConjureOffset, boltLeftConjureOffset, groundHitPos
global g

on new me, owner
  ancestor = new(g.classes.Class_Move, owner)
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  vis = [g.assets.CHAR_SHARED.STARFIRE_FLOAT_UP_01, g.assets.CHAR_SHARED.STARFIRE_ATTACK_01, g.assets.CHAR_SHARED.STARFIRE_ATTACK_02, g.assets.CHAR_SHARED.STARFIRE_ATTACK_03, g.assets.CHAR_SHARED.STARFIRE_ATTACK_04, g.assets.STARFIRE.STARFIRE_FALL_02]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.STARFIRE.STARFIRE_FLOAT_UP_01D, g.assets.STARFIRE.STARFIRE_ATTACK_01D, g.assets.STARFIRE.STARFIRE_ATTACK_02D, g.assets.STARFIRE.STARFIRE_ATTACK_03D, g.assets.STARFIRE.STARFIRE_ATTACK_04D, g.assets.STARFIRE.STARFIRE_FALL_02D]
  order = [1, 2, 3, 3, 4, 5, 2, 3, 4, 5, 2, 6]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_BOB = 2
  STATE_CONJURE = 3
  STATE_ATTACK = 4
  STATE_FINISH = 5
  moveState = 1
  initState = 1
  stateAge = 0
  launchHeight = -180.0
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
  stateAge = 0
  projectile = VOID
  effect = VOID
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on stop me
  ancestor.stop()
  if not voidp(effect) then
    g.game.killEffect(effect)
    effect = VOID
  end if
  if not voidp(projectile) then
    g.game.killProjectile(projectile)
    projectile = VOID
  end if
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
          me.owner.setOnGround(0)
        end if
        me.owner.moveBy(0.0, -30.0)
        if me.owner.getPosY() <= launchHeight then
          me.owner.setPosY(launchHeight)
          advanceState()
        end if
      STATE_BOB:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setHovering(1)
        end if
        if stateAge >= 10 then
          advanceState()
        end if
      STATE_CONJURE:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setHovering(0)
          me.setImmobile(1)
          boltLaunchVel = point(20.0 * me.owner.dir, 25.0)
          boltRightLaunchOffset = point(53.0 * me.owner.dir, -88.0)
          boltLeftLaunchOffset = point(66.0 * me.owner.dir, -96.0)
          boltRightConjureOffset = point(-50.0 * me.owner.dir, -150.0)
          boltLeftConjureOffset = point(0.0, -180.0)
          p = me.owner.pos + boltRightLaunchOffset
          groundHitPos = point(p.locH + (boltLaunchVel.locH * -p.locV / boltLaunchVel.locV), 0.0)
          effect = new(g.classes.Class_StarfireBoltGlowEffect, me.owner, me.owner.pos + boltRightConjureOffset, point(0, 0), me.owner.dir)
          g.main.screen.addEffect(effect)
          g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_STARFIRE_MAKINGSTARBOLT, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if stateAge = 4 then
          advanceState()
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
        end if
        case stateAge of
          1:
            me.animation.advance()
            effect = new(g.classes.Class_StarfireBoltRightHandEffect, me.owner, me.owner.pos + boltRightConjureOffset, point(0.0, 0.0), me.owner.dir)
            g.main.screen.addEffect(effect)
          3:
            me.animation.advance()
            g.main.screen.addProjectile(new(g.classes.Class_StarfireBoltProjectile, me.owner, me.owner.pos + boltRightLaunchOffset, boltLaunchVel, me.owner.dir))
            g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_STARFIRE_BOLT_BARRAGE, 100, g.SFX_EVENT_PRIORITY_LOW)
          6:
            me.animation.advance()
            effect = new(g.classes.Class_StarfireBoltLeftHandEffect, me.owner, me.owner.pos + boltLeftConjureOffset, point(0.0, 0.0), me.owner.dir)
            g.main.screen.addEffect(effect)
          9:
            me.animation.advance()
            g.main.screen.addProjectile(new(g.classes.Class_StarfireBoltProjectile, me.owner, me.owner.pos + boltLeftLaunchOffset, boltLaunchVel, me.owner.dir))
          10:
            g.main.screen.addEffect(new(g.classes.Class_StarfireExplodeEffect, me.owner, groundHitPos + point(0.0, -20.0), point(0, 0), me.owner.dir))
            g.main.screen.addEffect(new(g.classes.Class_StarfireColumnEffect, me.owner, groundHitPos, point(0, 0), me.owner.dir))
            projectile = new(g.classes.Class_StarfireBoltExplosionProjectile, me.owner, groundHitPos, point(0.0, 0.0), me.owner.dir)
            g.main.screen.addProjectile(projectile)
          12:
            me.animation.advance()
            effect = new(g.classes.Class_StarfireBoltRightHandEffect, me.owner, me.owner.pos + boltRightConjureOffset, point(0.0, 0.0), me.owner.dir)
            g.main.screen.addEffect(effect)
          15:
            me.animation.advance()
            g.main.screen.addProjectile(new(g.classes.Class_StarfireBoltProjectile, me.owner, me.owner.pos + boltRightLaunchOffset, boltLaunchVel, me.owner.dir))
            g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_STARFIRE_BOLT_BARRAGE, 100, g.SFX_EVENT_PRIORITY_LOW)
          16:
            g.main.screen.addEffect(new(g.classes.Class_StarfireExplodeEffect, me.owner, groundHitPos + point(60.0 * me.owner.dir, -30.0), point(0, 0), me.owner.dir))
          18:
            me.animation.advance()
            effect = new(g.classes.Class_StarfireBoltLeftHandEffect, me.owner, me.owner.pos + boltLeftConjureOffset, point(0.0, 0.0), me.owner.dir)
            g.main.screen.addEffect(effect)
          21:
            me.animation.advance()
            g.main.screen.addProjectile(new(g.classes.Class_StarfireBoltProjectile, me.owner, me.owner.pos + boltLeftLaunchOffset, boltLaunchVel, me.owner.dir))
          22:
            g.main.screen.addEffect(new(g.classes.Class_StarfireExplodeEffect, me.owner, groundHitPos + point(-50.0 * me.owner.dir, -5.0), point(0, 0), me.owner.dir))
          27:
            g.main.screen.addEffect(new(g.classes.Class_StarfireExplodeEffect, me.owner, groundHitPos + point(10.0 * me.owner.dir, -25.0), point(0, 0), me.owner.dir))
          29:
            g.game.killProjectile(projectile)
            projectile = VOID
            advanceState()
        end case
      STATE_FINISH:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setHovering(0)
          me.setImmobile(0)
        end if
        me.owner.accelerate(g.gravity * 0.5)
        if me.owner.fallCheck() then
          me.owner.setOnGround(1)
          me.owner.setVel(0.0, 0.0)
          me.moveDone = 1
        end if
    end case
  end if
end
