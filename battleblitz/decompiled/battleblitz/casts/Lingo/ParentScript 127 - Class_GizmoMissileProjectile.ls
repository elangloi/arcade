property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_GIZMO_AIR_MISSILE
  me.stunDuration = 8
  me.visSprite.blend = 85
  vis = [g.MEMBER_0]
  att = [g.assets.GIZMO.GIZMO_MISSILE_PROJECTILE_01A]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.animation.setRepeat(10)
  me.attackMasks = att
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on triggerPayoff me
  if not me.alive then
    return 0
  end if
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    return 1
  end if
end
