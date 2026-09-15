on dumpClassDefinitions
  classNames = []
  longestName = 0
  repeat with i = 1 to the number of castMembers of castLib "Lingo"
    m = member(i, 1)
    if m.type = #script then
      if m.scriptType = #parent then
        if m.name starts "Class_" then
          if m.name.length > longestName then
            longestName = m.name.length
          end if
          classNames.append(m.name)
        end if
      end if
    end if
  end repeat
  classNames.sort()
  out1 = EMPTY
  repeat with i = 1 to classNames.count
    if out1 <> EMPTY then
      put RETURN after classNames
    end if
    put "property" && classNames[i] after classNames
  end repeat
  prefix = "-- BEGIN Class definitions"
  suffix = "-- END Class definitions"
  out2 = prefix
  repeat with i = 1 to classNames.count
    put RETURN & classNames[i] after classNames
    put " = " after char (longestName + 1) of line (i + 1) of classNames
    put "script(" && QUOTE & classNames[i] & QUOTE && ")" after classNames
  end repeat
  put RETURN & suffix after classNames
  put out1 & RETURN & RETURN & out2
end

on buildAssetClasses
  CASTLIB_NAME_ROBIN = "char_Robin"
  CASTLIB_NAME_RAVEN = "char_Raven"
  CASTLIB_NAME_CYBORG = "char_Cyborg"
  CASTLIB_NAME_STARFIRE = "char_Starfire"
  CASTLIB_NAME_BEASTBOY = "char_Beastboy"
  CASTLIB_NAME_JINX = "char_Jinx"
  CASTLIB_NAME_MAMMOTH = "char_Mammoth"
  CASTLIB_NAME_GIZMO = "char_Gizmo"
  CASTLIB_NAME_CINDERBLOCK = "char_Cinderblock"
  CASTLIB_NAME_PLASMUS = "char_Plasmus"
  CASTLIB_NAME_HUD = "hud"
  CASTLIB_NAME_GAME_MSGS = "game_messages"
  CASTLIB_NAME_AUDIO = "audio"
  CASTLIB_NAME_CHAR_SHARED = "char_shared"
  castList = [CASTLIB_NAME_ROBIN, CASTLIB_NAME_RAVEN, CASTLIB_NAME_CYBORG, CASTLIB_NAME_STARFIRE, CASTLIB_NAME_BEASTBOY, CASTLIB_NAME_JINX, CASTLIB_NAME_MAMMOTH, CASTLIB_NAME_GIZMO, CASTLIB_NAME_CINDERBLOCK, CASTLIB_NAME_PLASMUS, CASTLIB_NAME_HUD, CASTLIB_NAME_GAME_MSGS, CASTLIB_NAME_AUDIO, CASTLIB_NAME_CHAR_SHARED]
  scriptNames = ["Class_AssetsRobin", "Class_AssetsRaven", "Class_AssetsCyborg", "Class_AssetsStarfire", "Class_AssetsBeastboy", "Class_AssetsJinx", "Class_AssetsMammoth", "Class_AssetsGizmo", "Class_AssetsCinderblock", "Class_AssetsPlasmus", "Class_AssetsHUD", "Class_AssetsGameMessages", "Class_AssetsAudio", "Class_AssetsCharShared"]
  u = script("Class_Utility").new()
  repeat with c = 1 to castList.count
    memNames = []
    longestName = 0
    repeat with i = 1 to the number of castMembers of castLib castList[c]
      m = member(i, castList[c])
      if (m.type = #bitmap) or (m.type = #filmLoop) or (m.type = #sound) then
        if u.isLetter(m.name.char[1]) then
          if m.name.length > longestName then
            longestName = m.name.length
          end if
          memNames.append(m.name)
        end if
      end if
    end repeat
    memNames.sort()
    out = EMPTY
    repeat with i = 1 to memNames.count
      put "property" && u.toUpper(memNames[i]) & RETURN after CASTLIB_NAME_CYBORG
    end repeat
    put RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put "on new ( me )" & RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put "  me.locateMembers()" after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put "  return me" & RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put "end new" & RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put "on locateMembers ( me )" & RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put "  util = new( script(" & QUOTE & "Class_Utility" & QUOTE & ") )" & RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put "  ASSET_CAST = " & QUOTE & castList[c] & QUOTE & RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    repeat with i = 1 to memNames.count
      n = u.toUpper(memNames[i])
      jj = longestName - n.length
      repeat with j = 0 to jj
        put " " after CASTLIB_NAME_CYBORG
      end repeat
      put "  " & n & "= util.findMember(" & QUOTE & memNames[i] & QUOTE & ",ASSET_CAST)" & RETURN after CASTLIB_NAME_CYBORG
    end repeat
    put RETURN after CASTLIB_NAME_CYBORG
    put "end locateMembers" & RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put "on precache ( me )" & RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    repeat with i = 1 to memNames.count
      n = u.toUpper(memNames[i])
      put "  preloadMember( " & n & " )" & RETURN after CASTLIB_NAME_CYBORG
    end repeat
    put RETURN after CASTLIB_NAME_CYBORG
    put "end precache" & RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    put RETURN after CASTLIB_NAME_CYBORG
    outMem = member(scriptNames[c], "Lingo")
    if not (outMem.number > 0) then
      outMem = new(#script, castLib("Lingo"))
      outMem.name = scriptNames[c]
      outMem.scriptType = #parent
    end if
    outMem.scriptText = out
  end repeat
end

on buildClassDefinitions
  u = script("Class_Utility").new()
  memNames = []
  longestName = 0
  repeat with i = 1 to the number of castMembers of castLib 1
    m = member(i, 1)
    if m.type = #script then
      if m.name.char[1..6] = "Class_" then
        if m.name.length > longestName then
          longestName = m.name.length
        end if
        memNames.append(m.name)
      end if
    end if
  end repeat
  memNames.sort()
  out = EMPTY
  repeat with i = 1 to memNames.count
    put "property" && memNames[i] & RETURN after u
  end repeat
  put RETURN after u
  put RETURN after u
  put "on new ( me )" & RETURN after u
  put RETURN after u
  repeat with i = 1 to memNames.count
    n = memNames[i]
    jj = longestName - n.length
    repeat with j = 0 to jj
      put " " after u
    end repeat
    put "  " & n & "= script(" & QUOTE & memNames[i] & QUOTE & ")" & RETURN after u
  end repeat
  put RETURN after u
  put "  return me" & RETURN after u
  put RETURN after u
  put "end new" & RETURN after u
  outMem = member("_ClassDefinitions", "Lingo")
  if not (outMem.number > 0) then
    outMem = new(#script, castLib("Lingo"))
    outMem.name = "_ClassDefinitions"
    outMem.scriptType = #parent
  end if
  outMem.scriptText = out
end

on unlinkCasts
  if the runMode = "plugin" then
    suffix = ".cct"
  else
    suffix = ".cst"
  end if
  castLib("char_Robin").fileName = "empty_Robin" & suffix
  castLib("char_Raven").fileName = "empty_Raven" & suffix
  castLib("char_Cyborg").fileName = "empty_Cyborg" & suffix
  castLib("char_Starfire").fileName = "empty_Starfire" & suffix
  castLib("char_Beastboy").fileName = "empty_Beastboy" & suffix
  castLib("char_Jinx").fileName = "empty_Jinx" & suffix
  castLib("char_Gizmo").fileName = "empty_Gizmo" & suffix
  castLib("char_Mammoth").fileName = "empty_Mammoth" & suffix
  castLib("char_Cinderblock").fileName = "empty_Cinderblock" & suffix
  castLib("char_Plasmus").fileName = "empty_Plasmus" & suffix
  castLib("char_shared").fileName = "empty_shared" & suffix
end

on linkCasts
  if the runMode = #PLUGIN then
    suffix = ".cct"
  else
    suffix = ".cst"
  end if
  castLib("char_Robin").fileName = "char_Robin" & suffix
  castLib("char_Raven").fileName = "char_Raven" & suffix
  castLib("char_Cyborg").fileName = "char_Cyborg" & suffix
  castLib("char_Starfire").fileName = "char_Starfire" & suffix
  castLib("char_Beastboy").fileName = "char_Beastboy" & suffix
  castLib("char_Jinx").fileName = "char_Jinx" & suffix
  castLib("char_Gizmo").fileName = "char_Gizmo" & suffix
  castLib("char_Mammoth").fileName = "char_Mammoth" & suffix
  castLib("char_Cinderblock").fileName = "char_Cinderblock" & suffix
  castLib("char_Plasmus").fileName = "char_Plasmus" & suffix
  castLib("char_shared").fileName = "char_shared" & suffix
end

on list32bitmembers
  repeat with c = 1 to the number of castLibs
    repeat with i = 1 to the number of castMembers of castLib c
      m = member(i, c)
      if m.type = #bitmap then
        if m.depth = 32 then
          put member(i, c).name & TAB & castLib(c).name
        end if
      end if
    end repeat
  end repeat
end
