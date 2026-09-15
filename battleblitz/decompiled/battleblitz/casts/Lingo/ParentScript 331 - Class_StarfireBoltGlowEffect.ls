property ancestor, glowOver
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CHAR_SHARED.FX_STARFIRE_BOLT_02]
  me.animation = new(g.classes.Class_LoopedAnimation, vis)
  glowOver = new(g.classes.Class_StaticActor, g.assets.CHAR_SHARED.fx_starfire_summon_glow_bg_01, g.SPRITE_LOCZ_EFFECTS_BACKGROUND, initPos, initVel, initDir)
  return me
end

on destroy me
  ancestor.destroy()
  glowOver.destroy()
  return VOID
end

on update me
  ancestor.update()
  if me.age < 6 then
    glowSprite = glowOver.getSprite()
    glowSprite.rect = glowSprite.rect.inflate(-15, -15)
    iBlend = glowSprite.blend - 20
    if iBlend < 0 then
      iBlend = 0
    end if
    glowSprite.blend = iBlend
  else
    me.kill()
  end if
end

on paint me
  ancestor.paint()
  glowOver.paint()
end
