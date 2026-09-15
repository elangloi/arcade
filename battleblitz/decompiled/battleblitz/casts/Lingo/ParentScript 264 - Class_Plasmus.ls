property ancestor
global g

on new me, initHealth
  ancestor = new(g.classes.Class_Fighter, initHealth)
  me.WALK_SPEED = 8.0
  me.visSprite.locZ = g.SPRITE_LOCZ_VILLAIN_FIGHTER
  me.moves[g.MOVE_STAND] = new(g.classes.Class_PlasmusStand, me)
  me.moves[g.MOVE_WALK_FORWARD] = new(g.classes.Class_PlasmusWalkForward, me)
  me.moves[g.MOVE_WALK_BACKWARD] = new(g.classes.Class_PlasmusWalkBackward, me)
  me.moves[g.MOVE_BLOCK] = new(g.classes.Class_PlasmusBlock, me)
  me.moves[g.MOVE_JUMP] = me.moves[g.MOVE_STAND]
  me.moves[g.MOVE_PUNCH] = new(g.classes.Class_PlasmusPunch, me)
  me.moves[g.MOVE_KICK] = me.moves[g.MOVE_STAND]
  me.moves[g.MOVE_STUN] = new(g.classes.Class_PlasmusStun, me)
  me.moves[g.MOVE_KNOCK_DOWN] = new(g.classes.Class_PlasmusKnockDown, me)
  me.moves[g.MOVE_DEFEAT] = new(g.classes.Class_PlasmusDefeat, me)
  me.moves[g.MOVE_FALL] = me.moves[g.MOVE_STAND]
  me.moves[g.MOVE_PLASMUS_SLUDGE_THROW] = new(g.classes.Class_PlasmusSludgeThrow, me)
  me.moves[g.MOVE_PLASMUS_CRAB_THROW] = new(g.classes.Class_PlasmusCrabThrow, me)
  me.moves[g.MOVE_PLASMUS_CHEST_BLAST] = new(g.classes.Class_PlasmusChestBlast, me)
  me.moves[g.MOVE_PLASMUS_ARM_SWIPE] = new(g.classes.Class_PlasmusArmSwipe, me)
  me.shadow.setWidth(200)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
