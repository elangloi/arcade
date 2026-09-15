property STATE_WAIT, STATE_FLY, STATE_ATTACK, ancestor, animState, initState, stateAge, bgEffect, shadow, trails
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  STATE_WAIT = 1
  STATE_FLY = 2
  STATE_ATTACK = 3
  initState = 1
  animState = 1
  stateAge = 0
  vis = [g.assets.CHAR_SHARED.CYBORG_JUMP_PUNCH_01, g.assets.CHAR_SHARED.CYBORG_JUMP_PUNCH_02]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
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
          targetRect = me.owner.opponent.getDefenseBox()
          if me.owner.dir > 0 then
            targetX = targetRect.left + (targetRect.width * 0.25)
          else
            targetX = targetRect.right - (targetRect.width * 0.25)
          end if
          targetY = targetRect.bottom - (targetRect.height * 0.65000000000000002)
          targetPos = point(targetX, targetY) + point(-80.0 * me.dir, 50.0)
          me.setPos(targetPos - point(600.0 * 0.68489999999999995 * me.dir, 600.0))
        end if
        if stateAge = 10 then
          me.advanceState()
        end if
      STATE_FLY:
        if initState then
          initState = 0
          g.main.screen.addEffect(new(g.classes.Class_CyborgDiagLinesEffect, me.owner, point(me.getPosX() - (me.owner.dir * me.getPosY() * 0.68489999999999995), 0.0), point(0, 0), me.owner.dir))
          me.setVel(me.owner.dir * 30.0 * 0.68489999999999995, 30.0)
        end if
        trails.update(me)
        if stateAge = 20 then
          me.advanceState()
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
          me.animation.advance()
          me.setVel(0.0, 0.0)
        end if
        trails.update(VOID)
        case me.stateAge of
          1:
            damage = me.owner.opponent.reactToCollision(me.owner.opponent.HEALTH_MAX * g.SUMMON_DAMAGE_PERCENT / 100)
            me.owner.awardPoints(damage)
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.pos + point(100.0 * me.dir, -40.0), point(0, 0), me.dir))
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          5:
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.pos + point(100.0 * me.dir, -40.0), point(0, 0), me.dir))
          7:
            g.game.hud.flashScreen(2)
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          11:
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.pos + point(100.0 * me.dir, -40.0), point(0, 0), me.dir))
          13:
            g.game.hud.flashScreen(2)
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          15:
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.pos + point(100.0 * me.dir, -40.0), point(0, 0), me.dir))
          20:
            g.game.hud.flashScreen(2)
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          21:
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
