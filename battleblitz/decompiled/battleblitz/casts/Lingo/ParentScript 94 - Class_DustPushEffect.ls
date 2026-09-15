property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_DUST_PUSH_01, g.assets.CHAR_SHARED.FX_DUST_PUSH_02, g.assets.CHAR_SHARED.FX_DUST_PUSH_03, g.assets.CHAR_SHARED.FX_DUST_PUSH_04, g.assets.CHAR_SHARED.FX_DUST_PUSH_05, g.assets.CHAR_SHARED.FX_DUST_PUSH_06, g.assets.CHAR_SHARED.FX_DUST_PUSH_07, g.assets.CHAR_SHARED.FX_DUST_PUSH_08, g.assets.CHAR_SHARED.FX_DUST_PUSH_09]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
