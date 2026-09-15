property ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.moves[g.MOVE_STAND] = new(g.classes.Class_RavenStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_RavenWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_RavenWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_RavenBlock, me)
  me.moves[g.MOVE_JUMP] = new(g.classes.Class_RavenJump, me)
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_RavenPunch, me)
  me.moves[g.MOVE_KICK] = new(g.classes.Class_RavenKick, me)
  me.moves[g.MOVE_STUN] = new(g.classes.Class_RavenStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_RavenKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_RavenDefeat, me)
  me.moves[g.MOVE_FALL] = new(g.classes.Class_RavenFall, me)
  me.moves[g.MOVE_SUMMON_FIGHTER] = new(g.classes.Class_RavenSummonTitan, me)
  me.moves[g.MOVE_RAVEN_TELEKINETIC_THROW] = new(g.classes.Class_RavenTelekineticThrow, me)
  me.moves[g.MOVE_RAVEN_EXPLOSIVE_DROP] = new(g.classes.Class_RavenExplosiveDrop, me)
  me.moves[g.MOVE_RAVEN_TELEKINETIC_SPIN] = new(g.classes.Class_RavenTelekineticSpin, me)
  me.moves[g.MOVE_RAVEN_MIDAIR_ATTACK] = new(g.classes.Class_RavenMidairAttack, me)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
