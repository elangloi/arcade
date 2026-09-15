property SCREENSTAGE_INTRO, SCREENSTAGE_LOADING, SCREENSTAGE_OUTRO, ancestor, screenStage, initStage, delayFrames, villainPreloader, titanPreloader, sharedPreloader, titanCastURL, villainCastURL, sharedCastURL, titanReady, villainReady, sharedReady, titanNameScratchMember, villainNameScratchMember, titanNameSourceImage, villainNameSourceImage
global g

on new me
  ancestor = new(g.classes.Class_Screen)
  SCREENSTAGE_INTRO = 1
  SCREENSTAGE_LOADING = 2
  SCREENSTAGE_OUTRO = 3
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
  screenStage = SCREENSTAGE_INTRO
  initStage = 1
  if g.villainID <> g.FIGHTER_ID_JINX then
    sprite(8).visible = 0
  end if
  if g.villainID <> g.FIGHTER_ID_GIZMO then
    sprite(11).visible = 0
  end if
  if g.villainID <> g.FIGHTER_ID_MAMMOTH then
    sprite(14).visible = 0
  end if
  if g.villainID <> g.FIGHTER_ID_CINDERBLOCK then
    sprite(17).visible = 0
  end if
  if g.villainID <> g.FIGHTER_ID_PLASMUS then
    sprite(20).visible = 0
  end if
  if g.titanID <> g.FIGHTER_ID_ROBIN then
    sprite(23).visible = 0
  end if
  if g.titanID <> g.FIGHTER_ID_RAVEN then
    sprite(26).visible = 0
  end if
  if g.titanID <> g.FIGHTER_ID_CYBORG then
    sprite(29).visible = 0
  end if
  if g.titanID <> g.FIGHTER_ID_STARFIRE then
    sprite(32).visible = 0
  end if
  if g.titanID <> g.FIGHTER_ID_BEASTBOY then
    sprite(35).visible = 0
  end if
  id = g.main.audioMgr.getEventID(g.assets.AUDIO.MUSIC_WHOLE_SONG)
  if id then
    g.main.audioMgr.fadeOutSound(id, 0, 0.75)
  end if
  if the runMode = "plugin" then
    titanCastURL = the moviePath & g.CASTLIB_NAMES[g.titanID] & ".cct"
    villainCastURL = the moviePath & g.CASTLIB_NAMES[g.villainID] & ".cct"
    sharedCastURL = the moviePath & "char_shared.cct"
  else
    titanCastURL = the moviePath & g.CASTLIB_NAMES[g.titanID] & ".cst"
    villainCastURL = the moviePath & g.CASTLIB_NAMES[g.villainID] & ".cst"
    sharedCastURL = the moviePath & "char_shared.cst"
  end if
  if g.linkedFighterCasts[g.titanID] then
    titanReady = 1
    sprite(46).visible = 0
  else
    titanReady = 0
    titanPreloader = new(g.classes.Class_NetPreloader, titanCastURL)
  end if
  if g.linkedFighterCasts[g.villainID] then
    villainReady = 1
    sprite(47).visible = 0
  else
    villainReady = 0
    villainPreloader = new(g.classes.Class_NetPreloader, villainCastURL)
  end if
  if g.linkedSharedCast then
    sharedReady = 1
  else
    sharedReady = 0
    sharedPreloader = new(g.classes.Class_NetPreloader, sharedCastURL)
  end if
  colorMems = []
  colorMems[g.FIGHTER_ID_ROBIN] = member("robin_vs.name")
  colorMems[g.FIGHTER_ID_RAVEN] = member("raven_vs.name")
  colorMems[g.FIGHTER_ID_CYBORG] = member("cyborg_vs.name")
  colorMems[g.FIGHTER_ID_STARFIRE] = member("starfire_vs.name")
  colorMems[g.FIGHTER_ID_BEASTBOY] = member("beastboy_vs.name")
  colorMems[g.FIGHTER_ID_JINX] = member("jinx_vs.name")
  colorMems[g.FIGHTER_ID_GIZMO] = member("gizmo_vs.name")
  colorMems[g.FIGHTER_ID_MAMMOTH] = member("mammoth_vs.name")
  colorMems[g.FIGHTER_ID_CINDERBLOCK] = member("cinderblock_vs.name")
  colorMems[g.FIGHTER_ID_PLASMUS] = member("plasmus_vs.name")
  greyMems = []
  greyMems[g.FIGHTER_ID_ROBIN] = member("robin_vs.name_gray")
  greyMems[g.FIGHTER_ID_RAVEN] = member("raven_vs.name_gray")
  greyMems[g.FIGHTER_ID_CYBORG] = member("cyborg_vs.name_gray")
  greyMems[g.FIGHTER_ID_STARFIRE] = member("starfire_vs.name_gray")
  greyMems[g.FIGHTER_ID_BEASTBOY] = member("beastboy_vs.name_gray")
  greyMems[g.FIGHTER_ID_JINX] = member("jinx_vs.name_gray")
  greyMems[g.FIGHTER_ID_GIZMO] = member("gizmo_vs.name_gray")
  greyMems[g.FIGHTER_ID_MAMMOTH] = member("mammoth_vs.name_gray")
  greyMems[g.FIGHTER_ID_CINDERBLOCK] = member("cinderblock_vs.name_gray")
  greyMems[g.FIGHTER_ID_PLASMUS] = member("plasmus_vs.name_gray")
  useCast = castLib("scratch")
  titanScratchMemName = "_scratch_titan_name"
  titanNameScratchMember = member(titanScratchMemName, useCast)
  if titanNameScratchMember.number < 1 then
    titanNameScratchMember = new(#bitmap, useCast)
    titanNameScratchMember.name = "_scratch_titan_name"
  end if
  titanNameScratchMember.image = greyMems[g.titanID].image.duplicate()
  titanNameScratchMember.regPoint = greyMems[g.titanID].regPoint
  titanNameSourceImage = colorMems[g.titanID].image
  sprite(44).member = titanNameScratchMember
  villainScratchMemName = "_scratch_villain_name"
  villainNameScratchMember = member(villainScratchMemName, useCast)
  if villainNameScratchMember.number < 1 then
    villainNameScratchMember = new(#bitmap, useCast)
    villainNameScratchMember.name = "_scratch_villain_name"
  end if
  villainNameScratchMember.image = greyMems[g.villainID].image.duplicate()
  villainNameScratchMember.regPoint = greyMems[g.villainID].regPoint
  villainNameSourceImage = colorMems[g.villainID].image
  sprite(45).member = villainNameScratchMember
  if titanReady then
    me.updateTitanBar(1.0)
  end if
  if villainReady then
    me.updateVillainBar(1.0)
  end if
end

on unload me
  me.loaded = 0
  if not voidp(titanPreloader) then
    titanPreloader.destroy()
  end if
  if not voidp(villainPreloader) then
    villainPreloader.destroy()
  end if
  sprite(8).visible = 1
  sprite(11).visible = 1
  sprite(14).visible = 1
  sprite(17).visible = 1
  sprite(20).visible = 1
  sprite(23).visible = 1
  sprite(26).visible = 1
  sprite(29).visible = 1
  sprite(32).visible = 1
  sprite(35).visible = 1
  sprite(46).visible = 1
  sprite(47).visible = 1
  if not voidp(titanNameScratchMember) then
    titanNameScratchMember.erase()
  end if
  if not voidp(villainNameScratchMember) then
    villainNameScratchMember.erase()
  end if
end

on updateTitanBar me, ratio
  destImg = titanNameScratchMember.image
  fillWidth = integer(destImg.width * ratio)
  copyRect = rect(0, 0, fillWidth, titanNameSourceImage.height)
  destImg.copyPixels(titanNameSourceImage, copyRect, copyRect)
end

on updateVillainBar me, ratio
  destImg = villainNameScratchMember.image
  fillWidth = integer(destImg.width * ratio)
  copyRect = rect(villainNameSourceImage.width - fillWidth, 0, villainNameSourceImage.width, villainNameSourceImage.height)
  destImg.copyPixels(villainNameSourceImage, copyRect, copyRect)
end

on linkCasts me
  castLib(g.CASTLIB_NUMS[g.titanID]).fileName = titanCastURL
  castLib(g.CASTLIB_NUMS[g.villainID]).fileName = villainCastURL
  castLib("char_shared").fileName = sharedCastURL
  g.assets.FIGHTERS[g.titanID].locateMembers()
  g.assets.FIGHTERS[g.villainID].locateMembers()
  g.assets.CHAR_SHARED.locateMembers()
  g.linkedFighterCasts[g.titanID] = 1
  g.linkedFighterCasts[g.villainID] = 1
  g.linkedSharedCast = 1
end

on setStage me, i
  case i of
    SCREENSTAGE_INTRO:
      g.goFrame = label("SCREEN_VERSUS")
    SCREENSTAGE_LOADING:
      g.goFrame = label("SCREEN_VERSUS_LOADING")
    SCREENSTAGE_OUTRO:
      g.goFrame = label("SCREEN_VERSUS_OUTRO")
  end case
  screenStage = i
  initStage = 1
end

on advanceStage me
  me.setStage(screenStage + 1)
end

on update me
  case screenStage of
    SCREENSTAGE_INTRO:
      if initStage then
        initStage = 0
      end if
      if the frame = (marker(1) - 1) then
        me.advanceStage()
      end if
    SCREENSTAGE_LOADING:
      if initStage then
        initStage = 0
        delayFrames = 100
      end if
      if the frame = (marker(1) - 1) then
        delayFrames = delayFrames - 1
        if not titanReady then
          if titanPreloader.update() then
            me.updateTitanBar(1.0)
            titanPreloader = titanPreloader.destroy()
            titanReady = 1
            sprite(46).visible = 0
          else
            titanRatio = titanPreloader.getRatioLoaded()
            me.updateTitanBar(titanRatio)
          end if
        end if
        if not villainReady then
          if villainPreloader.update() then
            me.updateVillainBar(1.0)
            villainPreloader = villainPreloader.destroy()
            villainReady = 1
            sprite(47).visible = 0
          else
            villainRatio = villainPreloader.getRatioLoaded()
            me.updateVillainBar(villainRatio)
          end if
        end if
        if not sharedReady then
          if sharedPreloader.update() then
            sharedPreloader = sharedPreloader.destroy()
            sharedReady = 1
          end if
        end if
        if titanReady and villainReady and sharedReady then
          if delayFrames <= 0 then
            me.advanceStage()
          end if
        end if
      end if
    SCREENSTAGE_OUTRO:
      if initStage then
        initStage = 0
        delayFrames = 30
        id = g.main.audioMgr.getEventID(g.assets.AUDIO.MUSIC_LOOP2)
        if id then
          g.main.audioMgr.fadeOutSound(id, 0, 0.75)
        end if
      end if
      if the frame = (marker(1) - 1) then
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          me.linkCasts()
          g.goFrame = label("SCREEN_GAME")
        end if
      end if
  end case
end
