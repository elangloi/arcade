global g

on mouseEnter me
  cursor(280)
  sprite(me.spriteNum).member = member("back_button_over", "win_screen")
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEOVER, 100, g.SFX_EVENT_PRIORITY_LOW)
end

on mouseLeave me
  sprite(me.spriteNum).member = member("back_button", "win_screen")
  cursor(-1)
end

on mouseUp me
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNFIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
  go("SCREEN_SELECTFIGHTER")
end
