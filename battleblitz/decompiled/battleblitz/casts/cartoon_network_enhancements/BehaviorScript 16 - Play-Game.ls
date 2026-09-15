on mouseUp
  global gTrackerURL, gBillboardNetID
  if gTrackerURL <> VOID then
    gBillboardNetID = preloadNetThing(gTrackerURL & "?id=" & the ticks)
  end if
  if gTrackerURL <> VOID then
    member("Info").text = "(Tracker message sent.)"
    updateStage()
    startTimer()
    repeat while the timer < 60
    end repeat
    member("Info").text = EMPTY
    updateStage()
  end if
  go("Game")
end
