global g

on mouseEnter me
  cursor(280)
  sprite(me.spriteNum).member = member("play_over", "select_screen")
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEOVER, 100, g.SFX_EVENT_PRIORITY_LOW)
end

on mouseLeave me
  sprite(me.spriteNum).member = member("button_fight_000", "select_screen")
  cursor(-1)
end

on mouseUp me
  sprite(me.spriteNum).member = member("button_fight_000", "select_screen")
  cursor(-1)
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_CHARACTERSWITCH3, 100, g.SFX_EVENT_PRIORITY_LOW)
  g.game.setPause(0)
end
