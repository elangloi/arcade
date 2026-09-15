property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.PLASMUS.PLASMUS_HIT_SPLATTER_01]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.animation.setRepeat(5)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
