property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CYBORG.FX_CYBORG_CANNON_BURST_01, g.assets.CYBORG.FX_CYBORG_CANNON_BURST_02, g.assets.CYBORG.FX_CYBORG_CANNON_BURST_03, g.assets.CYBORG.FX_CYBORG_CANNON_BURST_04, g.assets.CYBORG.FX_CYBORG_CANNON_BURST_05, g.assets.CYBORG.FX_CYBORG_CANNON_BURST_06, g.assets.CYBORG.FX_CYBORG_CANNON_BURST_07]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
