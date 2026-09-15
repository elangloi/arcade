property STATE_WAIT, STATE_FLY, STATE_ATTACK, ancestor, animState, initState, stateAge, delayFrames, bgEffect, shadow, trails
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  STATE_WAIT = 1
  STATE_FLY = 2
  STATE_ATTACK = 3
  initState = 1
  animState = 1
  stateAge = 0
  vis = [g.assets.CHAR_SHARED.BEASTBOY_PTERODACTYL_01, g.assets.CHAR_SHARED.BEASTBOY_PTERODACTYL_02, g.assets.CHAR_SHARED.BEASTBOY_PTERODACTYL_03]
  order = [1, 2, 3, 2, 3, 2]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.visSprite.blend = 100
  shadow = new(g.classes.Class_Shadow, me, 100)
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
          targetPos = point(targetX, targetY) - point(20.0 * me.dir, -20.0)
          me.setPos(targetPos - point(600.0 * me.dir, 0.0))
        end if
        if stateAge = 10 then
          me.advanceState()
        end if
      STATE_FLY:
        if initState then
          initState = 0
          me.setVel(30.0 * me.dir, -11.0)
        end if
        me.accelerate(point(0.0, 1.0))
        trails.update(me)
        if stateAge = 8 then
          g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_BEASTBOY_PTERODACTYL, 100, g.SFX_EVENT_PRIORITY_LOW)
        else
          if stateAge = 17 then
            me.animation.advance()
          else
            if stateAge = 20 then
              me.advanceState()
            end if
          end if
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
          me.setVel(0.0, 0.0)
        end if
        trails.update(VOID)
        case me.stateAge of
          1:
            damage = me.owner.opponent.reactToCollision(me.owner.opponent.HEALTH_MAX * g.SUMMON_DAMAGE_PERCENT / 100)
            me.owner.awardPoints(damage)
            me.animation.advance()
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.pos + point(66.0 * me.dir, -93.0), point(0, 0), me.dir))
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          5:
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.pos + point(66.0 * me.dir, -93.0), point(0, 0), me.dir))
          7:
            me.animation.advance()
            g.game.hud.flashScreen(2)
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          11:
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.pos + point(66.0 * me.dir, -93.0), point(0, 0), me.dir))
          13:
            me.animation.advance()
            g.game.hud.flashScreen(2)
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          15:
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.pos + point(66.0 * me.dir, -93.0), point(0, 0), me.dir))
          20:
            me.animation.advance()
            g.game.hud.flashScreen(2)
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
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
