property HUD_PORTRAITS, HUD_SUMMON_PORTRAITS, HUD_SUMMON_PORTRAITS_GREY, HUD_NAMES, WIN_LEFT_MEMBER_ON, WIN_LEFT_MEMBER_OFF, WIN_RIGHT_MEMBER_ON, WIN_RIGHT_MEMBER_OFF, hudBG, titanHealthBar, villainHealthBar, titanPortrait, villainPortrait, titanName, villainName, clock, titanWin1, titanWin2, villainWin1, villainWin2, flashOverlay, flashDuration, summonPortraits, fpsIndicator, score
global g

on new me
  g.assets.hud.precache()
  HUD_PORTRAITS = []
  HUD_PORTRAITS[g.FIGHTER_ID_ROBIN] = g.assets.hud.HUD_PORTRAIT_ROBIN
  HUD_PORTRAITS[g.FIGHTER_ID_RAVEN] = g.assets.hud.HUD_PORTRAIT_RAVEN
  HUD_PORTRAITS[g.FIGHTER_ID_CYBORG] = g.assets.hud.HUD_PORTRAIT_CYBORG
  HUD_PORTRAITS[g.FIGHTER_ID_STARFIRE] = g.assets.hud.HUD_PORTRAIT_STARFIRE
  HUD_PORTRAITS[g.FIGHTER_ID_BEASTBOY] = g.assets.hud.HUD_PORTRAIT_BEASTBOY
  HUD_PORTRAITS[g.FIGHTER_ID_JINX] = g.assets.hud.HUD_PORTRAIT_JINX
  HUD_PORTRAITS[g.FIGHTER_ID_MAMMOTH] = g.assets.hud.HUD_PORTRAIT_MAMMOTH
  HUD_PORTRAITS[g.FIGHTER_ID_GIZMO] = g.assets.hud.HUD_PORTRAIT_GIZMO
  HUD_PORTRAITS[g.FIGHTER_ID_CINDERBLOCK] = g.assets.hud.HUD_PORTRAIT_CINDERBLOCK
  HUD_PORTRAITS[g.FIGHTER_ID_PLASMUS] = g.assets.hud.HUD_PORTRAIT_PLASMUS
  HUD_SUMMON_PORTRAITS = []
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_ROBIN] = g.assets.hud.HUD_SUMMON_PORTRAIT_ROBIN
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_RAVEN] = g.assets.hud.HUD_SUMMON_PORTRAIT_RAVEN
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_CYBORG] = g.assets.hud.HUD_SUMMON_PORTRAIT_CYBORG
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_STARFIRE] = g.assets.hud.HUD_SUMMON_PORTRAIT_STARFIRE
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_BEASTBOY] = g.assets.hud.HUD_SUMMON_PORTRAIT_BEASTBOY
  HUD_SUMMON_PORTRAITS_GREY = []
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_ROBIN] = g.assets.hud.HUD_SUMMON_PORTRAIT_ROBIN
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_RAVEN] = g.assets.hud.HUD_SUMMON_PORTRAIT_RAVEN
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_CYBORG] = g.assets.hud.HUD_SUMMON_PORTRAIT_CYBORG
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_STARFIRE] = g.assets.hud.HUD_SUMMON_PORTRAIT_STARFIRE
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_BEASTBOY] = g.assets.hud.HUD_SUMMON_PORTRAIT_BEASTBOY
  HUD_NAMES = []
  HUD_NAMES[g.FIGHTER_ID_ROBIN] = g.assets.hud.HUD_NAME_ROBIN
  HUD_NAMES[g.FIGHTER_ID_RAVEN] = g.assets.hud.HUD_NAME_RAVEN
  HUD_NAMES[g.FIGHTER_ID_CYBORG] = g.assets.hud.HUD_NAME_CYBORG
  HUD_NAMES[g.FIGHTER_ID_STARFIRE] = g.assets.hud.HUD_NAME_STARFIRE
  HUD_NAMES[g.FIGHTER_ID_BEASTBOY] = g.assets.hud.HUD_NAME_BEASTBOY
  HUD_NAMES[g.FIGHTER_ID_JINX] = g.assets.hud.HUD_NAME_JINX
  HUD_NAMES[g.FIGHTER_ID_MAMMOTH] = g.assets.hud.HUD_NAME_MAMMOTH
  HUD_NAMES[g.FIGHTER_ID_GIZMO] = g.assets.hud.HUD_NAME_GIZMO
  HUD_NAMES[g.FIGHTER_ID_CINDERBLOCK] = g.assets.hud.HUD_NAME_CINDERBLOCK
  HUD_NAMES[g.FIGHTER_ID_PLASMUS] = g.assets.hud.HUD_NAME_PLASMUS
  hudBG = new(g.classes.Class_StaticOverlay, g.assets.hud.HUD_BG, point(0, 0), g.SPRITE_LOCZ_HUD_BG)
  titanHealthBar = new(g.classes.Class_HUDHealthBar, g.game.titan, point(278, 21), 1)
  villainHealthBar = new(g.classes.Class_HUDHealthBar, g.game.villain, point(322, 21), 0)
  titanPortrait = new(g.classes.Class_StaticOverlay, HUD_PORTRAITS[g.titanID], point(0, 3), g.SPRITE_LOCZ_HUD_FG)
  titanPortrait.setInk(g.INK_MATTE)
  villainPortrait = new(g.classes.Class_StaticOverlay, HUD_PORTRAITS[g.villainID], point(600, 3), g.SPRITE_LOCZ_HUD_FG)
  villainPortrait.setInk(g.INK_MATTE)
  villainPortrait.setFlipX(1)
  titanName = new(g.classes.Class_StaticOverlay, HUD_NAMES[g.titanID], point(10 + (HUD_NAMES[g.titanID].width / 2), 55), g.SPRITE_LOCZ_HUD_FG)
  titanName.getSprite().ink = g.INK_MATTE
  villainName = new(g.classes.Class_StaticOverlay, HUD_NAMES[g.villainID], point(590 - (HUD_NAMES[g.villainID].width / 2), 55), g.SPRITE_LOCZ_HUD_FG)
  villainName.getSprite().ink = g.INK_MATTE
  clock = new(g.classes.Class_HUDClock, point(300, 42))
  titanWin1 = new(g.classes.Class_StaticOverlay, g.assets.hud.HUD_WIN_LEFT_OFF, point(269, 54), g.SPRITE_LOCZ_HUD_BG)
  titanWin2 = new(g.classes.Class_StaticOverlay, g.assets.hud.HUD_WIN_LEFT_OFF, point(223, 54), g.SPRITE_LOCZ_HUD_BG)
  villainWin1 = new(g.classes.Class_StaticOverlay, g.assets.hud.HUD_WIN_RIGHT_OFF, point(331, 54), g.SPRITE_LOCZ_HUD_BG)
  villainWin2 = new(g.classes.Class_StaticOverlay, g.assets.hud.HUD_WIN_RIGHT_OFF, point(377, 54), g.SPRITE_LOCZ_HUD_BG)
  summonPortraits = g.util.newArray(g.FIGHTER_COUNT, VOID)
  x = 0
  repeat with i = 1 to g.TITAN_FIGHTER_ORDER.count
    if g.game.canSummon(g.game.titan, i) then
      summonPortraits[g.TITAN_FIGHTER_ORDER[i]] = new(g.classes.Class_HUDSummonPortrait, g.TITAN_FIGHTER_ORDER[i], point(90 + x, 10))
      x = x + 34
    end if
  end repeat
  flashOverlay = new(g.classes.Class_StaticOverlay, g.assets.hud.HUD_SCREEN_FLASH, point(300, 200), g.SPRITE_LOCZ_SCREEN_FLASH)
  flashOverlay.visSprite.rect = rect(0, 0, 600, 400)
  flashOverlay.visSprite.ink = g.INK_COPY
  flashOverlay.setVisible(0)
  flashDuration = 0
  fpsIndicator = new(g.classes.Class_StaticOverlay, member("FPS"), point(5, 380), 200)
  fpsIndicator.setVisible(0)
  score = new(g.classes.Class_HUDScore, point(328, 9))
  return me
end

on destroy me
  score.destroy()
  fpsIndicator.destroy()
  titanWin1.destroy()
  titanWin2.destroy()
  villainWin1.destroy()
  villainWin2.destroy()
  clock.destroy()
  villainName.destroy()
  titanName.destroy()
  repeat with o in summonPortraits
    if not voidp(o) then
      o.destroy()
    end if
  end repeat
  villainPortrait.destroy()
  titanPortrait.destroy()
  villainHealthBar.destroy()
  titanHealthBar.destroy()
  hudBG.destroy()
  return VOID
end

on reset me
  titanHealthBar.reset()
  villainHealthBar.reset()
end

on update me
  if fpsIndicator.isVisible() then
    fpsIndicator.getSprite().member.text = string(integer(g.fps)) && "fps"
  end if
  clock.update()
  titanHealthBar.update()
  villainHealthBar.update()
  if flashOverlay.isVisible() then
    if flashDuration = 0 then
      flashOverlay.setVisible(0)
    else
      flashDuration = flashDuration - 1
    end if
  end if
  repeat with o in summonPortraits
    if not voidp(o) then
      o.update()
    end if
  end repeat
  score.update()
end

on paint me
  clock.paint()
  titanHealthBar.paint()
  villainHealthBar.paint()
  score.paint()
end

on setTitanWins me, i
  if i = 2 then
    titanWin1.setMember(g.assets.hud.HUD_WIN_LEFT_ON)
    titanWin2.setMember(g.assets.hud.HUD_WIN_LEFT_ON)
  else
    if i = 1 then
      titanWin1.setMember(g.assets.hud.HUD_WIN_LEFT_ON)
      titanWin2.setMember(g.assets.hud.HUD_WIN_LEFT_OFF)
    else
      titanWin1.setMember(g.assets.hud.HUD_WIN_LEFT_OFF)
      titanWin2.setMember(g.assets.hud.HUD_WIN_LEFT_OFF)
    end if
  end if
end

on setVillainWins me, i
  if i = 2 then
    villainWin1.setMember(g.assets.hud.HUD_WIN_RIGHT_ON)
    villainWin2.setMember(g.assets.hud.HUD_WIN_RIGHT_ON)
  else
    if i = 1 then
      villainWin1.setMember(g.assets.hud.HUD_WIN_RIGHT_ON)
      villainWin2.setMember(g.assets.hud.HUD_WIN_RIGHT_OFF)
    else
      villainWin1.setMember(g.assets.hud.HUD_WIN_RIGHT_OFF)
      villainWin2.setMember(g.assets.hud.HUD_WIN_RIGHT_OFF)
    end if
  end if
end

on showFPS me, b
  fpsIndicator.setVisible(b)
end

on isFPS me
  return fpsIndicator.isVisible()
end

on flashScreen me, dur
  flashDuration = dur
  flashOverlay.setVisible(1)
end

on useSummonPortrait me, id
  if not voidp(summonPortraits[id]) then
    summonPortraits[id].trigger()
  end if
end

on resetSummonPortraits me
  repeat with o in summonPortraits
    if not voidp(o) then
      o.reset()
    end if
  end repeat
end
