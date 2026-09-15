property ancestor
global g

on new me, initMember, initLocZ, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Actor, initPos, initVel, initDir)
  me.visSprite = g.game.spriteMgr.grabSprite()
  me.visSprite.member = initMember
  me.visSprite.locZ = initLocZ
  me.visSprite.flipH = initDir < 0
  me.visSprite.ink = g.INK_BGTRANSPARENT
  return me
end

on destroy me
  g.game.spriteMgr.releaseSprite(me.visSprite)
  return VOID
end
