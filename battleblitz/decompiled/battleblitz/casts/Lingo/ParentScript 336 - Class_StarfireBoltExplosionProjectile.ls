property ancestor, initState
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_STARFIRE_BOLT_BARRAGE
  me.stunDuration = 20
  initState = 1
  vis = [g.MEMBER_0]
  att = [g.assets.STARFIRE.FX_STARFIRE_BOLT_EXPLODE_01A]
  me.animation = new(g.classes.Class_LoopedAnimation, vis)
  me.attackMasks = att
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on advanceState
  initState = 1
  animState = animState + 1
  stateAge = 0
end

on update me
  me.age = me.age + 1
  if me.alive then
    if initState then
      initState = 0
    end if
    me.setPos(me.pos + me.vel)
    me.visSprite.member = me.animation.getMember()
    me.updateBoundingBoxes()
    if me.getPosY() >= 0.0 then
      me.kill()
    end if
  end if
end

on triggerPayoff me
  if not me.alive then
    return 0
  end if
  g.main.screen.addEffect(new(g.classes.Class_StarfireExplodeEffect, me.owner, me.pos, point(0, 0), me.dir))
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    return 0
  else
    return 1
  end if
end
