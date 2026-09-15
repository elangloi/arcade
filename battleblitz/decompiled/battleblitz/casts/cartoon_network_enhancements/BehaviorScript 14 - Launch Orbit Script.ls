on beginSprite
  global gOrbitURL
  if gOrbitURL <> VOID then
    gotoNetPage(gOrbitURL, "Orbit")
  end if
end

on exitFrame
  go("Win animation")
end
