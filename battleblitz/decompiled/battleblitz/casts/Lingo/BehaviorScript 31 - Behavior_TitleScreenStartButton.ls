global g

on mouseEnter me
  cursor(280)
  tell sprite(me.spriteNum)
    go(1)
  end tell
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEOVER, 100, g.SFX_EVENT_PRIORITY_LOW)
end

on mouseLeave me
  cursor(-1)
end

on mouseUp me
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNFIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
  g.goFrame = label("Billboard")
end
