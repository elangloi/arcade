property ancestor, visAnim, visAltAnim
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(1)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.CYBORG.CYBORG_RUN_01, g.assets.CYBORG.CYBORG_RUN_02, g.assets.CYBORG.CYBORG_RUN_03, g.assets.CYBORG.CYBORG_RUN_04, g.assets.CYBORG.CYBORG_RUN_05, g.assets.CYBORG.CYBORG_RUN_06, g.assets.CYBORG.CYBORG_RUN_07, g.assets.CYBORG.CYBORG_RUN_08]
  visAlt = [g.assets.CYBORG.CYBORG_RUN_ALT_01, g.assets.CYBORG.CYBORG_RUN_ALT_02, g.assets.CYBORG.CYBORG_RUN_ALT_03, g.assets.CYBORG.CYBORG_RUN_ALT_04, g.assets.CYBORG.CYBORG_RUN_ALT_05, g.assets.CYBORG.CYBORG_RUN_ALT_06, g.assets.CYBORG.CYBORG_RUN_ALT_07, g.assets.CYBORG.CYBORG_RUN_ALT_08]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.CYBORG.CYBORG_STAND_01D, g.assets.CYBORG.CYBORG_STAND_01D, g.assets.CYBORG.CYBORG_STAND_01D, g.assets.CYBORG.CYBORG_STAND_01D, g.assets.CYBORG.CYBORG_STAND_01D, g.assets.CYBORG.CYBORG_STAND_01D, g.assets.CYBORG.CYBORG_STAND_01D, g.assets.CYBORG.CYBORG_STAND_01D]
  visAnim = new(g.classes.Class_LoopedAnimation, vis)
  visAltAnim = new(g.classes.Class_LoopedAnimation, visAlt)
  visAnim.setRepeat(2)
  visAltAnim.setRepeat(2)
  me.animation = visAnim
  me.attackMasks = att
  me.defenseMasks = def
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on reset me
  ancestor.reset()
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(-me.owner.dir * me.owner.WALK_SPEED, 0.0)
  me.dirChanged()
end

on dirChanged me
  if me.owner.dir > 0 then
    me.animation = visAltAnim
  else
    me.animation = visAnim
  end if
  me.animation.reset()
end

on update me
  ancestor.update()
  if (me.age mod 9) = 3 then
    if random(2) = 1 then
      g.main.audioMgr.playSound(g.assets.AUDIO.SFX_WALKING_SMALL_PERSON_1, 50, g.SFX_EVENT_PRIORITY_LOW)
    else
      g.main.audioMgr.playSound(g.assets.AUDIO.SFX_WALKING_SMALL_PERSON_2, 50, g.SFX_EVENT_PRIORITY_LOW)
    end if
  end if
end

on getFlipX me
  return 1
end
