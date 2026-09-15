property ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.visSprite.locZ = g.SPRITE_LOCZ_VILLAIN_FIGHTER
  me.moves[g.MOVE_STAND] = new(g.classes.Class_MammothStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_MammothWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_MammothWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_MammothBlock, me)
  me.moves[g.MOVE_JUMP] = new(g.classes.Class_MammothJump, me)
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_MammothPunch, me)
  me.moves[g.MOVE_KICK] = me.moves[g.MOVE_STAND]
  me.moves[g.MOVE_STUN] = new(g.classes.Class_MammothStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_MammothKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_MammothDefeat, me)
  me.moves[g.MOVE_FALL] = new(g.classes.Class_MammothFall, me)
  me.moves[g.MOVE_MAMMOTH_GROUND_PUNCH] = new(g.classes.Class_MammothGroundPunch, me)
  me.moves[g.MOVE_MAMMOTH_JUMP_PUNCH] = new(g.classes.Class_MammothJumpPunch, me)
  me.moves[g.MOVE_MAMMOTH_SHOULDER_BARGE] = new(g.classes.Class_MammothShoulderBarge, me)
  me.shadow.setWidth(130)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
