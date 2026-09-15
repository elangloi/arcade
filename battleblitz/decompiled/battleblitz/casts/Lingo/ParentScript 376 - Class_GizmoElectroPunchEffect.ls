property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  me.visSprite.locZ = g.SPRITE_LOCZ_EFFECTS_BACKGROUND
  vis = [g.assets.GIZMO.FX_GIZMO_ELECTRO_PUNCH_01, g.assets.GIZMO.FX_GIZMO_ELECTRO_PUNCH_02, g.assets.GIZMO.FX_GIZMO_ELECTRO_PUNCH_03, g.assets.GIZMO.FX_GIZMO_ELECTRO_PUNCH_04, g.assets.GIZMO.FX_GIZMO_ELECTRO_PUNCH_05, g.assets.GIZMO.FX_GIZMO_ELECTRO_PUNCH_06, g.assets.GIZMO.FX_GIZMO_ELECTRO_PUNCH_07, g.assets.GIZMO.fx_gizmo_electro_punch_08]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
