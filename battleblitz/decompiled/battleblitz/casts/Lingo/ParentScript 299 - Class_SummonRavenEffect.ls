property ancestor, STATE_LAUNCH, STATE_ATTACK, STATE_WAIT, animState, initState, stateAge, projectile, destPos, fallPosX, bgEffect, shadow, trails
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.RAVEN_SPECIAL_04, g.assets.CHAR_SHARED.RAVEN_SPECIAL_05, g.assets.CHAR_SHARED.RAVEN_SPECIAL_06, g.assets.CHAR_SHARED.RAVEN_SPECIAL_03, g.assets.CHAR_SHARED.RAVEN_SPECIAL_07]
  order = [3, 1, 2, 3, 4, 5]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.visSprite.blend = 100
  STATE_LAUNCH = 1
  STATE_ATTACK = 2
  STATE_WAIT = 3
  animState = 1
  initState = 1
  stateAge = 0
  shadow = new(g.classes.Class_Shadow, me, 100)
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
      STATE_LAUNCH:
        if initState then
          initState = 0
          bgEffect = new(g.classes.Class_BgBarsTitanEffect, me.owner, point(0, 0), point(0, 0), me.dir)
          g.main.screen.addEffect(bgEffect)
          if me.dir > 0 then
            destPos = point(g.game.scene.getViewRect().left + 120, -125.0)
          else
            destPos = point(g.game.scene.getViewRect().right - 120, -125.0)
          end if
        end if
        case stateAge of
          1:
            me.setPos(destPos + point(-170.0 * me.dir, -131.0))
          2:
            me.setPos(destPos + point(-100.0 * me.dir, -57.0))
          3:
            me.setPos(destPos + point(-30.0 * me.dir, -20.0))
          4:
            me.setPos(destPos + point(0.0, 0.0))
            me.animation.advance()
          6:
            me.animation.advance()
          8:
            me.setPos(destPos + point(-10.0 * me.dir, -9.0))
            me.animation.advance()
          9:
            me.setPos(destPos + point(0.0, 16.0))
            me.animation.advance()
          10:
            me.setPos(destPos + point(0.0, 12.0))
          11:
            me.setPos(destPos + point(0.0, 8.0))
          12:
            me.setPos(destPos + point(0.0, 4.0))
          13:
            me.setPos(destPos + point(0.0, 0.0))
          23:
            me.advanceState()
        end case
      STATE_ATTACK:
        if initState then
          initState = 0
          me.animation.advance()
          g.game.addEffect(new(g.classes.Class_RavenSwirlEffect, me.owner, me.pos + point(0.0, -110.0), point(0, 0), me.owner.dir))
          fallPosX = me.owner.opponent.getPosX() - (200.0 * me.owner.dir)
          projectile = new(g.classes.Class_RavenFallingObjectsProjectile, me.owner, point(fallPosX, -450.0), point(20.0 * me.owner.dir, 45.0), me.owner.dir)
          g.game.addProjectile(projectile)
          projectile.attackDamage = 0
          g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_RAVEN_VORTEX, 100, g.SFX_EVENT_PRIORITY_LOW)
          g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_RAVEN_FLINGOBJECT, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if projectile.explosionAt then
          damage = me.owner.opponent.reactToCollision(me.owner.opponent.HEALTH_MAX * g.SUMMON_DAMAGE_PERCENT / 100)
          me.owner.awardPoints(damage)
          me.advanceState()
        end if
      STATE_WAIT:
        if initState then
          initState = 0
        end if
        if stateAge >= 5 then
          me.kill()
        end if
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
end
