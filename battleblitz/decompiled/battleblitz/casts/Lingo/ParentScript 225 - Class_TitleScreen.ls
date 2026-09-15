property SCREENSTAGE_LOAD, SCREENSTAGE_WAIT, ancestor, screenStage, initStage, delayFrames, preloader
global g

on new me
  ancestor = new(g.classes.Class_Screen)
  SCREENSTAGE_LOAD = 1
  SCREENSTAGE_WAIT = 2
  return me
end

on destroy me
  if me.loaded then
    me.unload()
  end if
  ancestor.destroy()
  return VOID
end

on load me
  me.loaded = 1
  if the runMode contains "Projector" then
    screenStage = SCREENSTAGE_WAIT
  else
    screenStage = SCREENSTAGE_LOAD
  end if
  initStage = 1
  me.updateProgressBar(0.0)
end

on unload me
  me.loaded = 0
  if not voidp(preloader) then
    preloader = preloader.destroy()
  end if
end

on updateProgressBar me, ratio
  BAR_COUNT = 16
  bars = integer(ratio * BAR_COUNT)
  repeat with i = 1 to BAR_COUNT
    sprite(10 + i).visible = bars >= i
  end repeat
end

on setStage me, i
  case i of
    SCREENSTAGE_LOAD:
      g.goFrame = label("SCREEN_TITLE")
    SCREENSTAGE_WAIT:
      g.goFrame = label("SCREEN_TITLE_WAIT")
  end case
  screenStage = i
  initStage = 1
end

on advanceStage me
  me.setStage(screenStage + 1)
end

on update me
  case screenStage of
    SCREENSTAGE_LOAD:
      if initStage then
        initStage = 0
        delayFrames = 10
        preloader = new(g.classes.Class_NetPreloader, the moviePath & the movieName)
      end if
      preloader.update()
      ratio = preloader.getRatioLoaded()
      me.updateProgressBar(ratio)
      if preloader.isDone() then
        if the frame = (marker(1) - 1) then
          delayFrames = delayFrames - 1
          if delayFrames = 0 then
            preloader = preloader.destroy()
            me.advanceStage()
          end if
        end if
      end if
    SCREENSTAGE_WAIT:
      if initStage then
        initStage = 0
        if the runMode contains "Plugin" then
          sharedCastURL = the moviePath & "char_shared.cct"
        else
          sharedCastURL = the moviePath & "char_shared.cst"
        end if
        new(g.classes.Class_NetPreloader, sharedCastURL)
      end if
  end case
end
