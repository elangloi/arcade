property ancestor
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_PLASMUS_PUNCH
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.PLASMUS.PLASMUS_PUNCH_01, g.assets.PLASMUS.PLASMUS_PUNCH_02, g.assets.PLASMUS.PLASMUS_PUNCH_03]
  att = [g.MEMBER_0, g.assets.PLASMUS.PLASMUS_PUNCH_02A, g.MEMBER_0]
  def = [g.assets.PLASMUS.PLASMUS_PUNCH_01D, g.assets.PLASMUS.PLASMUS_PUNCH_02D, g.assets.PLASMUS.PLASMUS_PUNCH_03D]
  order = [1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on reset me, arg
  ancestor.reset()
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on update me
  me.age = me.age + 1
  if me.age = 1 then
    g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_STRETCH_1, 100, g.SFX_EVENT_PRIORITY_LOW)
  else
    if me.age = 4 then
      g.main.screen.addEffect(new(g.classes.Class_PlasmusPunchTrailsEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
    end if
  end if
  if me.age > 1 then
    me.animation.advance()
  end if
  me.moveDone = me.animation.isDone()
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_STRETCHMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitHorizBurstEffect, me.owner, me.owner.pos + point(100.0 * me.owner.dir, -40.0), point(0, 0), me.owner.dir))
    g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_PUNCH_HIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
