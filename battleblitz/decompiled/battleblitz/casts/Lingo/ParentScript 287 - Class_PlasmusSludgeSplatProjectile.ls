property ancestor, needInit
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_PLASMUS_SLUDGE_SPLAT
  me.stunDuration = 10
  needInit = 1
  vis = [g.assets.PLASMUS.PLASMUS_SLUDGE_01, g.assets.PLASMUS.PLASMUS_SLUDGE_02, g.assets.PLASMUS.PLASMUS_SLUDGE_03, g.assets.PLASMUS.PLASMUS_SLUDGE_04, g.assets.PLASMUS.PLASMUS_SLUDGE_05, g.assets.PLASMUS.PLASMUS_SLUDGE_06, g.assets.PLASMUS.PLASMUS_SLUDGE_07, g.assets.PLASMUS.PLASMUS_SLUDGE_08, g.assets.PLASMUS.PLASMUS_SLUDGE_09, g.assets.PLASMUS.PLASMUS_SLUDGE_10, g.assets.PLASMUS.PLASMUS_SLUDGE_11, g.assets.PLASMUS.PLASMUS_SLUDGE_12, g.assets.PLASMUS.PLASMUS_SLUDGE_13, g.assets.PLASMUS.PLASMUS_SLUDGE_14, g.assets.PLASMUS.PLASMUS_SLUDGE_15, g.assets.PLASMUS.PLASMUS_SLUDGE_16]
  att = [g.MEMBER_0, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.assets.PLASMUS.PLASMUS_SLUDGE_01A, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  return me
end

on update me
  me.age = me.age + 1
  if me.alive then
    if needInit then
      needInit = 0
      g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_GLOBULEWOOSH, 100, g.SFX_EVENT_PRIORITY_LOW)
    end if
    if me.age > 1 then
      me.animation.advance()
    end if
    me.visSprite.member = me.animation.getMember()
    me.updateBoundingBoxes()
    if me.animation.isDone() then
      me.kill()
    end if
  end if
end

on triggerPayoff me
  if not me.alive then
    return 0
  end if
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_GLOBULEMISS, 50, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_GLOBULEHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
