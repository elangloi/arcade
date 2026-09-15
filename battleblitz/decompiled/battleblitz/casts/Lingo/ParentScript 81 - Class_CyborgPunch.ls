property ancestor, visAnim, visAltAnim
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_CYBORG_PUNCH
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(1)
  vis = [g.assets.CYBORG.CYBORG_PUNCH_01, g.assets.CYBORG.CYBORG_PUNCH_02, g.assets.CYBORG.CYBORG_PUNCH_03, g.assets.CYBORG.CYBORG_PUNCH_04]
  visAlt = [g.assets.CYBORG.CYBORG_PUNCH_ALT_01, g.assets.CYBORG.CYBORG_PUNCH_ALT_02, g.assets.CYBORG.CYBORG_PUNCH_ALT_03, g.assets.CYBORG.CYBORG_PUNCH_ALT_04]
  att = [g.MEMBER_0, g.assets.CYBORG.CYBORG_PUNCH_02A, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.CYBORG.CYBORG_PUNCH_01D, g.assets.CYBORG.CYBORG_PUNCH_02D, g.assets.CYBORG.CYBORG_PUNCH_03D, g.assets.CYBORG.CYBORG_PUNCH_04D]
  order = [1, 1, 2, 2, 2, 2, 3, 3, 4, 4]
  visAnim = new(g.classes.Class_IndexedAnimation, vis, order)
  visAltAnim = new(g.classes.Class_IndexedAnimation, visAlt, order)
  me.animation = visAnim
  me.attackMasks = att
  me.defenseMasks = def
  return me
end

on reset me, arg
  ancestor.reset()
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
  me.dirChanged()
end

on dirChanged me
  if me.owner.dir > 0 then
    me.animation = visAnim
  else
    me.animation = visAltAnim
  end if
  me.animation.reset()
end

on update me
  ancestor.update()
  if me.age = 1 then
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_WOOSH, 100, g.SFX_EVENT_PRIORITY_LOW)
  end if
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.pos + point(120.0 * me.owner.dir, -105.0), point(0, 0), me.owner.dir))
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
