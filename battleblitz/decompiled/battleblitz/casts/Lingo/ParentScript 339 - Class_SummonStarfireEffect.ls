property STATE_WAIT, STATE_CONJURE, STATE_ATTACK, ancestor, animState, initState, stateAge, bgEffect, shadow, trails, boltLaunchVel, boltRightLaunchOffset, boltLeftLaunchOffset, boltRightConjureOffset, boltLeftConjureOffset, groundHitPos
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  STATE_WAIT = 1
  STATE_CONJURE = 2
  STATE_ATTACK = 3
  initState = 1
  animState = 1
  stateAge = 0
  vis = [g.assets.CHAR_SHARED.STARFIRE_FLOAT_UP_01, g.assets.CHAR_SHARED.STARFIRE_ATTACK_01, g.assets.CHAR_SHARED.STARFIRE_ATTACK_02, g.assets.CHAR_SHARED.STARFIRE_ATTACK_03, g.assets.CHAR_SHARED.STARFIRE_ATTACK_04]
  order = [1, 2, 3, 3, 4, 5, 2, 3, 4, 5, 2, 1]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.visSprite.blend = 100
  shadow = new(g.classes.Class_Shadow, me, 130)
  trails = new(g.classes.Class_ActorTrails, 4, g.SPRITE_LOCZ_EFFECTS_BACKGROUND)
  return me
end

on destroy me
  ancestor.destroy()
  if objectp(shadow) then
    shadow.destroy()
  end if
  if objectp(bgEffect) then
    bgEffect.destroy()
  end if
  if objectp(trails) then
    trails.destroy()
  end if
  return VOID
end

on advanceState
  initState = 1
  animState = animState + 1
  stateAge = 0
end

on update me
  me.age = me.age + 1
  stateAge = stateAge + 1
  if me.alive then
    case animState of
      STATE_WAIT:
        if initState then
          initState = 0
          bgEffect = new(g.classes.Class_BgBarsTitanEffect, me.owner, point(0, 0), point(0, 0), me.dir)
          g.main.screen.addEffect(bgEffect)
          boltLaunchVel = point(20.0 * me.dir, 25.0)
          boltRightLaunchOffset = point(53.0 * me.dir, -88.0)
          boltLeftLaunchOffset = point(66.0 * me.dir, -96.0)
          boltRightConjureOffset = point(-50.0 * me.dir, -150.0)
          boltLeftConjureOffset = point(0.0, -180.0)
          targetX = me.owner.opponent.getPosX()
          targetY = me.owner.opponent.getPosY()
          targetPos = point(targetX, 0.0)
          launchHeight = -130
          boltStartY = launchHeight + boltRightLaunchOffset.locV
          boltStartX = targetX - (boltLaunchVel.locH * abs(boltStartY / boltLaunchVel.locV))
          attackPos = point(boltStartX, boltStartY) - boltRightLaunchOffset
          startPos = attackPos + point(-275.0 * me.dir, 146.0)
          me.setPos(startPos)
        end if
        trails.update(me)
        case stateAge of
          1:
            me.moveBy(me.dir * 50.0, -1.0)
          2:
            me.moveBy(me.dir * 45.0, -3.0)
          3:
            me.moveBy(me.dir * 40.0, -5.0)
          4:
            me.moveBy(me.dir * 35.0, -7.0)
          5:
            me.moveBy(me.dir * 30.0, -9.0)
          6:
            me.moveBy(me.dir * 25.0, -12.0)
          7:
            me.moveBy(me.dir * 20.0, -16.0)
          8:
            me.moveBy(me.dir * 15.0, -23.0)
          9:
            me.moveBy(me.dir * 10.0, -30.0)
          10:
            me.moveBy(me.dir * 5.0, -40.0)
            me.advanceState()
        end case
      STATE_CONJURE:
        if initState then
          initState = 0
          me.animation.advance()
          boltLaunchVel = point(20.0 * me.dir, 25.0)
          boltRightLaunchOffset = point(53.0 * me.dir, -88.0)
          boltLeftLaunchOffset = point(66.0 * me.dir, -96.0)
          boltRightConjureOffset = point(-50.0 * me.dir, -150.0)
          boltLeftConjureOffset = point(0.0, -180.0)
          p = me.pos + boltRightLaunchOffset
          groundHitPos = point(p.locH + (boltLaunchVel.locH * -p.locV / boltLaunchVel.locV), 0.0)
          effect = new(g.classes.Class_StarfireBoltGlowEffect, me.owner, me.pos + boltRightConjureOffset, point(0, 0), me.dir)
          g.main.screen.addEffect(effect)
          g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_STARFIRE_MAKINGSTARBOLT, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        trails.update(VOID)
        if stateAge = 4 then
          advanceState()
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
        end if
        trails.update(VOID)
        case stateAge of
          1:
            me.animation.advance()
            effect = new(g.classes.Class_StarfireBoltRightHandEffect, me.owner, me.pos + boltRightConjureOffset, point(0.0, 0.0), me.dir)
            g.main.screen.addEffect(effect)
          3:
            me.animation.advance()
            g.main.screen.addProjectile(new(g.classes.Class_StarfireBoltProjectile, me.owner, me.pos + boltRightLaunchOffset, boltLaunchVel, me.dir))
            g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_STARFIRE_BOLT_BARRAGE, 100, g.SFX_EVENT_PRIORITY_LOW)
          6:
            me.animation.advance()
            effect = new(g.classes.Class_StarfireBoltLeftHandEffect, me.owner, me.pos + boltLeftConjureOffset, point(0.0, 0.0), me.dir)
            g.main.screen.addEffect(effect)
          9:
            me.animation.advance()
            g.main.screen.addProjectile(new(g.classes.Class_StarfireBoltProjectile, me.owner, me.pos + boltLeftLaunchOffset, boltLaunchVel, me.dir))
          10:
            damage = me.owner.opponent.reactToCollision(me.owner.opponent.HEALTH_MAX * g.SUMMON_DAMAGE_PERCENT / 100)
            me.owner.awardPoints(damage)
            g.main.screen.addEffect(new(g.classes.Class_StarfireExplodeEffect, me.owner, groundHitPos + point(0.0, -20.0), point(0, 0), me.dir))
            g.main.screen.addEffect(new(g.classes.Class_StarfireColumnEffect, me.owner, groundHitPos, point(0, 0), me.dir))
            g.game.hud.flashScreen(1)
          12:
            me.animation.advance()
            effect = new(g.classes.Class_StarfireBoltRightHandEffect, me.owner, me.pos + boltRightConjureOffset, point(0.0, 0.0), me.dir)
            g.main.screen.addEffect(effect)
          15:
            me.animation.advance()
            g.main.screen.addProjectile(new(g.classes.Class_StarfireBoltProjectile, me.owner, me.pos + boltRightLaunchOffset, boltLaunchVel, me.dir))
            g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_STARFIRE_BOLT_BARRAGE, 100, g.SFX_EVENT_PRIORITY_LOW)
          16:
            g.main.screen.addEffect(new(g.classes.Class_StarfireExplodeEffect, me.owner, groundHitPos + point(60.0 * me.dir, -30.0), point(0, 0), me.dir))
            g.game.hud.flashScreen(1)
          18:
            me.animation.advance()
            effect = new(g.classes.Class_StarfireBoltLeftHandEffect, me.owner, me.pos + boltLeftConjureOffset, point(0.0, 0.0), me.dir)
            g.main.screen.addEffect(effect)
          21:
            me.animation.advance()
            g.main.screen.addProjectile(new(g.classes.Class_StarfireBoltProjectile, me.owner, me.pos + boltLeftLaunchOffset, boltLaunchVel, me.dir))
          22:
            g.main.screen.addEffect(new(g.classes.Class_StarfireExplodeEffect, me.owner, groundHitPos + point(-50.0 * me.dir, -5.0), point(0, 0), me.dir))
            g.game.hud.flashScreen(1)
          24:
            me.animation.advance()
          27:
            g.main.screen.addEffect(new(g.classes.Class_StarfireExplodeEffect, me.owner, groundHitPos + point(10.0 * me.dir, -25.0), point(0, 0), me.dir))
            g.game.hud.flashScreen(1)
          40:
            me.kill()
        end case
    end case
    me.setPos(me.pos + me.vel)
    me.visSprite.member = me.animation.getMember()
    if objectp(shadow) then
      shadow.update()
    end if
  end if
end

on paint me
  ancestor.paint()
  if objectp(shadow) then
    shadow.paint()
  end if
  if objectp(trails) then
    trails.paint()
  end if
end
