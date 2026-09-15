property ancestor, needInit
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_MAMMOTH_GROUND_PUNCH
  me.stunDuration = 10
  needInit = 1
  vis = [g.MEMBER_0]
  att = [g.assets.MAMMOTH.MAMMOTH_WAVE_PROJECTILE_01A]
  me.animation = new(g.classes.Class_LoopedAnimation, vis)
  me.attackMasks = att
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on update me
  me.age = me.age + 1
  if me.alive then
    if needInit then
      needInit = 0
      me.setVel(20.0 * me.dir, 0.0)
    end if
    if ((me.age - 1) mod 12) = 0 then
      g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_SHOCKWAVEPUNCH, 100, g.SFX_EVENT_PRIORITY_LOW)
    end if
    if ((me.age - 1) mod 4) = 0 then
      g.main.screen.addEffect(new(g.classes.Class_GroundWaveEffect, me, me.pos, point(0, 0), me.dir))
    end if
    me.setPos(me.pos + me.vel)
    me.visSprite.member = me.animation.getMember()
    me.updateBoundingBoxes()
    if me.isOutOfPlay() then
      me.kill()
    end if
  end if
end

on triggerPayoff me
  if not me.alive then
    return 0
  end if
  me.kill()
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_SHOCKWAVEPUNCHMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me, me.owner.opponent.getPos() + point(0, -80), point(0, 0), me.dir))
    g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_SHOCKWAVEPUNCHHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
