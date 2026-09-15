property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CYBORG.FX_CYBORG_RING_01, g.assets.CYBORG.FX_CYBORG_RING_02, g.assets.CYBORG.FX_CYBORG_RING_03, g.assets.CYBORG.FX_CYBORG_RING_04, g.assets.CYBORG.FX_CYBORG_RING_05, g.assets.CYBORG.FX_CYBORG_RING_06]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end
