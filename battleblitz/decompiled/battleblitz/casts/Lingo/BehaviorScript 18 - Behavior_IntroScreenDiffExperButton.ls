global g

on mouseEnter me
  cursor(280)
  sprite(me.spriteNum).member = member("loop_intro_button_exper", "title_screen")
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEOVER, 100, g.SFX_EVENT_PRIORITY_LOW)
end

on mouseLeave me
  sprite(me.spriteNum).member = member("intro_diff_button_border_exper", "title_screen")
  cursor(-1)
end

on mouseUp me
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNFIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
  g.difficulty = g.DIFFICULTY_EXPERT
  g.main.screen.advanceStage()
end
