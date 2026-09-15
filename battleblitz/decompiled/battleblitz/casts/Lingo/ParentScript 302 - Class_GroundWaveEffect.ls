property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_GROUND_WAVE_01, g.assets.CHAR_SHARED.FX_GROUND_WAVE_02, g.assets.CHAR_SHARED.FX_GROUND_WAVE_03, g.assets.CHAR_SHARED.FX_GROUND_WAVE_04, g.assets.CHAR_SHARED.FX_GROUND_WAVE_05, g.assets.CHAR_SHARED.FX_GROUND_WAVE_06, g.assets.CHAR_SHARED.FX_GROUND_WAVE_07, g.assets.CHAR_SHARED.FX_GROUND_WAVE_08, g.assets.CHAR_SHARED.FX_GROUND_WAVE_09, g.assets.CHAR_SHARED.FX_GROUND_WAVE_10, g.assets.CHAR_SHARED.FX_GROUND_WAVE_11, g.assets.CHAR_SHARED.FX_GROUND_WAVE_12]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.moveBy(0.0, 10.0)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
