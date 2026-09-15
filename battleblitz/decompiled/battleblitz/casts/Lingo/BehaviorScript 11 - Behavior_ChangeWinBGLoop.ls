global g

on beginSprite me
  if g.game.playerWins > g.game.enemyWins then
    if g.playMode = g.PLAYMODE_AS_TITANS then
      sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.LOOP_TITAN_WINS
    else
      sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.LOOP_VILLAIN_WINS
    end if
  else
    if g.playMode = g.PLAYMODE_AS_TITANS then
      sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.LOOP_VILLAIN_WINS
    else
      sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.LOOP_TITAN_WINS
    end if
  end if
end
