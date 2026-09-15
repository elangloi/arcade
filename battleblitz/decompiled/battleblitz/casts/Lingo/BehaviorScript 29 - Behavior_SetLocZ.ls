property locZLayer
global g

on beginSprite me
  sprite(me.spriteNum).locZ = g[locZLayer]
end

on endSprite me
  sprite(me.spriteNum).locZ = me.spriteNum
end

on prepareFrame me
end

on exitFrame me
end

on getLocZDefs me
  return [#SPRITE_LOCZ_BACKGROUND, #SPRITE_LOCZ_BACKGROUND_EFFECT, #SPRITE_LOCZ_SHADOWS, #SPRITE_LOCZ_EFFECTS_BACKGROUND, #SPRITE_LOCZ_VILLAIN_FIGHTER, #SPRITE_LOCZ_TITAN_FIGHTER, #SPRITE_LOCZ_PROJECTILES, #SPRITE_LOCZ_EFFECTS_FOREGROUND, #SPRITE_LOCZ_SCREEN_FLASH, #SPRITE_LOCZ_HUD_BG, #SPRITE_LOCZ_HUD_FG, #SPRITE_LOCZ_GAME_FADE, #SPRITE_LOCZ_GAME_TEXT, #SPRITE_LOCZ_ALL_FADE]
end

on getPropertyDescriptionList me
  vals = getLocZDefs()
  props = [:]
  props.addProp(#locZLayer, [#default: vals[1], #format: #symbol, #range: vals, #comment: "LocZ layer:"])
  return props
end
