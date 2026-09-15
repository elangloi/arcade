property ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.moves[g.MOVE_STAND] = new(g.classes.Class_StarfireStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_StarfireWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_StarfireWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_StarfireBlock, me)
  me.moves[g.MOVE_JUMP] = new(g.classes.Class_StarfireJump, me)
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_StarfirePunch, me)
  me.moves[g.MOVE_KICK] = new(g.classes.Class_StarfireKick, me)
  me.moves[g.MOVE_STUN] = new(g.classes.Class_StarfireStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_StarfireKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_StarfireDefeat, me)
  me.moves[g.MOVE_FALL] = new(g.classes.Class_StarfireFall, me)
  me.moves[g.MOVE_SUMMON_FIGHTER] = new(g.classes.Class_StarfireSummonTitan, me)
  me.moves[g.MOVE_STARFIRE_DIAG_JUMP_KICK] = new(g.classes.Class_StarfireDiagJumpKick, me)
  me.moves[g.MOVE_STARFIRE_ENERGY_BALL] = new(g.classes.Class_StarfireEnergyBall, me)
  me.moves[g.MOVE_STARFIRE_BOLT_BARRAGE] = new(g.classes.Class_StarfireBoltBarrage, me)
  me.moves[g.MOVE_STARFIRE_FLYING_KNEE] = new(g.classes.Class_StarfireFlyingKnee, me)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
