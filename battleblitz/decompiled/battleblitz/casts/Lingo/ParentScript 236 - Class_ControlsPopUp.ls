property bgMem, fgMem, texMem, bgOverlay, fgOverlay, texOverlay, menuButtonOverlay, fightButtonOverlay, visible
global g

on new me
  case g.playerID of
    g.FIGHTER_ID_ROBIN:
      bgMem = member("controls_robin_bg", "controls_screen")
      fgMem = member("controls_robin_overlay", "controls_screen")
    g.FIGHTER_ID_RAVEN:
      bgMem = member("controls_raven_bg", "controls_screen")
      fgMem = member("controls_raven_overlay", "controls_screen")
    g.FIGHTER_ID_CYBORG:
      bgMem = member("controls_cyborg_bg", "controls_screen")
      fgMem = member("controls_cyborg_overlay", "controls_screen")
    g.FIGHTER_ID_STARFIRE:
      bgMem = member("controls_starfire_bg", "controls_screen")
      fgMem = member("controls_starfire_overlay", "controls_screen")
    g.FIGHTER_ID_BEASTBOY:
      bgMem = member("controls_beastboy_bg", "controls_screen")
      fgMem = member("controls_beastboy_overlay", "controls_screen")
    g.FIGHTER_ID_JINX:
      bgMem = member("controls_villains_bg", "controls_screen")
      fgMem = member("controls_jinx_overlay", "controls_screen")
    g.FIGHTER_ID_GIZMO:
      bgMem = member("controls_villains_bg", "controls_screen")
      fgMem = member("controls_gizmo_overlay", "controls_screen")
    g.FIGHTER_ID_MAMMOTH:
      bgMem = member("controls_villains_bg", "controls_screen")
      fgMem = member("controls_mammoth_overlay", "controls_screen")
    g.FIGHTER_ID_CINDERBLOCK:
      bgMem = member("controls_villains_bg", "controls_screen")
      fgMem = member("controls_cinderblock_overlay", "controls_screen")
    g.FIGHTER_ID_PLASMUS:
      bgMem = member("controls_villains_bg", "controls_screen")
      fgMem = member("controls_plasmus_overlay", "controls_screen")
  end case
  texMem = member("controls_texture", "controls_screen")
  bgMem.preload()
  fgMem.preload()
  texMem.preload()
  visible = 0
  return me
end

on destroy me
  if not voidp(bgOverlay) then
    bgOverlay.destroy()
  end if
  if not voidp(fgOverlay) then
    fgOverlay.destroy()
  end if
  if not voidp(texOverlay) then
    bgOverlay = texOverlay.destroy()
  end if
  if not voidp(menuButtonOverlay) then
    menuButtonOverlay.getSprite().scriptInstanceList = []
    menuButtonOverlay.destroy()
  end if
  if not voidp(fightButtonOverlay) then
    fightButtonOverlay.getSprite().scriptInstanceList = []
    fightButtonOverlay.destroy()
  end if
  return VOID
end

on isVisible me
  return visible
end

on setVisible me, b
  visible = b
  if visible then
    if voidp(bgOverlay) then
      bgOverlay = new(g.classes.Class_StaticOverlay, bgMem, point(300, 200), g.SPRITE_LOCZ_POPUP_CONTROLS_BG)
      bgOverlay.setInk(g.INK_COPY)
      fgOverlay = new(g.classes.Class_StaticOverlay, fgMem, point(300, 200), g.SPRITE_LOCZ_POPUP_CONTROLS_OVERLAY)
      fgOverlay.setInk(g.INK_BGTRANSPARENT)
      texOverlay = new(g.classes.Class_StaticOverlay, texMem, point(300, 200), g.SPRITE_LOCZ_POPUP_CONTROLS_TEXTURE)
      texOverlay.setInk(g.INK_BGTRANSPARENT)
      texOverlay.getSprite().blend = 10
      menuButtonOverlay = new(g.classes.Class_StaticOverlay, member("back_008", "select_screen"), point(301, 12), g.SPRITE_LOCZ_POPUP_CONTROLS_BUTTONS)
      menuButtonOverlay.getSprite().scriptInstanceList.append(new(script("Behavior_ControlPopupMenuButton")))
      fightButtonOverlay = new(g.classes.Class_StaticOverlay, member("button_fight_000", "select_screen"), point(301, 49), g.SPRITE_LOCZ_POPUP_CONTROLS_BUTTONS)
      fightButtonOverlay.getSprite().scriptInstanceList.append(new(script("Behavior_ControlPopupFightButton")))
    end if
  else
    if not voidp(bgOverlay) then
      bgOverlay = bgOverlay.destroy()
    end if
    if not voidp(fgOverlay) then
      bgOverlay = fgOverlay.destroy()
    end if
    if not voidp(texOverlay) then
      bgOverlay = texOverlay.destroy()
    end if
    if not voidp(menuButtonOverlay) then
      menuButtonOverlay.getSprite().scriptInstanceList = []
      menuButtonOverlay = menuButtonOverlay.destroy()
    end if
    if not voidp(fightButtonOverlay) then
      fightButtonOverlay.getSprite().scriptInstanceList = []
      fightButtonOverlay = fightButtonOverlay.destroy()
    end if
  end if
end
