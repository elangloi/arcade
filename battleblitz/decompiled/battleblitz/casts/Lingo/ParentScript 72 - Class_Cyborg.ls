property ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.moves[g.MOVE_STAND] = new(g.classes.Class_CyborgStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_CyborgWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_CyborgWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_CyborgBlock, me)
  me.moves[g.MOVE_JUMP] = new(g.classes.Class_CyborgJump, me)
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_CyborgPunch, me)
  me.moves[g.MOVE_KICK] = new(g.classes.Class_CyborgKick, me)
  me.moves[g.MOVE_STUN] = new(g.classes.Class_CyborgStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_CyborgKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_CyborgDefeat, me)
  me.moves[g.MOVE_FALL] = new(g.classes.Class_CyborgFall, me)
  me.moves[g.MOVE_SUMMON_FIGHTER] = new(g.classes.Class_CyborgSummonTitan, me)
  me.moves[g.MOVE_CYBORG_SONIC_CANNON] = new(g.classes.Class_CyborgSonicCannon, me)
  me.moves[g.MOVE_CYBORG_FLYING_PUNCH] = new(g.classes.Class_CyborgFlyingPunch, me)
  me.moves[g.MOVE_CYBORG_POWER_SMASH] = new(g.classes.Class_CyborgPowerSmash, me)
  me.moves[g.MOVE_CYBORG_CYBER_STOMP] = new(g.classes.Class_CyborgCyberStomp, me)
  me.shadow.setWidth(130)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
