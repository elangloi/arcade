global g

on beginSprite me
  case g.game.roundNum of
    1:
      sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_ROUND_NUM1
    2:
      sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_ROUND_NUM2
    3:
      sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_ROUND_NUM3
  end case
end

on endSprite me
end
