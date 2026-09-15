property ancestor, needInit, shadow
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_ROBIN_DISC_THROW
  me.stunDuration = 10
  needInit = 1
  vis = [g.assets.ROBIN.ROBIN_DISC_01, g.assets.ROBIN.ROBIN_DISC_02, g.assets.ROBIN.ROBIN_DISC_03, g.assets.ROBIN.ROBIN_DISC_04]
  att = [g.assets.ROBIN.ROBIN_DISC_04A, g.assets.ROBIN.ROBIN_DISC_04A, g.assets.ROBIN.ROBIN_DISC_04A, g.assets.ROBIN.ROBIN_DISC_04A]
  order = [1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
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
      me.setVel(25.0 * me.dir, 0.0)
      g.main.audioMgr.playSound(g.assets.ROBIN.SFX_ROBIN_DISK_FLYING, 100, g.SFX_EVENT_PRIORITY_LOW)
    end if
    me.setPos(me.pos + me.vel)
    if me.isOutOfPlay() then
      me.kill()
    end if
    if me.age > 1 then
      me.animation.advance()
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
  g.main.audioMgr.stopSound(g.assets.ROBIN.SFX_ROBIN_DISK_FLYING)
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.ROBIN.SFX_ROBIN_DISK_BLOCKED, 50, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_RobinDiscExplodeEffect, me.owner, me.pos, point(0, 0), me.dir))
    g.main.audioMgr.playSound(g.assets.ROBIN.SFX_ROBIN_DISK_EXPLODE, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
