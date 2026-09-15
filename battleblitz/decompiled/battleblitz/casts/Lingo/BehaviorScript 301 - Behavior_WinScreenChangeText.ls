global g

on beginSprite me
  txtMems = []
  txtMems[g.FIGHTER_ID_ROBIN] = member("tt_ending_txt_robin", "win_screen")
  txtMems[g.FIGHTER_ID_RAVEN] = member("tt_ending_txt_raven", "win_screen")
  txtMems[g.FIGHTER_ID_CYBORG] = member("tt_ending_txt_cyborg", "win_screen")
  txtMems[g.FIGHTER_ID_STARFIRE] = member("tt_ending_txt_starfire", "win_screen")
  txtMems[g.FIGHTER_ID_BEASTBOY] = member("tt_ending_txt_beastboy", "win_screen")
  txtMems[g.FIGHTER_ID_JINX] = member("tt_ending_txt_villain", "win_screen")
  txtMems[g.FIGHTER_ID_GIZMO] = member("tt_ending_txt_villain", "win_screen")
  txtMems[g.FIGHTER_ID_MAMMOTH] = member("tt_ending_txt_villain", "win_screen")
  txtMems[g.FIGHTER_ID_CINDERBLOCK] = member("tt_ending_txt_villain", "win_screen")
  txtMems[g.FIGHTER_ID_PLASMUS] = member("tt_ending_txt_villain", "win_screen")
  defeatedAll = 1
  repeat with i in g.VILLAIN_FIGHTER_ORDER
    repeat with j in g.TITAN_FIGHTER_ORDER
      defeatedAll = defeatedAll and g.defeatedEnemies[j][i]
    end repeat
  end repeat
  if defeatedAll and (g.playMode = g.PLAYMODE_AS_TITANS) then
    sprite(me.spriteNum).member = member("tt_ending_txt_ALL", "win_screen")
  else
    sprite(me.spriteNum).member = txtMems[g.playerID]
  end if
end

on endSprite me
end
