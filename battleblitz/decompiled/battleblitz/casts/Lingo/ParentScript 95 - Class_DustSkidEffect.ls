property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_DUST_SKID_01, g.assets.CHAR_SHARED.FX_DUST_SKID_02, g.assets.CHAR_SHARED.FX_DUST_SKID_03, g.assets.CHAR_SHARED.FX_DUST_SKID_04, g.assets.CHAR_SHARED.FX_DUST_SKID_05, g.assets.CHAR_SHARED.FX_DUST_SKID_06, g.assets.CHAR_SHARED.FX_DUST_SKID_07]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
