property ancestor
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_CINDERBLOCK_BACKHAND
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_01, g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_02, g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_03, g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_04, g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_05]
  att = [g.MEMBER_0, g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_02A, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_01D, g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_02D, g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_03D, g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_04D, g.assets.CINDERBLOCK.CINDERBLOCK_BACKHAND_05D]
  order = [1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4]
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
  if me.age = 1 then
    g.main.audioMgr.playSound(g.assets.CINDERBLOCK.SFX_CINDERBLOCK_BACKHANDWOOSH, 100, g.SFX_EVENT_PRIORITY_LOW)
  else
    if (me.age = 7) or (me.age = 9) or (me.age = 11) then
      g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, me.owner.pos + point(80.0 * me.owner.dir, 0.0), point(15.0 * me.owner.dir, 0.0), -me.owner.dir))
    end if
  end if
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.CINDERBLOCK.SFX_CINDERBLOCK_BACKHANDMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.opponent.pos + point(20.0 * -me.owner.dir, -70.0), point(0, 0), me.owner.dir))
    g.main.audioMgr.playSound(g.assets.CINDERBLOCK.SFX_CINDERBLOCK_BACKHANDHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
