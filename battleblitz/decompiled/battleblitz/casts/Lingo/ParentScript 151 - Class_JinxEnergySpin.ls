property ancestor, projectile
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Move, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_JINX_ENERGY_SPIN
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.JINX.JINX_JUMP_01, g.assets.JINX.JINX_SPIN_01, g.assets.JINX.JINX_SPIN_02, g.assets.JINX.JINX_SPIN_03, g.assets.JINX.JINX_SPIN_04, g.assets.JINX.JINX_SPIN_05, g.assets.JINX.JINX_JUMP_06]
  att = [g.MEMBER_0, g.MEMBER_0, g.assets.JINX.JINX_SPIN_02A, g.assets.JINX.JINX_SPIN_03A, g.assets.JINX.JINX_SPIN_04A, g.assets.JINX.JINX_SPIN_05A, g.MEMBER_0]
  def = [g.assets.JINX.JINX_JUMP_01D, g.assets.JINX.JINX_SPIN_01D, g.assets.JINX.JINX_SPIN_02D, g.assets.JINX.JINX_SPIN_03D, g.assets.JINX.JINX_SPIN_04D, g.assets.JINX.JINX_SPIN_05D, g.assets.JINX.JINX_JUMP_06D]
  order = [1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 7]
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
  if me.age > 1 then
    me.animation.advance()
  end if
  me.moveDone = me.animation.isDone()
  if me.age = 1 then
    g.main.audioMgr.playSound(g.assets.JINX.SFX_JINX_ENERGY_SPIN, 100, g.SFX_EVENT_PRIORITY_LOW)
  else
    if me.age = 8 then
      g.main.screen.addEffect(new(g.classes.Class_JinxEnergySpinEffect, me.owner, me.owner.pos + point(0.0, -70.0), point(0, 0), me.owner.dir))
    end if
  end if
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    return 1
  end if
end
