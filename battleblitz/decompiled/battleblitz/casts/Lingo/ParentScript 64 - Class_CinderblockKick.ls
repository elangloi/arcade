property ancestor
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_CINDERBLOCK_PUNCH
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_01, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_02, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_03, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_04]
  att = [g.MEMBER_0, g.MEMBER_0, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_03A, g.MEMBER_0]
  def = [g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_01D, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_02D, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_03D, g.assets.CINDERBLOCK.CINDERBLOCK_STOMP_04D]
  order = [1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4]
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
  ancestor.update()
  if me.age = 10 then
    g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, me.owner.pos + point(80.0 * me.owner.dir, 0.0), point(5.0 * me.owner.dir, 0.0), -me.owner.dir))
    g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, me.owner.pos + point(-40.0 * me.owner.dir, 0.0), point(-5.0 * me.owner.dir, 0.0), me.owner.dir))
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_WALL_SLAM, 100, g.SFX_EVENT_PRIORITY_LOW)
  end if
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitHorizBurstEffect, me.owner, me.owner.pos + point(80.0 * me.owner.dir, -30.0), point(0, 0), 1))
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_KICK_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
