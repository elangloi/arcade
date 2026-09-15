property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, -initDir)
  vis = [g.assets.CHAR_SHARED.FX_DUST_JUMP_01, g.assets.CHAR_SHARED.FX_DUST_JUMP_02, g.assets.CHAR_SHARED.FX_DUST_JUMP_03, g.assets.CHAR_SHARED.FX_DUST_JUMP_04, g.assets.CHAR_SHARED.FX_DUST_JUMP_05, g.assets.CHAR_SHARED.FX_DUST_JUMP_06, g.assets.CHAR_SHARED.FX_DUST_JUMP_07, g.assets.CHAR_SHARED.FX_DUST_JUMP_08, g.assets.CHAR_SHARED.FX_DUST_JUMP_09, g.assets.CHAR_SHARED.FX_DUST_JUMP_10]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
