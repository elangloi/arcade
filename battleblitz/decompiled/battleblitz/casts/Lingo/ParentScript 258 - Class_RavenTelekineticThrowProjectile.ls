property ancestor, needInit, shadow
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_RAVEN_TELEKINETIC_THROW
  me.stunDuration = 10
  needInit = 1
  case g.villainID of
    g.FIGHTER_ID_JINX:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_TIRE_01]
      att = [g.assets.RAVEN.FX_RAVEN_OBJ_TIRE_01A]
    g.FIGHTER_ID_GIZMO:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_COG_01]
      att = [g.assets.RAVEN.FX_RAVEN_OBJ_COG_01A]
    g.FIGHTER_ID_MAMMOTH:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_IBEAM_SM_01]
      att = [g.assets.RAVEN.FX_RAVEN_OBJ_IBEAM_SM_01A]
    g.FIGHTER_ID_CINDERBLOCK:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_CONCRETE_SM_01]
      att = [g.assets.RAVEN.FX_RAVEN_OBJ_CONCRETE_SM_01A]
    g.FIGHTER_ID_PLASMUS:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_ENGINE_01]
      att = [g.assets.RAVEN.FX_RAVEN_OBJ_ENGINE_01A]
    otherwise:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_TIRE_01]
      att = [g.assets.RAVEN.FX_RAVEN_OBJ_TIRE_01A]
  end case
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  shadow = new(g.classes.Class_Shadow, me, 50)
  return me
end

on destroy me
  ancestor.destroy()
  shadow.destroy()
  return VOID
end

on update me
  me.age = me.age + 1
  if me.alive then
    if needInit then
      needInit = 0
    end if
    me.setPos(me.pos + me.vel)
    if me.isOutOfPlay() then
      me.kill()
    end if
    if me.age > 1 then
      me.animation.advance()
    end if
    me.visSprite.member = me.animation.getMember()
    me.updateBoundingBoxes()
    shadow.update()
  end if
end

on paint me
  ancestor.paint()
  shadow.paint()
end

on triggerPayoff me
  if not me.alive then
    return 0
  end if
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.RAVEN.SFX_RAVEN_LEVITATEDOBJECTSMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_RavenExplodeEffect, me.owner, me.pos, point(0, 0), me.dir))
    g.main.audioMgr.playSound(g.assets.RAVEN.SFX_RAVEN_LEVITATEDOBJECTSHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
