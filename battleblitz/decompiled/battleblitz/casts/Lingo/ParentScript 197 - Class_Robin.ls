property ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.moves[g.MOVE_STAND] = new(g.classes.Class_RobinStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_RobinWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_RobinWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_RobinBlock, me)
  me.moves[g.MOVE_JUMP] = new(g.classes.Class_RobinJump, me)
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_RobinPunch, me)
  me.moves[g.MOVE_KICK] = new(g.classes.Class_RobinKick, me)
  me.moves[g.MOVE_STUN] = new(g.classes.Class_RobinStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_RobinKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_RobinDefeat, me)
  me.moves[g.MOVE_FALL] = new(g.classes.Class_RobinFall, me)
  me.moves[g.MOVE_SUMMON_FIGHTER] = new(g.classes.Class_RobinSummonTitan, me)
  me.moves[g.MOVE_ROBIN_FLYING_KICK] = new(g.classes.Class_RobinFlyingKick, me)
  me.moves[g.MOVE_ROBIN_DISC_THROW] = new(g.classes.Class_RobinDiscThrow, me)
  me.moves[g.MOVE_ROBIN_DIAG_JUMP_KICK] = new(g.classes.Class_RobinDiagJumpKick, me)
  me.moves[g.MOVE_ROBIN_BOMB_THROW] = new(g.classes.Class_RobinBombThrow, me)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
