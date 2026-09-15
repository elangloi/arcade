global g

on beginSprite me
  g.main.loadScreen(g.SCREEN_TITLE)
end

on endSprite me
  if objectp(g) then
    if objectp(g.main) then
      g.main.unloadScreen()
    end if
  end if
end
