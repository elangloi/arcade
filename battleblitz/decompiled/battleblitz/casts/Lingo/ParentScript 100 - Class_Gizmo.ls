property HOVER_HEIGHT, flying, ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.WALK_SPEED = 20
  me.visSprite.locZ = g.SPRITE_LOCZ_VILLAIN_FIGHTER
  HOVER_HEIGHT = -40.0
  me.moves[g.MOVE_STAND] = new(g.classes.Class_GizmoStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_GizmoWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_GizmoWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_GizmoBlock, me)
  me.moves[g.MOVE_JUMP] = new(g.classes.Class_GizmoJump, me)
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_GizmoPunch, me)
  me.moves[g.MOVE_KICK] = me.moves[g.MOVE_STAND]
  me.moves[g.MOVE_STUN] = new(g.classes.Class_GizmoStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_GizmoKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_GizmoDefeat, me)
  me.moves[g.MOVE_FALL] = new(g.classes.Class_GizmoFall, me)
  me.moves[g.MOVE_GIZMO_HOVER] = new(g.classes.Class_GizmoHover, me)
  me.moves[g.MOVE_GIZMO_TAKE_OFF] = new(g.classes.Class_GizmoTakeOff, me)
  me.moves[g.MOVE_GIZMO_LAND] = new(g.classes.Class_GizmoLand, me)
  me.moves[g.MOVE_GIZMO_FLY_FORWARD] = new(g.classes.Class_GizmoFlyForward, me)
  me.moves[g.MOVE_GIZMO_FLY_BACKWARD] = new(g.classes.Class_GizmoFlyBackward, me)
  me.moves[g.MOVE_GIZMO_AIR_STUN] = new(g.classes.Class_GizmoAirStun, me)
  me.moves[g.MOVE_GIZMO_CANNON] = new(g.classes.Class_GizmoCannon, me)
  me.moves[g.MOVE_GIZMO_AIR_CANNON] = new(g.classes.Class_GizmoAirCannon, me)
  me.moves[g.MOVE_GIZMO_AIR_MISSILE] = new(g.classes.Class_GizmoAirMissile, me)
  me.moves[g.MOVE_GIZMO_HIGH_AIR_MISSILE] = new(g.classes.Class_GizmoHighAirMissile, me)
  me.moves[g.MOVE_GIZMO_AIR_JUMP] = new(g.classes.Class_GizmoAirJump, me)
  me.moves[g.MOVE_GIZMO_AIR_BLOCK] = new(g.classes.Class_GizmoAirBlock, me)
  me.moves[g.MOVE_GIZMO_AIR_PUNCH] = new(g.classes.Class_GizmoAirPunch, me)
  me.shadow.setWidth(70)
  flying = 0
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on queueDefaultMove me
  if me.isOnGround() then
    me.queueMove(g.MOVE_STAND, 0)
  else
    me.queueMove(g.MOVE_GIZMO_HOVER, 0)
  end if
end

on isFlying me
  return flying
end

on setFlying me, b
  if b then
    flying = 1
  else
    flying = 0
  end if
end

on queueStun me, dur
  if me.isOnGround() then
    me.queueMove(g.MOVE_STUN, dur)
  else
    me.queueMove(g.MOVE_GIZMO_AIR_STUN, dur)
  end if
end
