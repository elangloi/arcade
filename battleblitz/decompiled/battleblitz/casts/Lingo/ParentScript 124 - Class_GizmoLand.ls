property ancestor
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.GIZMO.GIZMO_LAND_01, g.assets.GIZMO.GIZMO_LAND_02, g.assets.GIZMO.GIZMO_LAND_03, g.assets.GIZMO.GIZMO_TAKEOFF_02, g.assets.GIZMO.GIZMO_TAKEOFF_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.GIZMO.GIZMO_LAND_01D, g.assets.GIZMO.GIZMO_LAND_02D, g.assets.GIZMO.GIZMO_LAND_03D, g.assets.GIZMO.GIZMO_TAKEOFF_02D, g.assets.GIZMO.GIZMO_TAKEOFF_01D]
  order = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 5]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on update me
  ancestor.update()
  if me.age = 1 then
    g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_WINGSFOLDIN, 100, g.SFX_EVENT_PRIORITY_LOW)
  else
    if me.age = 5 then
      me.owner.moveBy(0.0, -me.owner.HOVER_HEIGHT / 2.0)
    else
      if me.age = 6 then
        me.owner.setOnGround(1)
        me.owner.moveBy(0.0, -me.owner.HOVER_HEIGHT / 2.0)
      end if
    end if
  end if
end

on reset me
  ancestor.reset()
  me.owner.setOnGround(0)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setFlying(0)
  me.owner.setVel(0.0, 0.0)
end
