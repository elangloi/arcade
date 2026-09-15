property ancestor, blastEffect, streams, streamCap, capvis
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_CYBORG_SONIC_CANNON
  me.stunDuration = 8
  me.visSprite.blend = 85
  vis = [g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_02, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_03, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_04, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_05, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_06, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_07]
  att = [g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A, g.assets.CYBORG.FX_CYBORG_CANNON_STREAM_01A]
  me.animation = new(g.classes.Class_LoopedAnimation, vis)
  me.attackMasks = att
  capvis = [g.assets.CYBORG.FX_CYBORG_CANNON_CAP_01, g.assets.CYBORG.FX_CYBORG_CANNON_CAP_02]
  blastEffect = new(g.classes.Class_CyborgCannonBurstLoopEffect, owner, initPos, initVel, initDir)
  blastEffect.getSprite().blend = 100
  g.main.screen.addEffect(blastEffect)
  g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_CANNONBLASTSUSTAINED_LOOP, 60, g.SFX_EVENT_PRIORITY_LOW)
  streams = []
  repeat with i = 0 to 3
    o = new(g.classes.Class_StaticActor, vis[1], g.SPRITE_LOCZ_PROJECTILES, initPos + point(i * 114.0 * initDir, 0.0), initVel, initDir)
    o.getSprite().ink = g.INK_BGTRANSPARENT
    streams.append(o)
  end repeat
  streamCap = new(g.classes.Class_StaticActor, capvis[1], g.SPRITE_LOCZ_PROJECTILES, initPos + point(4 * 114.0 * initDir, 0.0), initVel, initDir)
  streamCap.getSprite().ink = g.INK_BGTRANSPARENT
  return me
end

on kill me
  ancestor.kill()
  if not voidp(blastEffect) then
    g.game.killEffect(blastEffect)
    blastEffect = VOID
    g.main.audioMgr.stopSound(g.assets.CYBORG.SFX_CYBORG_CANNONBLASTSUSTAINED_LOOP)
  end if
  repeat with o in streams
    o.destroy()
  end repeat
  streamCap.destroy()
end

on update me
  ancestor.update()
  repeat with o in streams
    o.getSprite().member = me.animation.getMember()
  end repeat
  streamCap.getSprite().member = capvis[(me.age mod 2) + 1]
end

on paint me
  ancestor.paint()
  repeat with o in streams
    o.paint()
  end repeat
  streamCap.paint()
end

on triggerPayoff me
  if not me.alive then
    exit
  end if
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_CANNONMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.screen.addEffect(new(g.classes.Class_CyborgExplodeEffect, me.owner, point(me.owner.opponent.getPosX(), me.getPosY()), point(0, 0), me.dir))
    g.main.audioMgr.playSound(g.assets.CYBORG.SFX_CYBORG_CANNONHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end
