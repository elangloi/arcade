global g

on mouseEnter me
  cursor(280)
  sprite(me.spriteNum).member = member("back_over", "select_screen")
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEOVER, 100, g.SFX_EVENT_PRIORITY_LOW)
end

on mouseLeave me
  sprite(me.spriteNum).member = member("back_008", "select_screen")
  cursor(-1)
end

on mouseUp me
  global g
  g.goFrame = the frame + 1
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNFIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
end
