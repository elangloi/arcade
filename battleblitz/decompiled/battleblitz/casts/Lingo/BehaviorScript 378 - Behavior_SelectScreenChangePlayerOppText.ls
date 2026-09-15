global g

on beginSprite me
  if g.playMode = g.PLAYMODE_AS_TITANS then
    sprite(me.spriteNum).member = member("loop_player_opp_text_as_titans")
  else
    sprite(me.spriteNum).member = member("loop_player_opp_text_as_villains")
  end if
end
