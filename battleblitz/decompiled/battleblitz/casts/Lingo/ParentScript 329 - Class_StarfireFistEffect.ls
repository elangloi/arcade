property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  me.visSprite.locZ = g.SPRITE_LOCZ_EFFECTS_BACKGROUND
  me.visSprite.blend = 100
  vis = [g.assets.STARFIRE.FX_STARFIRE_FIST_01, g.assets.STARFIRE.FX_STARFIRE_FIST_02, g.assets.STARFIRE.FX_STARFIRE_FIST_03, g.assets.STARFIRE.FX_STARFIRE_FIST_04, g.assets.STARFIRE.FX_STARFIRE_FIST_05, g.assets.STARFIRE.FX_STARFIRE_FIST_06, g.assets.STARFIRE.FX_STARFIRE_FIST_07, g.assets.STARFIRE.FX_STARFIRE_FIST_08, g.assets.STARFIRE.FX_STARFIRE_FIST_09, g.assets.STARFIRE.FX_STARFIRE_FIST_10, g.assets.STARFIRE.FX_STARFIRE_FIST_11, g.assets.STARFIRE.FX_STARFIRE_FIST_12]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
