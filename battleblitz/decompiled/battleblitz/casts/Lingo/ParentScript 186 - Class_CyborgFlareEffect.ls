property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CYBORG.FX_CYBORG_FLARE_01, g.assets.CYBORG.FX_CYBORG_FLARE_02]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.animation.setRepeat(3)
  return me
end
