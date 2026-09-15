property SCREENSTAGE_INTRO, SCREENSTAGE_SELECT_ROBIN, SCREENSTAGE_SELECT_RAVEN, SCREENSTAGE_SELECT_CYBORG, SCREENSTAGE_SELECT_STARFIRE, SCREENSTAGE_SELECT_BEASTBOY, SCREENSTAGE_SELECT_JINX, SCREENSTAGE_SELECT_GIZMO, SCREENSTAGE_SELECT_MAMMOTH, SCREENSTAGE_SELECT_CINDERBLOCK, SCREENSTAGE_SELECT_PLASMUS, TAG_MEMBER_PLAYER, TAG_MEMBER_OPPONENT, TAG_MEMBER_LOCKED, TAG_MEMBER_DEFEATED, TAG_MEMBER_FUTURE_DATES, FIGHTER_HILIGHT_MEMBERS, ancestor, fighterNames, scoreNumberMembers, screenStage, initStage, musicEventID, cheat_unlockAllFighters, cheat_availAllFighters, cheat_defeatAllFighters
global g

on new me
  ancestor = new(g.classes.Class_Screen)
  SCREENSTAGE_INTRO = 1
  SCREENSTAGE_SELECT_ROBIN = 2
  SCREENSTAGE_SELECT_RAVEN = 3
  SCREENSTAGE_SELECT_CYBORG = 4
  SCREENSTAGE_SELECT_STARFIRE = 5
  SCREENSTAGE_SELECT_BEASTBOY = 6
  SCREENSTAGE_SELECT_JINX = 7
  SCREENSTAGE_SELECT_GIZMO = 8
  SCREENSTAGE_SELECT_MAMMOTH = 9
  SCREENSTAGE_SELECT_CINDERBLOCK = 10
  SCREENSTAGE_SELECT_PLASMUS = 11
  TAG_MEMBER_PLAYER = member("select_player")
  TAG_MEMBER_OPPONENT = member("select_opponent")
  TAG_MEMBER_LOCKED = member("select_locked")
  TAG_MEMBER_DEFEATED = member("select_defeated")
  TAG_MEMBER_FUTURE_DATES = []
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_ROBIN] = member(0)
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_RAVEN] = member(0)
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_CYBORG] = member(0)
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_STARFIRE] = member(0)
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_BEASTBOY] = member(0)
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_JINX] = member(0)
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_GIZMO] = member(0)
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_MAMMOTH] = member(0)
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_CINDERBLOCK] = member(0)
  TAG_MEMBER_FUTURE_DATES[g.FIGHTER_ID_PLASMUS] = member(0)
  fighterNames = []
  fighterNames[g.FIGHTER_ID_ROBIN] = "robin"
  fighterNames[g.FIGHTER_ID_RAVEN] = "raven"
  fighterNames[g.FIGHTER_ID_CYBORG] = "cyborg"
  fighterNames[g.FIGHTER_ID_STARFIRE] = "starfire"
  fighterNames[g.FIGHTER_ID_BEASTBOY] = "beast"
  fighterNames[g.FIGHTER_ID_JINX] = "jinx"
  fighterNames[g.FIGHTER_ID_MAMMOTH] = "mammoth"
  fighterNames[g.FIGHTER_ID_GIZMO] = "gizmo"
  fighterNames[g.FIGHTER_ID_CINDERBLOCK] = "cinder"
  fighterNames[g.FIGHTER_ID_PLASMUS] = "plasmus"
  scoreNumberMembers = [g.util.findMember("playerscore_0w"), g.util.findMember("playerscore_1w"), g.util.findMember("playerscore_2w"), g.util.findMember("playerscore_3w"), g.util.findMember("playerscore_4w"), g.util.findMember("playerscore_5w"), g.util.findMember("playerscore_6w"), g.util.findMember("playerscore_7w"), g.util.findMember("playerscore_8w"), g.util.findMember("playerscore_9w")]
  cheat_unlockAllFighters = new(g.classes.Class_KeyCombo, [g.KEYCODE_O, g.KEYCODE_P, g.KEYCODE_E, g.KEYCODE_N, g.KEYCODE_A, g.KEYCODE_L, g.KEYCODE_L])
  cheat_availAllFighters = new(g.classes.Class_KeyCombo, [g.KEYCODE_E, g.KEYCODE_A, g.KEYCODE_T, g.KEYCODE_I, g.KEYCODE_T])
  cheat_defeatAllFighters = new(g.classes.Class_KeyCombo, [g.KEYCODE_S, g.KEYCODE_P, g.KEYCODE_E, g.KEYCODE_E, g.KEYCODE_D, g.KEYCODE_Y, g.KEYCODE_W, g.KEYCODE_I, g.KEYCODE_N])
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
  g.main.keyMgr.addListener(me)
  if g.main.prevScreenID = g.SCREEN_CONTROLS then
  else
    screenStage = SCREENSTAGE_INTRO
  end if
  if g.main.audioMgr.isPlaying(g.assets.AUDIO.MUSIC_WHOLE_SONG) then
    musicEventID = g.main.audioMgr.getEventID(g.assets.AUDIO.MUSIC_WHOLE_SONG)
  else
    musicEventID = g.main.audioMgr.playSound(g.assets.AUDIO.MUSIC_WHOLE_SONG, 70, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
  end if
  me.updatePlayerScore()
  initStage = 1
end

on unload me
  me.loaded = 0
  g.main.keyMgr.removeListener(me)
  sprite(35).visible = 1
  sprite(36).visible = 1
  sprite(37).visible = 1
  sprite(38).visible = 1
  sprite(39).visible = 1
end

on updatePlayerPortrait me, spr, id
  if g.unlockedPlayers[id] and g.availablePlayers[id] then
    if g.playerID = id then
      spr.member = member("loop_selection_" & fighterNames[id] & "_click")
    else
      spr.member = member("selection_" & fighterNames[id] & ".active")
    end if
  else
  end if
end

on updateEnemyPortrait me, spr, id
  if g.defeatedEnemies[g.playerID][id] then
    if g.enemyID = id then
      spr.member = member("loop_selection_" & fighterNames[id] & "_defeated_click")
    else
      spr.member = member("selection_" & fighterNames[id] & ".defeat")
    end if
  else
    if g.unlockedEnemies[g.playerID][id] and g.availableEnemies[id] then
      if g.enemyID = id then
        spr.member = member("loop_selection_" & fighterNames[id] & "_click")
      else
        spr.member = member("selection_" & fighterNames[id] & ".active")
      end if
    else
      spr.member = member("selection_" & fighterNames[id] & ".inactive")
    end if
  end if
end

on updatePlayerTag me, spr, id
  if g.availablePlayers[id] then
    if g.unlockedPlayers[id] then
      if id = g.playerID then
        spr.member = TAG_MEMBER_PLAYER
      else
        spr.member = member(0)
      end if
    else
      spr.member = TAG_MEMBER_LOCKED
    end if
  else
    spr.member = TAG_MEMBER_FUTURE_DATES[id]
  end if
end

on updateEnemyTag me, spr, id
  if g.availableEnemies[id] then
    if g.unlockedEnemies[g.playerID][id] then
      if id = g.enemyID then
        spr.member = TAG_MEMBER_OPPONENT
      else
        if g.defeatedEnemies[g.playerID][id] then
          spr.member = TAG_MEMBER_DEFEATED
        else
          spr.member = member(0)
        end if
      end if
    else
      spr.member = TAG_MEMBER_LOCKED
    end if
  else
    spr.member = TAG_MEMBER_FUTURE_DATES[id]
  end if
end

on updatePlayerScore me
  totalScore = 0
  if g.playMode = g.PLAYMODE_AS_TITANS then
    ENEMY_ORDER = g.VILLAIN_FIGHTER_ORDER
  else
    ENEMY_ORDER = g.TITAN_FIGHTER_ORDER
  end if
  repeat with fighterID in ENEMY_ORDER
    totalScore = totalScore + g.playerScores[g.playerID][fighterID]
  end repeat
  digitRect = rect(0, 0, 11, 26)
  baseRect = digitRect.offset(160, 1)
  destImg = g.util.findMember("playerscore_dynamic").image
  repeat with i = 1 to 9
    digit = totalScore mod integer(power(10, i)) / integer(power(10, i - 1))
    srcImg = scoreNumberMembers[digit + 1].image
    destImg.copyPixels(srcImg, baseRect.offset(-(digitRect.width + 1) * (i - 1), 0), digitRect)
  end repeat
end

on updateSprites me
  if g.playMode = g.PLAYMODE_AS_TITANS then
    me.updatePlayerPortrait(sprite(23), g.FIGHTER_ID_ROBIN)
    me.updatePlayerPortrait(sprite(24), g.FIGHTER_ID_RAVEN)
    me.updatePlayerPortrait(sprite(25), g.FIGHTER_ID_CYBORG)
    me.updatePlayerPortrait(sprite(26), g.FIGHTER_ID_STARFIRE)
    me.updatePlayerPortrait(sprite(27), g.FIGHTER_ID_BEASTBOY)
    me.updateEnemyPortrait(sprite(28), g.FIGHTER_ID_JINX)
    me.updateEnemyPortrait(sprite(29), g.FIGHTER_ID_GIZMO)
    me.updateEnemyPortrait(sprite(30), g.FIGHTER_ID_MAMMOTH)
    me.updateEnemyPortrait(sprite(31), g.FIGHTER_ID_CINDERBLOCK)
    me.updateEnemyPortrait(sprite(32), g.FIGHTER_ID_PLASMUS)
    me.updatePlayerTag(sprite(61), g.FIGHTER_ID_ROBIN)
    me.updatePlayerTag(sprite(62), g.FIGHTER_ID_RAVEN)
    me.updatePlayerTag(sprite(63), g.FIGHTER_ID_CYBORG)
    me.updatePlayerTag(sprite(64), g.FIGHTER_ID_STARFIRE)
    me.updatePlayerTag(sprite(65), g.FIGHTER_ID_BEASTBOY)
    me.updateEnemyTag(sprite(66), g.FIGHTER_ID_JINX)
    me.updateEnemyTag(sprite(67), g.FIGHTER_ID_GIZMO)
    me.updateEnemyTag(sprite(68), g.FIGHTER_ID_MAMMOTH)
    me.updateEnemyTag(sprite(69), g.FIGHTER_ID_CINDERBLOCK)
    me.updateEnemyTag(sprite(70), g.FIGHTER_ID_PLASMUS)
    sprite(35).visible = g.enemyID = g.FIGHTER_ID_JINX
    sprite(36).visible = g.enemyID = g.FIGHTER_ID_GIZMO
    sprite(37).visible = g.enemyID = g.FIGHTER_ID_MAMMOTH
    sprite(38).visible = g.enemyID = g.FIGHTER_ID_CINDERBLOCK
    sprite(39).visible = g.enemyID = g.FIGHTER_ID_PLASMUS
  else
    me.updateEnemyPortrait(sprite(23), g.FIGHTER_ID_ROBIN)
    me.updateEnemyPortrait(sprite(24), g.FIGHTER_ID_RAVEN)
    me.updateEnemyPortrait(sprite(25), g.FIGHTER_ID_CYBORG)
    me.updateEnemyPortrait(sprite(26), g.FIGHTER_ID_STARFIRE)
    me.updateEnemyPortrait(sprite(27), g.FIGHTER_ID_BEASTBOY)
    me.updatePlayerPortrait(sprite(28), g.FIGHTER_ID_JINX)
    me.updatePlayerPortrait(sprite(29), g.FIGHTER_ID_GIZMO)
    me.updatePlayerPortrait(sprite(30), g.FIGHTER_ID_MAMMOTH)
    me.updatePlayerPortrait(sprite(31), g.FIGHTER_ID_CINDERBLOCK)
    me.updatePlayerPortrait(sprite(32), g.FIGHTER_ID_PLASMUS)
    me.updateEnemyTag(sprite(61), g.FIGHTER_ID_ROBIN)
    me.updateEnemyTag(sprite(62), g.FIGHTER_ID_RAVEN)
    me.updateEnemyTag(sprite(63), g.FIGHTER_ID_CYBORG)
    me.updateEnemyTag(sprite(64), g.FIGHTER_ID_STARFIRE)
    me.updateEnemyTag(sprite(65), g.FIGHTER_ID_BEASTBOY)
    me.updatePlayerTag(sprite(66), g.FIGHTER_ID_JINX)
    me.updatePlayerTag(sprite(67), g.FIGHTER_ID_GIZMO)
    me.updatePlayerTag(sprite(68), g.FIGHTER_ID_MAMMOTH)
    me.updatePlayerTag(sprite(69), g.FIGHTER_ID_CINDERBLOCK)
    me.updatePlayerTag(sprite(70), g.FIGHTER_ID_PLASMUS)
    sprite(35).visible = g.enemyID = g.FIGHTER_ID_ROBIN
    sprite(36).visible = g.enemyID = g.FIGHTER_ID_RAVEN
    sprite(37).visible = g.enemyID = g.FIGHTER_ID_CYBORG
    sprite(38).visible = g.enemyID = g.FIGHTER_ID_STARFIRE
    sprite(39).visible = g.enemyID = g.FIGHTER_ID_BEASTBOY
  end if
  sprite(19).member = member("name_and_moves_" & fighterNames[g.enemyID], "select_screen")
end

on setPlayMode me, mode
  if mode <> g.playMode then
    case mode of
      g.PLAYMODE_AS_TITANS:
        g.playMode = mode
        me.setPlayer(g.TITAN_FIGHTER_ORDER[1])
        me.jumpToCharacerStage()
        sprite(15).member = member("loop_player_opp_text_switch_to_titans", "select_screen")
      g.PLAYMODE_AS_VILLAINS:
        g.playMode = mode
        me.setPlayer(g.VILLAIN_FIGHTER_ORDER[1])
        me.jumpToCharacerStage()
        sprite(15).member = member("loop_player_opp_text_switch_to_villains", "select_screen")
    end case
  end if
end

on setPlayer me, id
  if g.availablePlayers[id] and g.unlockedPlayers[id] then
    sprite(10).member = member("bg_head_" & g.main.screen.fighterNames[g.enemyID], "select_screen")
    g.playerID = id
    if g.playMode = g.PLAYMODE_AS_TITANS then
      g.titanID = id
      ENEMY_ORDER = g.VILLAIN_FIGHTER_ORDER
    else
      g.villainID = id
      ENEMY_ORDER = g.TITAN_FIGHTER_ORDER
    end if
    repeat with i = ENEMY_ORDER.count down to 1
      if g.unlockedEnemies[g.playerID][ENEMY_ORDER[i]] then
        me.setOpponent(ENEMY_ORDER[i])
        exit repeat
      end if
    end repeat
    me.updatePlayerScore()
    me.jumpToCharacerStage()
  end if
end

on setOpponent me, id
  if g.availableEnemies[id] and g.unlockedEnemies[g.playerID][id] then
    g.enemyID = id
    if g.playMode = g.PLAYMODE_AS_TITANS then
      g.villainID = id
    else
      g.titanID = id
    end if
    mem = member("loop_logo_anim", "select_screen")
    if sprite(11).member = mem then
      tell sprite(11)
        go(1)
      end tell
    else
      sprite(11).member = member("loop_logo_anim", "select_screen")
    end if
    sprite(10).member = member("bg_head_" & g.main.screen.fighterNames[g.enemyID], "select_screen")
    sprite(12).member = member("loop_figure_" & fighterNames[g.enemyID], "select_screen")
    me.updateSprites()
  end if
end

on setStage me, i
  case i of
    SCREENSTAGE_INTRO:
      g.goFrame = label("SCREEN_SELECTFIGHTER")
    SCREENSTAGE_SELECT_ROBIN:
      g.goFrame = label("SCREEN_SELECTFIGHTER_ROBIN")
    SCREENSTAGE_SELECT_RAVEN:
      g.goFrame = label("SCREEN_SELECTFIGHTER_RAVEN")
    SCREENSTAGE_SELECT_CYBORG:
      g.goFrame = label("SCREEN_SELECTFIGHTER_CYBORG")
    SCREENSTAGE_SELECT_STARFIRE:
      g.goFrame = label("SCREEN_SELECTFIGHTER_STARFIRE")
    SCREENSTAGE_SELECT_BEASTBOY:
      g.goFrame = label("SCREEN_SELECTFIGHTER_BEASTBOY")
    SCREENSTAGE_SELECT_JINX:
      g.goFrame = label("SCREEN_SELECTFIGHTER_JINX")
    SCREENSTAGE_SELECT_GIZMO:
      g.goFrame = label("SCREEN_SELECTFIGHTER_GIZMO")
    SCREENSTAGE_SELECT_MAMMOTH:
      g.goFrame = label("SCREEN_SELECTFIGHTER_MAMMOTH")
    SCREENSTAGE_SELECT_CINDERBLOCK:
      g.goFrame = label("SCREEN_SELECTFIGHTER_CINDERBLOCK")
    SCREENSTAGE_SELECT_PLASMUS:
      g.goFrame = label("SCREEN_SELECTFIGHTER_PLASMUS")
  end case
  screenStage = i
  initStage = 1
end

on advanceStage me
  me.setStage(screenStage + 1)
end

on jumpToCharacerStage me
  case g.playerID of
    g.FIGHTER_ID_ROBIN:
      me.setStage(SCREENSTAGE_SELECT_ROBIN)
    g.FIGHTER_ID_RAVEN:
      me.setStage(SCREENSTAGE_SELECT_RAVEN)
    g.FIGHTER_ID_CYBORG:
      me.setStage(SCREENSTAGE_SELECT_CYBORG)
    g.FIGHTER_ID_STARFIRE:
      me.setStage(SCREENSTAGE_SELECT_STARFIRE)
    g.FIGHTER_ID_BEASTBOY:
      me.setStage(SCREENSTAGE_SELECT_BEASTBOY)
    g.FIGHTER_ID_JINX:
      me.setStage(SCREENSTAGE_SELECT_JINX)
    g.FIGHTER_ID_GIZMO:
      me.setStage(SCREENSTAGE_SELECT_GIZMO)
    g.FIGHTER_ID_MAMMOTH:
      me.setStage(SCREENSTAGE_SELECT_MAMMOTH)
    g.FIGHTER_ID_CINDERBLOCK:
      me.setStage(SCREENSTAGE_SELECT_CINDERBLOCK)
    g.FIGHTER_ID_PLASMUS:
      me.setStage(SCREENSTAGE_SELECT_PLASMUS)
  end case
end

on update me
  case screenStage of
    SCREENSTAGE_INTRO:
      if initStage then
        initStage = 0
      end if
      if the frame = (marker(1) - 1) then
        me.jumpToCharacerStage()
      end if
    SCREENSTAGE_SELECT_ROBIN, SCREENSTAGE_SELECT_RAVEN, SCREENSTAGE_SELECT_CYBORG, SCREENSTAGE_SELECT_STARFIRE, SCREENSTAGE_SELECT_BEASTBOY, SCREENSTAGE_SELECT_JINX, SCREENSTAGE_SELECT_GIZMO, SCREENSTAGE_SELECT_MAMMOTH, SCREENSTAGE_SELECT_CINDERBLOCK, SCREENSTAGE_SELECT_PLASMUS:
      if initStage then
        initStage = 0
        me.updateSprites()
        sprite(10).member = member("bg_head_" & g.main.screen.fighterNames[g.enemyID], "select_screen")
        sprite(12).member = member("loop_figure_" & fighterNames[g.enemyID], "select_screen")
      end if
  end case
end

on keyDown me, event
  playSound = 0
  if cheat_unlockAllFighters.checkKey(event.keyCode) then
    repeat with i = 1 to g.FIGHTER_COUNT
      g.unlockedPlayers[i] = 1
      g.unlockedEnemies[g.playerID][i] = 1
      me.updateSprites()
    end repeat
    playSound = 1
  end if
  if cheat_defeatAllFighters.checkKey(event.keyCode) then
    if g.playMode = g.PLAYMODE_AS_TITANS then
      ENEMY_ORDER = g.VILLAIN_FIGHTER_ORDER
    else
      ENEMY_ORDER = g.TITAN_FIGHTER_ORDER
    end if
    repeat with i = 1 to ENEMY_ORDER.count
      g.defeatedEnemies[g.playerID][ENEMY_ORDER[i]] = 1
      me.updateSprites()
    end repeat
    playSound = 1
  end if
  if playSound then
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNFIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
  end if
end

on keyUp me, event
end
