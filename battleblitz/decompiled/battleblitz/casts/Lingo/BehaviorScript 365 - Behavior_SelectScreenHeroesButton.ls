global g

on beginSprite me
  if (the mouseLoc).inside(sprite(me.spriteNum).rect) then
    cursor(280)
    sprite(me.spriteNum).member = member("loop_play_as_titans_button_over", "select_screen")
  end if
end

on mouseEnter me
  cursor(280)
  sprite(me.spriteNum).member = member("loop_play_as_titans_button_over", "select_screen")
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEOVER, 100, g.SFX_EVENT_PRIORITY_LOW)
end

on mouseLeave me
  sprite(me.spriteNum).member = member("select_heroes.off", "select_screen")
  cursor(-1)
end

on mouseUp me
  sprite(me.spriteNum).member = member("select_heroes.off", "select_screen")
  cursor(-1)
  g.main.screen.setPlayMode(g.PLAYMODE_AS_TITANS)
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNFIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
end
