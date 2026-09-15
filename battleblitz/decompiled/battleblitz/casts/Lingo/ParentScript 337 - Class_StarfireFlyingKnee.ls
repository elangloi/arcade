property ancestor
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_STARFIRE_FLYING_KNEE
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.STARFIRE.STARFIRE_FLYINGKNEE_01, g.assets.STARFIRE.STARFIRE_FLYINGKNEE_02, g.assets.STARFIRE.STARFIRE_FLYINGKNEE_03, g.assets.STARFIRE.STARFIRE_FALL_02]
  att = [g.assets.STARFIRE.STARFIRE_FLYINGKNEE_01A, g.assets.STARFIRE.STARFIRE_FLYINGKNEE_02A, g.assets.STARFIRE.STARFIRE_FLYINGKNEE_03A, g.MEMBER_0]
  def = [g.assets.STARFIRE.STARFIRE_FLYINGKNEE_01D, g.assets.STARFIRE.STARFIRE_FLYINGKNEE_02D, g.assets.STARFIRE.STARFIRE_FLYINGKNEE_03D, g.assets.STARFIRE.STARFIRE_FALL_02D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
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
  me.owner.setOnGround(0)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on update me
  me.age = me.age + 1
  case me.age of
    1:
      g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, me.owner.pos, point(0, 0), me.owner.dir))
      me.owner.setShowingTrails(1)
      me.owner.moveBy(26.0 * me.owner.dir, 0.0)
    2:
      me.owner.moveBy(28.0 * me.owner.dir, 0.0)
    3:
      me.owner.moveBy(28.0 * me.owner.dir, 0.0)
    4:
      me.animation.advance()
      me.owner.moveBy(23.0 * me.owner.dir, 0.0)
    5:
      me.owner.moveBy(36.0 * me.owner.dir, -9.0)
    6:
      me.owner.moveBy(35.0 * me.owner.dir, -18.0)
    7:
      me.animation.advance()
      me.owner.moveBy(30.0 * me.owner.dir, -24.0)
    8:
      me.owner.moveBy(24.0 * me.owner.dir, -32.0)
    9:
      me.owner.moveBy(14.0 * me.owner.dir, -31.0)
    10:
      me.animation.advance()
      me.owner.setShowingTrails(0)
      me.owner.moveBy(-5.0 * me.owner.dir, -25.0)
    11:
      me.owner.moveBy(-9.0 * me.owner.dir, -6.0)
    12:
      me.owner.moveBy(-11.0 * me.owner.dir, -4.0)
    13:
      me.owner.moveBy(-11.0 * me.owner.dir, 5.0)
    14:
      me.owner.moveBy(-9.0 * me.owner.dir, 5.0)
    15:
      me.moveDone = 1
  end case
end

on opponentHit me
  me.hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.pos + point(77.0 * me.owner.dir, -98.0), point(0, 0), me.owner.dir))
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
