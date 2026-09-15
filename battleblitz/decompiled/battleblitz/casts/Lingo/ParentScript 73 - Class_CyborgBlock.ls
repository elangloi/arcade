property ancestor, visAnim, visAltAnim
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.defenseRating = g.DEFENSE_BLOCK_DEFAULT
  me.setAttack(0)
  me.setInterruptible(1)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(1)
  vis = [g.assets.CYBORG.CYBORG_CROUCH_01]
  visAlt = [g.assets.CYBORG.CYBORG_CROUCH_ALT_01]
  att = [g.MEMBER_0]
  def = [g.assets.CYBORG.CYBORG_CROUCH_01D]
  visAnim = new(g.classes.Class_LoopedAnimation, vis)
  visAltAnim = new(g.classes.Class_LoopedAnimation, visAlt)
  me.animation = visAnim
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
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
  me.dirChanged()
end

on dirChanged me
  if me.owner.dir > 0 then
    me.animation = visAnim
  else
    me.animation = visAltAnim
  end if
  me.animation.reset()
end
