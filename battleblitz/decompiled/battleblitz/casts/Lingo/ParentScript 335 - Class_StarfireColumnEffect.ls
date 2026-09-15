property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  me.visSprite.locZ = g.SPRITE_LOCZ_EFFECTS_BACKGROUND
  vis = [g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_01, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_02, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_FULL_01, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_FULL_02, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_FULL_01, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_FULL_02, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_FULL_01, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_FULL_02, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_FULL_01, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_FULL_02, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_FULL_01, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_03, g.assets.CHAR_SHARED.FX_STARFIRE_COLUMN_05]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
