property HEALTHBAR_COLOR_GREEN, HEALTHBAR_COLOR_ORANGE, HEALTHBAR_COLOR_RED, HEALTHBAR_COLOR_WHITE, HEALTHBAR_SLICE_COUNT, HEALTHBAR_END_SLICE_COUNT, HEALTHBAR_MIDDLE_SLICE_COUNT, HEALTHBAR_SLICE_WIDTH, HEALTHBAR_HEIGHT, HEALTHBAR_DELTA_FILL_MAX, HEALTHBAR_HILITE_DURATION, source, pos, dir, maxVal, endMembers, middleMembers, lowOverlay, middleOverlays, highOverlay, barColor, targetFill, displayFill, hiliteFrames
global g

on new me, obj, initPos, initFlipX
  source = obj
  pos = initPos
  maxVal = float(obj.getHealth())
  if initFlipX then
    dir = -1
  else
    dir = 1
  end if
  HEALTHBAR_COLOR_GREEN = 1
  HEALTHBAR_COLOR_ORANGE = 2
  HEALTHBAR_COLOR_RED = 3
  HEALTHBAR_COLOR_WHITE = 4
  HEALTHBAR_SLICE_COUNT = 70
  HEALTHBAR_END_SLICE_COUNT = 6
  HEALTHBAR_MIDDLE_SLICE_COUNT = 10
  HEALTHBAR_SLICE_WIDTH = 3
  HEALTHBAR_HEIGHT = 19
  HEALTHBAR_DELTA_FILL_MAX = 0.0143
  HEALTHBAR_HILITE_DURATION = 8
  endMembers = []
  endMembers[HEALTHBAR_COLOR_GREEN] = [g.assets.hud.HUD_LIFEBAR_END_GREEN_01, g.assets.hud.HUD_LIFEBAR_END_GREEN_02, g.assets.hud.HUD_LIFEBAR_END_GREEN_03, g.assets.hud.HUD_LIFEBAR_END_GREEN_04, g.assets.hud.HUD_LIFEBAR_END_GREEN_05, g.assets.hud.HUD_LIFEBAR_END_GREEN_06]
  endMembers[HEALTHBAR_COLOR_ORANGE] = [g.assets.hud.HUD_LIFEBAR_END_ORANGE_01, g.assets.hud.HUD_LIFEBAR_END_ORANGE_02, g.assets.hud.HUD_LIFEBAR_END_ORANGE_03, g.assets.hud.HUD_LIFEBAR_END_ORANGE_04, g.assets.hud.HUD_LIFEBAR_END_ORANGE_05, g.assets.hud.HUD_LIFEBAR_END_ORANGE_06]
  endMembers[HEALTHBAR_COLOR_RED] = [g.assets.hud.HUD_LIFEBAR_END_RED_01, g.assets.hud.HUD_LIFEBAR_END_RED_02, g.assets.hud.HUD_LIFEBAR_END_RED_03, g.assets.hud.HUD_LIFEBAR_END_RED_04, g.assets.hud.HUD_LIFEBAR_END_RED_05, g.assets.hud.HUD_LIFEBAR_END_RED_06]
  endMembers[HEALTHBAR_COLOR_WHITE] = [g.assets.hud.HUD_LIFEBAR_END_WHITE_01, g.assets.hud.HUD_LIFEBAR_END_WHITE_02, g.assets.hud.HUD_LIFEBAR_END_WHITE_03, g.assets.hud.HUD_LIFEBAR_END_WHITE_04, g.assets.hud.HUD_LIFEBAR_END_WHITE_05, g.assets.hud.HUD_LIFEBAR_END_WHITE_06]
  middleMembers = []
  middleMembers[HEALTHBAR_COLOR_GREEN] = [g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_01, g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_02, g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_03, g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_04, g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_05, g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_06, g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_07, g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_08, g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_09, g.assets.hud.HUD_LIFEBAR_MIDDLE_GREEN_10]
  middleMembers[HEALTHBAR_COLOR_ORANGE] = [g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_01, g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_02, g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_03, g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_04, g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_05, g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_06, g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_07, g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_08, g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_09, g.assets.hud.HUD_LIFEBAR_MIDDLE_ORANGE_10]
  middleMembers[HEALTHBAR_COLOR_RED] = [g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_01, g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_02, g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_03, g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_04, g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_05, g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_06, g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_07, g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_08, g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_09, g.assets.hud.HUD_LIFEBAR_MIDDLE_RED_10]
  middleMembers[HEALTHBAR_COLOR_WHITE] = [g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_01, g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_02, g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_03, g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_04, g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_05, g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_06, g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_07, g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_08, g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_09, g.assets.hud.HUD_LIFEBAR_MIDDLE_WHITE_10]
  barColor = HEALTHBAR_COLOR_GREEN
  lowOverlay = new(g.classes.Class_Overlay, initPos, g.SPRITE_LOCZ_HUD_BG)
  lowOverlay.setFlipX(initFlipX)
  middleOverlays = []
  repeat with i = 0 to 6
    o = new(g.classes.Class_Overlay, initPos + point(dir * (HEALTHBAR_HEIGHT + (i * 10 * HEALTHBAR_SLICE_WIDTH)), 0), g.SPRITE_LOCZ_HUD_BG)
    o.setFlipX(initFlipX)
    middleOverlays.append(o)
  end repeat
  highOverlay = new(g.classes.Class_Overlay, initPos, g.SPRITE_LOCZ_HUD_BG)
  highOverlay.setFlipX(not initFlipX)
  highOverlay.setFlipY(1)
  targetFill = 1.0
  displayFill = 1.0
  hiliteFrames = 0
  me.buildBar()
  return me
end

on destroy me
  lowOverlay.destroy()
  repeat with o in middleOverlays
    o.destroy()
  end repeat
  highOverlay.destroy()
  return VOID
end

on checkBar me, health
  newTarget = float(health) / maxVal
  if newTarget <> targetFill then
    targetFill = newTarget
    hiliteFrames = HEALTHBAR_HILITE_DURATION
  end if
  if hiliteFrames then
    hiliteFrames = hiliteFrames - 1
    me.buildBar()
  else
    if targetFill <> displayFill then
      me.buildBar()
    end if
  end if
end

on buildBar me
  fillDelta = targetFill - displayFill
  if fillDelta < -HEALTHBAR_DELTA_FILL_MAX then
    fillDelta = -HEALTHBAR_DELTA_FILL_MAX
  else
    if fillDelta > HEALTHBAR_DELTA_FILL_MAX then
      fillDelta = HEALTHBAR_DELTA_FILL_MAX
    end if
  end if
  displayFill = displayFill + fillDelta
  if hiliteFrames then
    barColor = HEALTHBAR_COLOR_WHITE
  else
    if displayFill > 0.66000000000000003 then
      barColor = HEALTHBAR_COLOR_GREEN
    else
      if displayFill > 0.33000000000000002 then
        barColor = HEALTHBAR_COLOR_ORANGE
      else
        barColor = HEALTHBAR_COLOR_RED
      end if
    end if
  end if
  slices = g.util.ceiling(displayFill * HEALTHBAR_SLICE_COUNT)
  index = slices
  if index <= 0 then
    lowOverlay.setVisible(0)
    highOverlay.setVisible(0)
  else
    lowOverlay.setVisible(1)
    highOverlay.setVisible(1)
    if index > HEALTHBAR_END_SLICE_COUNT then
      index = HEALTHBAR_END_SLICE_COUNT
    end if
    lowOverlay.setMember(endMembers[barColor][index])
    highOverlay.setMember(endMembers[barColor][index])
  end if
  highOverlay.setPos(pos + point(dir * ((slices * HEALTHBAR_SLICE_WIDTH) + HEALTHBAR_HEIGHT + 1), HEALTHBAR_HEIGHT + 1))
  repeat with i = 0 to middleOverlays.count - 1
    o = middleOverlays[i + 1]
    index = slices - HEALTHBAR_END_SLICE_COUNT - (10 * i)
    if index <= 0 then
      o.setVisible(0)
      next repeat
    end if
    o.setVisible(1)
    if index > 10 then
      index = 10
    end if
    o.setMember(middleMembers[barColor][index])
  end repeat
end

on reset me
  targetFill = 1.0
  displayFill = 1.0
  hiliteFrames = 0
  me.buildBar()
end

on update me
  me.checkBar(source.getHealth())
end

on paint me
  lowOverlay.paint()
  repeat with o in middleOverlays
    o.paint()
  end repeat
  highOverlay.paint()
end
