property ancestor, initState
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_JINX_ENERGY_BALL
  me.stunDuration = 20
  initState = 1
  me.visSprite.blend = 85
  vis = [g.assets.JINX.FX_JINX_ENERGYBALL_12, g.assets.JINX.FX_JINX_ENERGYBALL_13]
  att = [g.assets.JINX.FX_JINX_ENERGYBALL_12A, g.assets.JINX.FX_JINX_ENERGYBALL_12A]
  me.animation = new(g.classes.Class_LoopedAnimation, vis)
  me.attackMasks = att
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on advanceState
  initState = 1
  animState = animState + 1
  stateAge = 0
end

on update me
  me.age = me.age + 1
  if me.alive then
    if initState then
      initState = 0
    end if
    if me.age > 1 then
      me.animation.advance()
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
    g.main.audioMgr.playSound(g.assets.JINX.SFX_JINX_ENERGY_BALL_MISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_JinxBallExplodeEffect, me.owner, me.pos, point(0, 0), me.dir))
    g.main.audioMgr.playSound(g.assets.JINX.SFX_JINX_ENERGY_BALL_HIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
