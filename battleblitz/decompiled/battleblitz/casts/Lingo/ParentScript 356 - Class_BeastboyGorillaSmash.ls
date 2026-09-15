property ancestor, projectile
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(1)
  me.setImmobile(0)
  me.setMelee(1)
  vis = [g.assets.BEASTBOY.BEASTBOY_STAND_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_STAND_01, g.assets.BEASTBOY.BEASTBOY_CROUCH_01, g.assets.BEASTBOY.BEASTBOY_CROUCH_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_APE_TRANSFORM_01, g.assets.BEASTBOY.BEASTBOY_APE_01, g.assets.BEASTBOY.BEASTBOY_APE_02, g.assets.BEASTBOY.BEASTBOY_APE_03, g.assets.BEASTBOY.BEASTBOY_APE_TRANSFORM_03]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.BEASTBOY.BEASTBOY_STAND_01D, g.assets.BEASTBOY.BEASTBOY_STAND_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D, g.assets.BEASTBOY.BEASTBOY_CROUCH_01D, g.assets.BEASTBOY.BEASTBOY_APE_01D, g.assets.BEASTBOY.BEASTBOY_APE_01D, g.assets.BEASTBOY.BEASTBOY_APE_02D, g.assets.BEASTBOY.BEASTBOY_APE_03D, g.assets.BEASTBOY.BEASTBOY_APE_03D]
  order = [1, 2, 3, 4, 3, 4, 5, 6, 5, 6, 6, 6, 6, 6, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 8, 9, 4, 3, 4, 3]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
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
  projectile = VOID
end

on update me
  ancestor.update()
  case me.age of
    1:
      g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_TRANSFORM, 100, g.SFX_EVENT_PRIORITY_LOW)
      g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_GORILLA, 100, g.SFX_EVENT_PRIORITY_LOW)
    10:
      g.main.screen.addEffect(new(g.classes.Class_WhiteBurstReverseEffect, me.owner, me.owner.pos + point(-15.0 * me.owner.dir, -205.0), point(0.0, 0.0), me.owner.dir))
    13:
      me.owner.setShowingTrails(1)
    16:
      me.owner.setShowingTrails(0)
      projectile = new(g.classes.Class_BeastboyWaveProjectile, me.owner, me.owner.pos + point(50 * me.owner.dir, 0), point(0, 0), me.owner.dir)
      g.main.screen.addProjectile(projectile)
      g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, me.owner.pos + point(20.0 * me.owner.dir, 15.0), point(0.0 * me.owner.dir, 0.0), me.owner.dir))
    25:
      g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_TRANSFORMBACK, 100, g.SFX_EVENT_PRIORITY_LOW)
  end case
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitHorizBurstEffect, me.owner, me.owner.pos + point(74.0 * me.owner.dir, -52.0), point(0, 0), me.owner.dir))
    g.main.audioMgr.playSound(g.assets.BEASTBOY.SFX_BEASTBOY_GORILLAHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
