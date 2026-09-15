global g

on beginSprite me
  sprite(me.spriteNum).visible = 0
  sprite(11).visible = 1
  sprite(18).visible = 1
  sprite(18).member = member("loop_figure_" & g.main.screen.fighterNames[g.enemyID], "select_screen")
end

on endSprite me
  sprite(me.spriteNum).visible = 1
end
