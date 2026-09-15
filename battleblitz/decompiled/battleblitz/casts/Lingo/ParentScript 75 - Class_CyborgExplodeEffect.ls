property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CYBORG.FX_CYBORG_EXPLODE_01, g.assets.CYBORG.FX_CYBORG_EXPLODE_02, g.assets.CYBORG.FX_CYBORG_EXPLODE_03, g.assets.CYBORG.FX_CYBORG_EXPLODE_04, g.assets.CYBORG.FX_CYBORG_EXPLODE_05, g.assets.CYBORG.FX_CYBORG_EXPLODE_06, g.assets.CYBORG.FX_CYBORG_EXPLODE_07, g.assets.CYBORG.FX_CYBORG_EXPLODE_08, g.assets.CYBORG.FX_CYBORG_EXPLODE_09, g.assets.CYBORG.FX_CYBORG_EXPLODE_10, g.assets.CYBORG.FX_CYBORG_EXPLODE_11, g.assets.CYBORG.FX_CYBORG_EXPLODE_12, g.assets.CYBORG.FX_CYBORG_EXPLODE_13, g.assets.CYBORG.FX_CYBORG_EXPLODE_14, g.assets.CYBORG.FX_CYBORG_EXPLODE_15, g.assets.CYBORG.FX_CYBORG_EXPLODE_16, g.assets.CYBORG.FX_CYBORG_EXPLODE_17, g.assets.CYBORG.FX_CYBORG_EXPLODE_18, g.assets.CYBORG.FX_CYBORG_EXPLODE_19, g.assets.CYBORG.FX_CYBORG_EXPLODE_20, g.assets.CYBORG.FX_CYBORG_EXPLODE_21, g.assets.CYBORG.FX_CYBORG_EXPLODE_22]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
