property ancestor, needInit, shadow
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_PLASMUS_SLUDGE_THROW
  me.stunDuration = 10
  needInit = 1
  vis = [g.assets.PLASMUS.PLASMUS_GLOBULE_02]
  att = [g.assets.PLASMUS.PLASMUS_GLOBULE_02A]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  shadow = new(g.classes.Class_Shadow, me, 50)
  return me
end

on destroy me
  ancestor.destroy()
  shadow.destroy()
  return VOID
end

on update me
  me.age = me.age + 1
  if me.alive then
    if needInit then
      needInit = 0
      g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_GLOBULEWOOSH, 100, g.SFX_EVENT_PRIORITY_LOW)
    end if
    me.accelerate(g.gravity)
    me.setPos(me.pos + me.vel)
    if me.isOutOfPlay() then
      me.kill()
    else
      if me.getPosY() >= 0.0 then
        me.setPosY(0.0)
        me.setVel(0.0, 0.0)
        g.main.screen.addProjectile(new(g.classes.Class_PlasmusSludgeSplatProjectile, me.owner, me.pos, point(0, 0), me.dir))
        g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_GLOBULEMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
        g.game.hud.flashScreen(1)
        me.kill()
      end if
    end if
    me.visSprite.member = me.animation.getMember()
    me.updateBoundingBoxes()
    shadow.update()
  end if
end

on paint me
  ancestor.paint()
  shadow.paint()
end

on triggerPayoff me
  if not me.alive then
    return 0
  end if
  me.kill()
  g.main.screen.addEffect(new(g.classes.Class_PlasmusSplatEffect, me.owner, me.owner.opponent.pos + point(0.0, -100.0), point(0, 0), me.dir))
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_GLOBULEMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.game.hud.flashScreen(1)
    g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_GLOBULEHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
