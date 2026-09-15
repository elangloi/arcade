global g

on exitFrame me
  case g.playerID of
    g.FIGHTER_ID_ROBIN:
      g.goFrame = label("SCREEN_SELECTFIGHTER_ROBIN")
    g.FIGHTER_ID_RAVEN:
      g.goFrame = label("SCREEN_SELECTFIGHTER_RAVEN")
    g.FIGHTER_ID_CYBORG:
      g.goFrame = label("SCREEN_SELECTFIGHTER_CYBORG")
    g.FIGHTER_ID_STARFIRE:
      g.goFrame = label("SCREEN_SELECTFIGHTER_STARFIRE")
    g.FIGHTER_ID_BEASTBOY:
      g.goFrame = label("SCREEN_SELECTFIGHTER_BEASTBOY")
    g.FIGHTER_ID_JINX:
      g.goFrame = label("SCREEN_SELECTFIGHTER_JINX")
    g.FIGHTER_ID_GIZMO:
      g.goFrame = label("SCREEN_SELECTFIGHTER_GIZMO")
    g.FIGHTER_ID_MAMMOTH:
      g.goFrame = label("SCREEN_SELECTFIGHTER_MAMMOTH")
    g.FIGHTER_ID_CINDERBLOCK:
      g.goFrame = label("SCREEN_SELECTFIGHTER_CINDERBLOCK")
    g.FIGHTER_ID_PLASMUS:
      g.goFrame = label("SCREEN_SELECTFIGHTER_PLASMUS")
  end case
  pass()
end
