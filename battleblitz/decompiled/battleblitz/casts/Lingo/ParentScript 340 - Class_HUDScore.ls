property SCORE_DIGIT_COUNT, DELTA_SCORE_RATE, scoreOverlays, scoreNumberMembers, displayedScore, targetScore, scoreDivisors
global g

on new me, initPos
  SCORE_DIGIT_COUNT = 8
  DELTA_SCORE_RATE = 350
  scoreNumberMembers = [g.assets.hud.HUD_SCORE_NUMBER_0, g.assets.hud.HUD_SCORE_NUMBER_1, g.assets.hud.HUD_SCORE_NUMBER_2, g.assets.hud.HUD_SCORE_NUMBER_3, g.assets.hud.HUD_SCORE_NUMBER_4, g.assets.hud.HUD_SCORE_NUMBER_5, g.assets.hud.HUD_SCORE_NUMBER_6, g.assets.hud.HUD_SCORE_NUMBER_7, g.assets.hud.HUD_SCORE_NUMBER_8, g.assets.hud.HUD_SCORE_NUMBER_9]
  digitOffset = point(-8, 0)
  scoreOverlays = []
  repeat with i = 1 to SCORE_DIGIT_COUNT
    o = new(g.classes.Class_Overlay, initPos + (digitOffset * (i - 1)), g.SPRITE_LOCZ_HUD_FG)
    scoreOverlays.append(o)
  end repeat
  displayedScore = 0
  targetScore = 0
  scoreDivisors = []
  x = 1
  repeat with i = 1 to SCORE_DIGIT_COUNT + 1
    scoreDivisors.append(x)
    x = x * 10
  end repeat
  me.updateOverlays()
  return me
end

on destroy me
  repeat with o in scoreOverlays
    o.destroy()
  end repeat
  return VOID
end

on updateOverlays me
  scoreDelta = targetScore - displayedScore
  if scoreDelta > DELTA_SCORE_RATE then
    scoreDelta = DELTA_SCORE_RATE
  end if
  displayedScore = displayedScore + scoreDelta
  repeat with i = 1 to SCORE_DIGIT_COUNT
    o = scoreOverlays[i]
    digit = displayedScore mod scoreDivisors[i + 1] / scoreDivisors[i]
    o.setMember(scoreNumberMembers[digit + 1])
  end repeat
end

on reset me
  targetScore = 1.0
  displayedScore = 1.0
  me.updateOverlays()
end

on update me
  newScore = g.game.getScore()
  if newScore <> targetScore then
    targetScore = newScore
  end if
  if targetScore <> displayedScore then
    me.updateOverlays()
  end if
end

on paint me
  repeat with o in scoreOverlays
    o.paint()
  end repeat
end
