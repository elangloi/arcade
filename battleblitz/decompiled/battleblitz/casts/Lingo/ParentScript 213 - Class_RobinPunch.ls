property ancestor, fistEffect1, fistEffect2
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_ROBIN_PUNCH
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(1)
  vis = [g.assets.ROBIN.ROBIN_PUNCH_01, g.assets.ROBIN.ROBIN_PUNCH_02, g.assets.ROBIN.ROBIN_PUNCH_03, g.assets.ROBIN.ROBIN_PUNCH_04]
  att = [g.assets.ROBIN.ROBIN_PUNCH_01A, g.MEMBER_0, g.assets.ROBIN.ROBIN_PUNCH_03A, g.MEMBER_0]
  def = [g.assets.ROBIN.ROBIN_STAND_01D, g.assets.ROBIN.ROBIN_STAND_01D, g.assets.ROBIN.ROBIN_STAND_01D, g.assets.ROBIN.ROBIN_STAND_01D]
  order = [2, 2, 1, 1, 1, 2, 2, 3, 3, 3, 4, 4]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  fistEffect1 = 0
  fistEffect2 = 0
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
  fistEffect1 = 0
  fistEffect2 = 0
  me.owner.setVel(0.0, 0.0)
end

on update me
  me.age = me.age + 1
  if me.age > 1 then
    me.animation.advance()
  end if
  me.moveDone = me.animation.isDone()
  case me.animation.orderIndex of
    1:
      g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_WOOSH, 100, g.SFX_EVENT_PRIORITY_LOW)
    3, 4, 5:
      if me.hitOpponent and not fistEffect1 then
        fistEffect1 = 1
        if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
          g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
        else
          g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.pos + point(61.0 * me.owner.dir, -116.0), point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
      end if
    8, 9, 10:
      if me.hitOpponent and not fistEffect2 then
        fistEffect2 = 1
        if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
          g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
        else
          g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.pos + point(77.0 * me.owner.dir, -99.0), point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
      end if
  end case
end
