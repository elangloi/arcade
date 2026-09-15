property ancestor, leftObj, rightObj, leftObjOffset, rightObjOffset, leftObjVel, rightObjVel, shadow, needInit, explosionAt
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_RAVEN_EXPLOSIVE_DROP
  me.stunDuration = 10
  case g.villainID of
    g.FIGHTER_ID_JINX:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_TIRE_01]
      sideMem = g.assets.CHAR_SHARED.FX_RAVEN_OBJ_HOTDOGCART_01
    g.FIGHTER_ID_GIZMO:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_COG_01]
      sideMem = g.assets.CHAR_SHARED.FX_RAVEN_OBJ_CRATE_01
    g.FIGHTER_ID_MAMMOTH:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_IBEAM_SM_01]
      sideMem = g.assets.CHAR_SHARED.FX_RAVEN_OBJ_IBEAM_LG_01
    g.FIGHTER_ID_CINDERBLOCK:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_CONCRETE_SM_01]
      sideMem = g.assets.CHAR_SHARED.FX_RAVEN_OBJ_CONCRETE_LG_01
    g.FIGHTER_ID_PLASMUS:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_ENGINE_01]
      sideMem = g.assets.CHAR_SHARED.FX_RAVEN_OBJ_MACHINE_01
    otherwise:
      vis = [g.assets.CHAR_SHARED.FX_RAVEN_OBJ_IBEAM_SM_01]
      sideMem = g.assets.CHAR_SHARED.FX_RAVEN_OBJ_IBEAM_LG_01
  end case
  me.attackMasks = [g.assets.RAVEN.FX_RAVEN_FALLING_OBJECTS_01A]
  centerObjOffset = point(-10.0 * me.dir, -60)
  leftObjOffset = point(-90.0 * me.dir, 35.0)
  rightObjOffset = point(110.0 * me.dir, 5.0)
  leftObjVel = me.vel * 1.30000000000000004
  rightObjVel = me.vel * 1.19999999999999996
  me.moveBy(centerObjOffset)
  leftObj = new(g.classes.Class_StaticActor, sideMem, g.SPRITE_LOCZ_EFFECTS_FOREGROUND, me.pos + leftObjOffset, initVel, initDir)
  rightObj = new(g.classes.Class_StaticActor, sideMem, g.SPRITE_LOCZ_EFFECTS_FOREGROUND, me.pos + rightObjOffset, initVel, initDir)
  leftObj.visSprite.ink = g.INK_BGTRANSPARENT
  rightObj.visSprite.ink = g.INK_BGTRANSPARENT
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  shadow = new(g.classes.Class_Shadow, me, 150)
  needInit = 1
  me.armed = 0
  return me
end

on destroy me
  ancestor.destroy()
  leftObj.destroy()
  rightObj.destroy()
  shadow.destroy()
  return VOID
end

on update me
  me.age = me.age + 1
  if me.alive then
    if needInit then
      needInit = 0
      explosionAt = 0
    end if
    me.setPos(me.pos + me.vel)
    if (me.getPosY() >= -90.0) and not explosionAt then
      me.setPosY(0.0)
      me.setVel(0.0, 0.0)
      me.armed = 1
      explosionAt = me.age
      g.main.screen.addEffect(new(g.classes.Class_GroundExplode2Effect, me.owner, me.pos + point(0.0, 10.0), point(0, 0), me.owner.dir))
      g.main.screen.addEffect(new(g.classes.Class_RavenColumnEffect, me.owner, me.pos, point(0, 0), me.owner.dir))
      g.main.audioMgr.playSound(g.assets.CHAR_SHARED.SFX_RAVEN_OBJECTS_HIT_GROUND, 100, g.SFX_EVENT_PRIORITY_LOW)
      g.game.hud.flashScreen(1)
      me.visSprite.visible = 0
      leftObj.visSprite.visible = 0
      rightObj.visSprite.visible = 0
    end if
    me.visSprite.member = me.animation.getMember()
    me.updateBoundingBoxes()
    shadow.update()
    leftObj.moveBy(leftObjVel)
    rightObj.moveBy(rightObjVel)
    if explosionAt then
      if me.age = (explosionAt + 2) then
        g.main.screen.addEffect(new(g.classes.Class_GroundExplode2Effect, me.owner, me.pos + point(-90.0 * me.owner.dir, 5.0), point(0, 0), -me.owner.dir))
      else
        if me.age = (explosionAt + 3) then
          g.main.screen.addEffect(new(g.classes.Class_GroundExplode2Effect, me.owner, me.pos + point(90.0 * me.owner.dir, 0.0), point(0, 0), me.owner.dir))
        else
          if me.age >= (explosionAt + 11) then
            me.kill()
          end if
        end if
      end if
    end if
  end if
end

on paint me
  ancestor.paint()
  shadow.paint()
  leftObj.paint()
  rightObj.paint()
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
