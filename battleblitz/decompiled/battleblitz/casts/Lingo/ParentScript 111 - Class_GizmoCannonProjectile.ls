property ancestor, effect
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_GIZMO_CANNON
  me.stunDuration = 8
  me.visSprite.blend = 85
  vis = [g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_01, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_02, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_03, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_04, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_05, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_06]
  att = [g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_01A, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_01A, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_01A, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_01A, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_01A, g.assets.GIZMO.FX_GIZMO_CANNON_SHOT_01A]
  order = [1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  effect = new(g.classes.Class_GizmoCannonBlastEffect, owner, owner.pos + point(28 * owner.dir, -75), point(0, 0), owner.dir)
  g.main.screen.addEffect(effect)
  g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_BACKPACKCANNONSHOOTING, 100, g.SFX_EVENT_PRIORITY_LOW)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on kill me
  ancestor.kill()
  if not voidp(effect) then
    g.game.killEffect(effect)
    effect = VOID
    g.main.audioMgr.stopSound(g.assets.GIZMO.SFX_GIZMO_BACKPACKCANNONSHOOTING)
  end if
end

on triggerPayoff me
  if not me.alive then
    return 0
  end if
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_CANNONMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_GizmoExplodeEffect, me.owner, me.owner.opponent.pos + point(0.0, -75.0), point(0, 0), me.dir))
    g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_CANNONHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
