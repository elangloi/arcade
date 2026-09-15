global g

on mouseEnter me
  cursor(280)
  sprite(me.spriteNum).member = member("controls_over", "select_screen")
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEOVER, 100, g.SFX_EVENT_PRIORITY_LOW)
end

on mouseLeave me
  sprite(me.spriteNum).member = member("button_controls_012", "select_screen")
  cursor(-1)
end

on mouseUp me
  sprite(me.spriteNum).member = member("button_controls_012", "select_screen")
  cursor(-1)
  case g.playerID of
    g.FIGHTER_ID_ROBIN:
      g.goFrame = label("SCREEN_CONTROLS_ROBIN")
    g.FIGHTER_ID_RAVEN:
      g.goFrame = label("SCREEN_CONTROLS_RAVEN")
    g.FIGHTER_ID_CYBORG:
      g.goFrame = label("SCREEN_CONTROLS_CYBORG")
    g.FIGHTER_ID_STARFIRE:
      g.goFrame = label("SCREEN_CONTROLS_STARFIRE")
    g.FIGHTER_ID_BEASTBOY:
      g.goFrame = label("SCREEN_CONTROLS_BEASTBOY")
    g.FIGHTER_ID_JINX:
      g.goFrame = label("SCREEN_CONTROLS_JINX")
    g.FIGHTER_ID_GIZMO:
      g.goFrame = label("SCREEN_CONTROLS_GIZMO")
    g.FIGHTER_ID_MAMMOTH:
      g.goFrame = label("SCREEN_CONTROLS_MAMMOTH")
    g.FIGHTER_ID_CINDERBLOCK:
      g.goFrame = label("SCREEN_CONTROLS_CINDERBLOCK")
    g.FIGHTER_ID_PLASMUS:
      g.goFrame = label("SCREEN_CONTROLS_PLASMUS")
  end case
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNFIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
end
