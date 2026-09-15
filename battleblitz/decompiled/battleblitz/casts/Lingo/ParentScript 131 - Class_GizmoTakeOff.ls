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
  vis = [g.assets.GIZMO.GIZMO_TAKEOFF_01, g.assets.GIZMO.GIZMO_TAKEOFF_02, g.assets.GIZMO.GIZMO_TAKEOFF_03, g.assets.GIZMO.GIZMO_TAKEOFF_04, g.assets.GIZMO.GIZMO_TAKEOFF_05, g.assets.GIZMO.GIZMO_TAKEOFF_06, g.assets.GIZMO.GIZMO_TAKEOFF_07, g.assets.GIZMO.GIZMO_TAKEOFF_08, g.assets.GIZMO.GIZMO_TAKEOFF_09, g.assets.GIZMO.GIZMO_TAKEOFF_10, g.assets.GIZMO.GIZMO_TAKEOFF_11]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.GIZMO.GIZMO_TAKEOFF_01D, g.assets.GIZMO.GIZMO_TAKEOFF_02D, g.assets.GIZMO.GIZMO_TAKEOFF_03D, g.assets.GIZMO.GIZMO_TAKEOFF_04D, g.assets.GIZMO.GIZMO_TAKEOFF_05D, g.assets.GIZMO.GIZMO_TAKEOFF_06D, g.assets.GIZMO.GIZMO_TAKEOFF_07D, g.assets.GIZMO.GIZMO_TAKEOFF_08D, g.assets.GIZMO.GIZMO_TAKEOFF_09D, g.assets.GIZMO.GIZMO_TAKEOFF_10D, g.assets.GIZMO.GIZMO_TAKEOFF_11D]
  order = [1, 1, 2, 3, 4, 5, 6, 7, 9, 11]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
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
  me.owner.setFlying(1)
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on update me
  ancestor.update()
  if me.age = 1 then
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_JUMP_1, 100, g.SFX_EVENT_PRIORITY_LOW)
  else
    if me.age = 4 then
      me.owner.setOnGround(0)
    else
      if me.age = 6 then
        g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_WINGSUNFURL, 100, g.SFX_EVENT_PRIORITY_LOW)
      end if
    end if
  end if
  if (me.age >= 4) and (me.age <= 8) then
    me.owner.moveBy(0.0, me.owner.HOVER_HEIGHT / 5)
  end if
end
