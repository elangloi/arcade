property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  me.visSprite.locZ = g.SPRITE_LOCZ_EFFECTS_BACKGROUND
  vis = [g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_01, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_02, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_03, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_04, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_05, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_06, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_07, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_08, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_09, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_10, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_11, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_12, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_13, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_14, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_15, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_16, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_17, g.assets.CHAR_SHARED.FX_RAVEN_SWIRL_18]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
