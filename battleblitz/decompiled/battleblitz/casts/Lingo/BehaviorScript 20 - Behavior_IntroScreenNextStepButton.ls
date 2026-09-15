global g

on mouseEnter me
  cursor(280)
  sprite(me.spriteNum).member = member("loop_intro_next_button", "title_screen")
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEOVER, 100, g.SFX_EVENT_PRIORITY_LOW)
end

on mouseLeave me
  sprite(me.spriteNum).member = member("intro_next_border", "title_screen")
  cursor(-1)
end

on mouseUp me
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNFIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
  g.main.screen.advanceStage()
end
