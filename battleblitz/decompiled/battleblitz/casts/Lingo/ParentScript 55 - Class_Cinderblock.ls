property ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.WALK_SPEED = 8.0
  me.visSprite.locZ = g.SPRITE_LOCZ_VILLAIN_FIGHTER
  me.moves[g.MOVE_STAND] = new(g.classes.Class_CinderblockStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_CinderblockWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_CinderblockWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_CinderblockBlock, me)
  me.moves[g.MOVE_JUMP] = me.moves[g.MOVE_STAND]
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_CinderblockPunch, me)
  me.moves[g.MOVE_KICK] = new(g.classes.Class_CinderblockKick, me)
  me.moves[g.MOVE_STUN] = new(g.classes.Class_CinderblockStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_CinderblockKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_CinderblockDefeat, me)
  me.moves[g.MOVE_FALL] = me.moves[g.MOVE_STAND]
  me.moves[g.MOVE_CINDERBLOCK_DOUBLE_PUNCH] = new(g.classes.Class_CinderblockDoublePunch, me)
  me.moves[g.MOVE_CINDERBLOCK_STOMP] = new(g.classes.Class_CinderblockStomp, me)
  me.moves[g.MOVE_CINDERBLOCK_BACKHAND] = new(g.classes.Class_CinderblockBackhand, me)
  me.shadow.setWidth(180)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
