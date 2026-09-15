property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.BG_EN_STRETCH_000, g.assets.CHAR_SHARED.BG_EN_STRETCH_001, g.assets.CHAR_SHARED.BG_EN_STRETCH_002]
  me.animation = new(g.classes.Class_LoopedAnimation, vis)
  me.animation.setRepeat(3)
  me.visSprite.locZ = g.SPRITE_LOCZ_BACKGROUND_EFFECT
  me.visSprite.rect = rect(0, 0, 600, 400)
  me.visSprite.blend = 100
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on paint me
  me.visSprite.rect = rect(0, 0, 600, 400)
end
