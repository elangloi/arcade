property ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.moves[g.MOVE_STAND] = new(g.classes.Class_BeastboyStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_BeastboyWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_BeastboyWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_BeastboyBlock, me)
  me.moves[g.MOVE_JUMP] = new(g.classes.Class_BeastboyJump, me)
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_BeastboyPunch, me)
  me.moves[g.MOVE_KICK] = new(g.classes.Class_BeastboyKick, me)
  me.moves[g.MOVE_STUN] = new(g.classes.Class_BeastboyStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_BeastboyKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_BeastboyDefeat, me)
  me.moves[g.MOVE_FALL] = new(g.classes.Class_BeastboyFall, me)
  me.moves[g.MOVE_SUMMON_FIGHTER] = new(g.classes.Class_BeastboySummonTitan, me)
  me.moves[g.MOVE_BEASTBOY_GORILLA_SMASH] = new(g.classes.Class_BeastboyGorillaSmash, me)
  me.moves[g.MOVE_BEASTBOY_EAGLE_STRIKE] = new(g.classes.Class_BeastboyEagleStrike, me)
  me.moves[g.MOVE_BEASTBOY_RHINO_CHARGE] = new(g.classes.Class_BeastboyRhinoCharge, me)
  me.moves[g.MOVE_BEASTBOY_PTERODACTYL_SWOOP] = new(g.classes.Class_BeastboyPterodactylSwoop, me)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
