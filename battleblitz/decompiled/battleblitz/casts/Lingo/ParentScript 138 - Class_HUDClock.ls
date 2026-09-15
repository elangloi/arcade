property DIGIT_WIDTH, PIE_SLICE_COUNT, pos, time, digitMembers, pieOffMembers, pieOnMembers, digit1, digit2, pieSlices, secondsPerSlice, timeThresholds
global g

on new me, initPos
  pos = initPos
  DIGIT_WIDTH = 16
  PIE_SLICE_COUNT = 6
  secondsPerSlice = g.ROUND_DURATION / PIE_SLICE_COUNT
  timeThresholds = []
  repeat with i = 1 to PIE_SLICE_COUNT
    timeThresholds.append(g.ROUND_DURATION - (i * secondsPerSlice))
  end repeat
  digitMembers = [g.assets.hud.HUD_CLOCK_NUM_0, g.assets.hud.HUD_CLOCK_NUM_1, g.assets.hud.HUD_CLOCK_NUM_2, g.assets.hud.HUD_CLOCK_NUM_3, g.assets.hud.HUD_CLOCK_NUM_4, g.assets.hud.HUD_CLOCK_NUM_5, g.assets.hud.HUD_CLOCK_NUM_6, g.assets.hud.HUD_CLOCK_NUM_7, g.assets.hud.HUD_CLOCK_NUM_8, g.assets.hud.HUD_CLOCK_NUM_9]
  digit1 = new(g.classes.Class_Overlay, pos + point(DIGIT_WIDTH / 2, 0), g.SPRITE_LOCZ_HUD_FG)
  digit2 = new(g.classes.Class_Overlay, pos + point(-DIGIT_WIDTH / 2, 0), g.SPRITE_LOCZ_HUD_FG)
  pieOffMembers = [g.assets.hud.HUD_CLOCK_PIE_OFF_1, g.assets.hud.HUD_CLOCK_PIE_OFF_2, g.assets.hud.HUD_CLOCK_PIE_OFF_3, g.assets.hud.HUD_CLOCK_PIE_OFF_4, g.assets.hud.HUD_CLOCK_PIE_OFF_5, g.assets.hud.HUD_CLOCK_PIE_OFF_6]
  pieOnMembers = [g.assets.hud.HUD_CLOCK_PIE_ON_1, g.assets.hud.HUD_CLOCK_PIE_ON_2, g.assets.hud.HUD_CLOCK_PIE_ON_3, g.assets.hud.HUD_CLOCK_PIE_ON_4, g.assets.hud.HUD_CLOCK_PIE_ON_5, g.assets.hud.HUD_CLOCK_PIE_ON_6]
  pieSlices = []
  repeat with i = 1 to PIE_SLICE_COUNT
    pieSlices.append(new(g.classes.Class_Overlay, pos, g.SPRITE_LOCZ_HUD_BG))
  end repeat
  time = -1
  return me
end

on destroy me
  repeat with o in pieSlices
    o.destroy()
  end repeat
  digit1.destroy()
  digit2.destroy()
  return VOID
end

on checkClock me, newTime
  if newTime <> time then
    time = newTime
    me.buildClock()
  end if
end

on buildClock me
  repeat with i = 1 to PIE_SLICE_COUNT
    if time <= timeThresholds[i] then
      pieSlices[i].setMember(pieOffMembers[i])
      next repeat
    end if
    pieSlices[i].setMember(pieOnMembers[i])
  end repeat
  digit1.setMember(digitMembers[(time mod 10) + 1])
  digit2.setMember(digitMembers[(time / 10 mod 10) + 1])
end

on update me
  me.checkClock(g.game.getTime())
end

on paint me
end
