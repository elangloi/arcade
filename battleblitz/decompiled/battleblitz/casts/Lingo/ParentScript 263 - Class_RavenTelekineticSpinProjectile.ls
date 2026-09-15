property ancestor, leftObj, rightObj, leftObjOffset, rightObjOffset, shadow, needInit, centerPos, trail1, trail2, loopOffsets
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_RAVEN_TELEKINETIC_SPIN
  me.stunDuration = 10
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
  me.attackMasks = att
  loopOffsets = [point(0.0, 35.0), point(72.0, 31.0), point(118.0, 16.0), point(128.0, -4.0), point(107.0, -21.0), point(60.0, -32.0), point(0.0, -35.0), point(-60, -32.0), point(-107.0, -21.0), point(-128.0, -4.0), point(-118.0, 16.0), point(-72.0, 31.0)]
  trail1 = new(g.classes.Class_StaticActor, vis[1], g.SPRITE_LOCZ_EFFECTS_FOREGROUND, me.pos, initVel, initDir)
  trail1.visSprite.ink = g.INK_BGTRANSPARENT
  trail1.visSprite.blend = 60
  trail2 = new(g.classes.Class_StaticActor, vis[1], g.SPRITE_LOCZ_EFFECTS_FOREGROUND, me.pos, initVel, initDir)
  trail2.visSprite.ink = g.INK_BGTRANSPARENT
  trail2.visSprite.blend = 20
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  shadow = new(g.classes.Class_Shadow, me, 150)
  centerPos = initPos
  needInit = 1
  return me
end

on destroy me
  ancestor.destroy()
  trail1.destroy()
  trail2.destroy()
  shadow.destroy()
  return VOID
end

on getLoopOffset me, index
  i = index - 1
  if i <= 0 then
    i = loopOffsets.count - i
  end if
  if me.dir > 0 then
    return loopOffsets[(i mod loopOffsets.count) + 1]
  else
    return loopOffsets[loopOffsets.count - (i mod loopOffsets.count)]
  end if
end

on update me
  me.age = me.age + 1
  if me.alive then
    if needInit then
      needInit = 0
    end if
    me.setPos(centerPos + me.getLoopOffset(me.age))
    trail1.setPos(centerPos + me.getLoopOffset(me.age - 1))
    trail2.setPos(centerPos + me.getLoopOffset(me.age - 2))
    me.visSprite.member = me.animation.getMember()
    me.updateBoundingBoxes()
    shadow.update()
  end if
end

on paint me
  ancestor.paint()
  shadow.paint()
  trail1.paint()
  trail2.paint()
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
    g.main.screen.addEffect(new(g.classes.Class_RavenExplodeEffect, me.owner, me.owner.opponent.pos + point(20.0 * -me.owner.dir, -60.0), point(0, 0), me.dir))
    g.main.audioMgr.playSound(g.assets.RAVEN.SFX_RAVEN_LEVITATEDOBJECTSHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
