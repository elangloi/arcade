property ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.visSprite.locZ = g.SPRITE_LOCZ_VILLAIN_FIGHTER
  me.moves[g.MOVE_STAND] = new(g.classes.Class_JinxStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_JinxWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_JinxWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_JinxBlock, me)
  me.moves[g.MOVE_JUMP] = new(g.classes.Class_JinxJump, me)
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_JinxPunch, me)
  me.moves[g.MOVE_KICK] = new(g.classes.Class_JinxKick, me)
  me.moves[g.MOVE_STUN] = new(g.classes.Class_JinxStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_JinxKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_JinxDefeat, me)
  me.moves[g.MOVE_FALL] = new(g.classes.Class_JinxFall, me)
  me.moves[g.MOVE_JINX_ENERGY_SPIN] = new(g.classes.Class_JinxEnergySpin, me)
  me.moves[g.MOVE_JINX_ENERGY_BALL] = new(g.classes.Class_JinxEnergyBall, me)
  me.moves[g.MOVE_JINX_POWER_KICK] = new(g.classes.Class_JinxPowerKick, me)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
