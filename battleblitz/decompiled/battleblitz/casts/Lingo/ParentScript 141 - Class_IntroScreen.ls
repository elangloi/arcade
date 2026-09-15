property SCREENSTAGE_STEP_1, SCREENSTAGE_STEP_2, SCREENSTAGE_STEP_3, ancestor, screenStage, initStage, delayFrames
global g

on new me
  ancestor = new(g.classes.Class_Screen)
  SCREENSTAGE_STEP_1 = 1
  SCREENSTAGE_STEP_2 = 2
  SCREENSTAGE_STEP_3 = 3
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
  screenStage = SCREENSTAGE_STEP_1
  initStage = 1
end

on unload me
  me.loaded = 0
end

on setStage me, i
  case i of
    SCREENSTAGE_STEP_1:
      g.goFrame = label("SCREEN_INTRO")
    SCREENSTAGE_STEP_2:
      g.goFrame = label("SCREEN_INTRO_STEP_2")
    SCREENSTAGE_STEP_3:
      g.goFrame = label("SCREEN_INTRO_STEP_3")
  end case
  screenStage = i
  initStage = 1
end

on advanceStage me
  me.setStage(screenStage + 1)
end

on update me
  case screenStage of
    SCREENSTAGE_STEP_1:
      if initStage then
        initStage = 0
        g.main.audioMgr.playSound(g.assets.AUDIO.MUSIC_WHOLE_SONG, 70, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
      end if
    SCREENSTAGE_STEP_2:
      if initStage then
        initStage = 0
      end if
    SCREENSTAGE_STEP_3:
      if initStage then
        initStage = 0
      end if
      if the frame = (marker(1) - 1) then
        g.main.audioMgr.playSound(g.assets.AUDIO.SFX_CHARACTERSWITCH3, 100, g.SFX_EVENT_PRIORITY_LOW)
        g.main.audioMgr.playSound(g.assets.AUDIO.SFX_WALL_SLAM, 100, g.SFX_EVENT_PRIORITY_LOW)
        g.goFrame = label("SCREEN_SELECTFIGHTER")
      end if
  end case
end
