global g

on beginSprite me
  if g.playMode = g.PLAYMODE_AS_TITANS then
    sprite(me.spriteNum).member = member("tt_ending_titans", "win_screen")
  else
    sprite(me.spriteNum).member = member("tt_ending_villains", "win_screen")
  end if
end

on endSprite me
end
