property ancestor
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
  vis = [g.assets.STARFIRE.STARFIRE_FLOAT_FWD_01, g.assets.STARFIRE.STARFIRE_FALL_02]
  att = [g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.STARFIRE.STARFIRE_FLOAT_FWD_01D, g.assets.STARFIRE.STARFIRE_FALL_02D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
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
  me.owner.setHovering(1)
  me.owner.setShowingTrails(0)
  me.owner.setVel(-me.owner.dir * me.owner.WALK_SPEED, 0.0)
end

on update me
  me.age = me.age + 1
  if me.age = 2 then
    me.animation.advance()
  end if
end

on getFlipX me
  return 1
end
