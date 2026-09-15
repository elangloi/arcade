global g

on beginSprite me
  sprite(me.spriteNum).member = member("bg_head_" & g.main.screen.fighterNames[g.enemyID], "select_screen")
end
