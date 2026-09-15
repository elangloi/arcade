property ancestor, fistEffect1, fistEffect2
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.attackDamage = g.DAMAGE_CINDERBLOCK_DOUBLE_PUNCH
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_01, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_02, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_03, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_04, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_05, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_06]
  att = [g.MEMBER_0, g.MEMBER_0, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_03A, g.MEMBER_0, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_05A, g.MEMBER_0]
  def = [g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_01D, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_02D, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_03D, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_04D, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_05D, g.assets.CINDERBLOCK.CINDERBLOCK_PUNCH_06D]
  order = [1, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6]
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

on reset me
  ancestor.reset()
  fistEffect1 = 0
  fistEffect2 = 0
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on update me
  me.age = me.age + 1
  if me.age > 1 then
    me.animation.advance()
  end if
  me.moveDone = me.animation.isDone()
  if me.hitOpponent then
    case me.animation.orderIndex of
      1:
        g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_WOOSH, 100, g.SFX_EVENT_PRIORITY_LOW)
      6, 7, 8:
        if not fistEffect1 then
          fistEffect1 = 1
          if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
            g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
          else
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.pos + point(110.0 * me.owner.dir, -55.0), point(0, 0), me.owner.dir))
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          end if
        end if
      10, 11, 12:
        if not fistEffect2 then
          fistEffect2 = 1
          if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_BLOCK, 100, g.SFX_EVENT_PRIORITY_LOW)
            g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
          else
            g.main.screen.addEffect(new(g.classes.Class_HitStarBurstEffect, me.owner, me.owner.pos + point(100.0 * me.owner.dir, -40.0), point(0, 0), me.owner.dir))
            g.main.audioMgr.playSound(g.assets.AUDIO.SFX_PUNCH_LANDING, 100, g.SFX_EVENT_PRIORITY_LOW)
          end if
        end if
    end case
  end if
end
