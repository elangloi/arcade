global gBillboardNetID, gBillboardState, gBillboardDelay, gBillboardMember, gBGColor, gBillboardURL, gBillboardDuration, gBillboardDimension, gBillboardLink, gOrbitURL, gTrackerURL

on beginSprite
  gBillboardState = "Download"
  puppetSprite(1, 1)
  aStageWidth = the stageRight - the stageLeft
  aStageHeight = the stageBottom - the stageTop
  sprite(1).loc = point(aStageWidth / 2, aStageHeight / 2)
  gBGColor = (the stage).bgColor
  (the stage).bgColor = rgb(0, 0, 0)
end

on exitFrame
  case gBillboardState of
    "Download", VOID:
      gBillboardURL = externalParamValue("sw1")
      gBillboardDuration = value(externalParamValue("sw2"))
      gBillboardLink = externalParamValue("sw4")
      gOrbitURL = externalParamValue("sw6")
      gTrackerURL = externalParamValue("sw7")
      gBillboardMember = VOID
      gBillboardDelay = the ticks + (15 * 60)
      if gBillboardDuration = VOID then
        gBillboardDuration = 7
      end if
      gBillboardNetID = -1
      if gBillboardURL <> VOID then
        gBillboardNetID = preloadNetThing(gBillboardURL)
      end if
      gBillboardState = "Downloading"
    "Downloading":
      if (netDone(gBillboardNetID) <> 0) or (gBillboardDelay < the ticks) then
        gBillboardState = "Downloaded"
      end if
    "Downloaded":
      if netError(gBillboardNetID) = "OK" then
        gBillboardMember = new(#bitmap)
        if gBillboardURL <> VOID then
          importFileInto(gBillboardMember, gBillboardURL)
        end if
        sprite(1).member = gBillboardMember
        gBillboardDelay = the ticks + (gBillboardDuration * 60)
      else
        gBillboardDelay = 0
      end if
      gBillboardState = "Display Billboard"
    "Display Billboard":
      if gBillboardDelay < the ticks then
        if gBillboardMember <> VOID then
          erase(gBillboardMember)
        end if
        gBillboardDelay = the ticks + (gBillboardDuration * 60)
        if gOrbitURL <> VOID then
          gBillboardState = "Display Orbit"
          sprite(1).member = "Orbit Screen"
        else
          gBillboardState = VOID
        end if
      end if
    "Display Orbit":
      if gBillboardDelay < the ticks then
        gBillboardState = VOID
      end if
    otherwise:
      gBillboardState = "Download"
  end case
  if gBillboardState <> VOID then
    go(the frame)
  else
    (the stage).bgColor = gBGColor
    sprite(1).loc = point(-1000, -1000)
    puppetSprite(1, 0)
    go(#next)
  end if
end

on mouseDown
  case gBillboardState of
    "Display Billboard":
      gBillboardDelay = 0
      if gBillboardLink <> VOID then
        gotoNetPage(gBillboardLink, "_blank")
      end if
    "Display Orbit":
      gBillboardDelay = 0
  end case
end
