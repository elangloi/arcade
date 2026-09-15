property audioMgr, keyMgr, screenList, screen, currScreenID, prevScreenID
global g

on new me
  screenList = []
  screenList[g.SCREEN_TITLE] = new(g.classes.Class_TitleScreen)
  screenList[g.SCREEN_INTRO] = new(g.classes.Class_IntroScreen)
  screenList[g.SCREEN_SELECTFIGHTER] = new(g.classes.Class_SelectFighterScreen)
  screenList[g.SCREEN_CONTROLS] = new(g.classes.Class_ControlsScreen)
  screenList[g.SCREEN_VERSUS] = new(g.classes.Class_VersusScreen)
  screenList[g.SCREEN_GAME] = new(g.classes.Class_GameScreen)
  screenList[g.SCREEN_WIN] = new(g.classes.Class_WinScreen)
  audioMgr = new(g.classes.Class_AudioManager)
  keyMgr = new(g.classes.Class_KeyManager)
  currScreenID = 0
  prevScreenID = 0
  return me
end

on destroy me
  repeat with o in screenList
    if objectp(o) then
      o = o.destroy()
    end if
  end repeat
  audioMgr = audioMgr.destroy()
  keyMgr = keyMgr.destroy()
  return VOID
end

on loadScreen me, s
  prevScreenID = currScreenID
  currScreenID = s
  unloadScreen()
  screen = screenList[s]
  g.screen = screen
  screen.load()
  cursor(-1)
end

on unloadScreen me
  if not voidp(screen) then
    screen.unload()
    screen = VOID
    g.screen = VOID
  end if
end

on update me
  repeat while 1
    audioMgr.update()
    keyMgr.update()
    if (the milliSeconds - g.frameTimestamp) >= g.FRAME_DURATION_MIN then
      exit repeat
    end if
  end repeat
  i = the milliSeconds
  g.fps = 1.0 / (float(i - g.frameTimestamp) * 0.001)
  g.frameTimestamp = i
  g.frameCount = g.frameCount + 1
  if objectp(screen) then
    screen.update()
  end if
end

on paint me
  if objectp(screen) then
    screen.paint()
  end if
end

on branch me
  if g.goFrame then
    i = g.goFrame
    g.goFrame = 0
    go(i)
  end if
end
