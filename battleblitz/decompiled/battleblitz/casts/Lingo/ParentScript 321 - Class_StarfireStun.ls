property ancestor, stunDuration
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(1)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.STARFIRE.STARFIRE_HIT_01]
  att = [g.MEMBER_0]
  def = [g.assets.STARFIRE.STARFIRE_HIT_01D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  stunDuration = 0
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on reset me, arg
  ancestor.reset()
  me.owner.setVel(0.0, 0.0)
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  if me.owner.getPosY() > 0.0 then
    me.owner.setPosY(0.0)
  end if
  if voidp(arg) then
    stunDuration = 0
  else
    stunDuration = arg
  end if
end

on update me
  me.age = me.age + 1
  if me.age >= stunDuration then
    me.moveDone = 1
  end if
end
