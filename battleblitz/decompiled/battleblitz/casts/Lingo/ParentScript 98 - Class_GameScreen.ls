property GAMESTAGE_INTRO, GAMESTAGE_PLAY, GAMESTAGE_KO, GAMESTAGE_TIMEUP, GAMESTAGE_WIN, GAMESTAGE_SCORE, ROUNDSTATE_FIGHT_IN_PROGRESS, ROUNDSTATE_TITAN_WINS_BY_DAMAGE, ROUNDSTATE_VILLAIN_WINS_BY_DAMAGE, ROUNDSTATE_TITAN_WINS_BY_TIME, ROUNDSTATE_VILLAIN_WINS_BY_TIME, SCORECHAIN_MAX_HIT_INTERVAL, ancestor, spriteMgr, titan, villain, player, enemy, playerAdapter, enemyAdapter, collisionGroup, projectileGroup, effectGroup, scene, hud, clock, controlsPopup, gameStage, initStage, roundState, roundNum, playerWins, enemyWins, matchScore, delayFrames, cheat_toggleFPS, cheat_toggleAI, cheat_reduceTitanHealth, cheat_reduceVillainHealth, cheat_invulnerability, paused, playerCanSummon, prevHitTimestamp, hitChainMultiplier, musicEventID
global g, main

on new me
  ancestor = new(g.classes.Class_Screen)
  g.game = me
  GAMESTAGE_INTRO = 1
  GAMESTAGE_PLAY = 2
  GAMESTAGE_KO = 3
  GAMESTAGE_TIMEUP = 4
  GAMESTAGE_WIN = 5
  GAMESTAGE_SCORE = 6
  ROUNDSTATE_FIGHT_IN_PROGRESS = 0
  ROUNDSTATE_TITAN_WINS_BY_DAMAGE = 1
  ROUNDSTATE_VILLAIN_WINS_BY_DAMAGE = 2
  ROUNDSTATE_TITAN_WINS_BY_TIME = 3
  ROUNDSTATE_VILLAIN_WINS_BY_TIME = 4
  SCORECHAIN_MAX_HIT_INTERVAL = 1000
  cheat_toggleFPS = new(g.classes.Class_KeyCombo, [g.KEYCODE_S, g.KEYCODE_H, g.KEYCODE_O, g.KEYCODE_W, g.KEYCODE_F, g.KEYCODE_P, g.KEYCODE_S])
  cheat_toggleAI = new(g.classes.Class_KeyCombo, [g.KEYCODE_S, g.KEYCODE_T, g.KEYCODE_A, g.KEYCODE_N, g.KEYCODE_D, g.KEYCODE_S, g.KEYCODE_T, g.KEYCODE_I, g.KEYCODE_L, g.KEYCODE_L])
  cheat_reduceVillainHealth = new(g.classes.Class_KeyCombo, [g.KEYCODE_G, g.KEYCODE_O, g.KEYCODE_T, g.KEYCODE_I, g.KEYCODE_T, g.KEYCODE_A, g.KEYCODE_N, g.KEYCODE_S])
  cheat_reduceTitanHealth = new(g.classes.Class_KeyCombo, [g.KEYCODE_G, g.KEYCODE_O, g.KEYCODE_V, g.KEYCODE_I, g.KEYCODE_L, g.KEYCODE_L, g.KEYCODE_A, g.KEYCODE_I, g.KEYCODE_N, g.KEYCODE_S])
  cheat_invulnerability = new(g.classes.Class_KeyCombo, [g.KEYCODE_T, g.KEYCODE_H, g.KEYCODE_E, g.KEYCODE_R, g.KEYCODE_E, g.KEYCODE_C, g.KEYCODE_A, g.KEYCODE_N, g.KEYCODE_B, g.KEYCODE_E, g.KEYCODE_O, g.KEYCODE_N, g.KEYCODE_L, g.KEYCODE_Y, g.KEYCODE_O, g.KEYCODE_N, g.KEYCODE_E])
  return me
end

on destroy me
  if me.loaded then
    me.unload()
  end if
  ancestor.destroy()
  g.game = VOID
  return VOID
end

on load me
  me.loaded = 1
  g.assets.CHAR_SHARED.precache()
  g.assets.GAME_MESSAGES.precache()
  spriteMgr = new(g.classes.Class_SpriteManager, g.SPRITE_POOL_CHANNEL_MIN, g.SPRITE_POOL_CHANNEL_MAX)
  collisionGroup = new(g.classes.Class_ObjectGroup)
  projectileGroup = new(g.classes.Class_ObjectGroup)
  effectGroup = new(g.classes.Class_ObjectGroup)
  playerInitHealth = g.PLAYER_HEALTH_DEFAULT
  if g.playMode = g.PLAYMODE_AS_TITANS then
    enemyInitHealth = g.VILLAIN_HEALTH_DEFAULTS[g.difficulty][g.villainID]
  else
    enemyInitHealth = g.TITAN_HEALTH_DEFAULTS[g.difficulty][g.titanID]
  end if
  playerCanSummon = g.util.newArray(g.FIGHTER_COUNT, 0)
  if g.playMode = g.PLAYMODE_AS_TITANS then
    repeat with i = 1 to g.TITAN_FIGHTER_ORDER.count
      playerCanSummon[g.TITAN_FIGHTER_ORDER[i]] = g.TITAN_FIGHTER_ORDER[i] <> g.titanID
    end repeat
  end if
  case g.playerID of
    g.FIGHTER_ID_ROBIN:
      g.assets.ROBIN.precache()
      player = new(g.classes.Class_Robin, playerInitHealth)
      playerAdapter = new(g.classes.Class_RobinKeyAdapter, player)
    g.FIGHTER_ID_RAVEN:
      g.assets.RAVEN.precache()
      player = new(g.classes.Class_Raven, playerInitHealth)
      playerAdapter = new(g.classes.Class_RavenKeyAdapter, player)
    g.FIGHTER_ID_CYBORG:
      g.assets.CYBORG.precache()
      player = new(g.classes.Class_Cyborg, playerInitHealth)
      playerAdapter = new(g.classes.Class_CyborgKeyAdapter, player)
    g.FIGHTER_ID_STARFIRE:
      g.assets.STARFIRE.precache()
      player = new(g.classes.Class_Starfire, playerInitHealth)
      playerAdapter = new(g.classes.Class_StarfireKeyAdapter, player)
    g.FIGHTER_ID_BEASTBOY:
      g.assets.BEASTBOY.precache()
      player = new(g.classes.Class_Beastboy, playerInitHealth)
      playerAdapter = new(g.classes.Class_BeastboyKeyAdapter, player)
    g.FIGHTER_ID_JINX:
      g.assets.JINX.precache()
      player = new(g.classes.Class_Jinx, playerInitHealth)
      playerAdapter = new(g.classes.Class_JinxKeyAdapter, player)
    g.FIGHTER_ID_MAMMOTH:
      g.assets.MAMMOTH.precache()
      player = new(g.classes.Class_Mammoth, playerInitHealth)
      playerAdapter = new(g.classes.Class_MammothKeyAdapter, player)
    g.FIGHTER_ID_GIZMO:
      g.assets.GIZMO.precache()
      player = new(g.classes.Class_Gizmo, playerInitHealth)
      playerAdapter = new(g.classes.Class_GizmoKeyAdapter, player)
    g.FIGHTER_ID_CINDERBLOCK:
      g.assets.CINDERBLOCK.precache()
      player = new(g.classes.Class_Cinderblock, playerInitHealth)
      playerAdapter = new(g.classes.Class_CinderblockKeyAdapter, player)
    g.FIGHTER_ID_PLASMUS:
      g.assets.PLASMUS.precache()
      player = new(g.classes.Class_Plasmus, playerInitHealth)
      playerAdapter = new(g.classes.Class_PlasmusKeyAdapter, player)
  end case
  g.main.keyMgr.addListener(playerAdapter)
  case g.enemyID of
    g.FIGHTER_ID_ROBIN:
      g.assets.ROBIN.precache()
      enemy = new(g.classes.Class_Robin, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_RobinAI, enemy)
    g.FIGHTER_ID_RAVEN:
      g.assets.RAVEN.precache()
      enemy = new(g.classes.Class_Raven, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_RavenAI, enemy)
    g.FIGHTER_ID_CYBORG:
      g.assets.CYBORG.precache()
      enemy = new(g.classes.Class_Cyborg, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_CyborgAI, enemy)
    g.FIGHTER_ID_STARFIRE:
      g.assets.BEASTBOY.precache()
      enemy = new(g.classes.Class_Starfire, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_StarfireAI, enemy)
    g.FIGHTER_ID_BEASTBOY:
      g.assets.BEASTBOY.precache()
      enemy = new(g.classes.Class_Beastboy, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_BeastboyAI, enemy)
    g.FIGHTER_ID_JINX:
      g.assets.JINX.precache()
      enemy = new(g.classes.Class_Jinx, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_JinxAI, enemy)
    g.FIGHTER_ID_MAMMOTH:
      g.assets.MAMMOTH.precache()
      enemy = new(g.classes.Class_Mammoth, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_MammothAI, enemy)
    g.FIGHTER_ID_GIZMO:
      g.assets.GIZMO.precache()
      enemy = new(g.classes.Class_Gizmo, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_GizmoAI, enemy)
    g.FIGHTER_ID_CINDERBLOCK:
      g.assets.CINDERBLOCK.precache()
      enemy = new(g.classes.Class_Cinderblock, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_CinderblockAI, enemy)
    g.FIGHTER_ID_PLASMUS:
      g.assets.PLASMUS.precache()
      enemy = new(g.classes.Class_Plasmus, enemyInitHealth)
      enemyAdapter = new(g.classes.Class_PlasmusAI, enemy)
  end case
  player.setOpponent(enemy)
  enemy.setOpponent(player)
  collisionGroup.addToGroup(player)
  collisionGroup.addToGroup(enemy)
  if g.playMode = g.PLAYMODE_AS_TITANS then
    titan = player
    villain = enemy
  else
    titan = enemy
    villain = player
  end if
  scene = new(g.classes.Class_Scene, me)
  hud = new(g.classes.Class_HUD, me)
  g.main.keyMgr.addListener(me)
  clock = new(g.classes.Class_GameTimer, g.ROUND_DURATION)
  controlsPopup = new(g.classes.Class_ControlsPopUp)
  gameStage = 1
  initStage = 1
  g.gameSpeed = 1.0
  roundNum = 0
  playerWins = 0
  enemyWins = 0
  matchScore = 0
  prevHitTimestamp = 0
  hitChainMultiplier = 1
  delayFrames = 0
  paused = 0
end

on unload me
  me.loaded = 0
  g.main.keyMgr.removeListener(me)
  g.main.keyMgr.removeListener(playerAdapter)
  controlsPopup = controlsPopup.destroy()
  clock = clock.destroy()
  hud = hud.destroy()
  playerAdapter = playerAdapter.destroy()
  enemyAdapter = enemyAdapter.destroy()
  enemy = enemy.destroy()
  player = player.destroy()
  titan = VOID
  villain = VOID
  effectGroup = effectGroup.destroy()
  projectileGroup = projectileGroup.destroy()
  collisionGroup = collisionGroup.destroy()
  scene = scene.destroy()
  spriteMgr = spriteMgr.destroy()
  g.main.audioMgr.fadeOutSound(musicEventID, 0, 0.75)
end

on checkFighterOverlap me
  fighter1 = player
  fighter2 = enemy
  fighterX1 = fighter1.getPosX()
  fighterX2 = fighter2.getPosX()
  fighterDefBox1 = fighter1.getDefenseBox()
  fighterDefBox2 = fighter2.getDefenseBox()
  if fighterDefBox1.intersect(fighterDefBox2) <> g.RECT_0 then
    if not fighter1.isDoingMove() and not fighter2.isDoingMove() then
      if (fighterX2 - fighterX1) > 0.0 then
        dX = (fighterDefBox1.right - fighterDefBox2.left) / 2.0
      else
        dX = -(fighterDefBox2.right - fighterDefBox1.left) / 2.0
      end if
      fighter1.setPosX(fighterX1 - dX)
      fighter2.setPosX(fighterX2 + dX)
    else
      if fighter1.moveRef.isImmobile() then
        corrFactor1 = 0.0
      else
        if fighter2.moveRef.isImmobile() then
          corrFactor1 = 1.0
        else
          corrFactor1 = 0.5
        end if
      end if
      corrFactor2 = 1.0 - corrFactor1
      diffX = fighterX2 - fighterX1
      if diffX > 0.0 then
        dX = (fighterDefBox1.right - fighterDefBox2.left) / 2.0
      else
        if diffX < 0.0 then
          dX = -(fighterDefBox2.right - fighterDefBox1.left) / 2.0
        else
          if fighter1.getDir() > fighter2.getDir() then
            dX = (fighterDefBox1.right - fighterDefBox2.left) / 2.0
          else
            dX = -(fighterDefBox2.right - fighterDefBox1.left) / 2.0
          end if
        end if
      end if
      fighter1.setPosX(fighterX1 - (dX * corrFactor1))
      fighter2.setPosX(fighterX2 + (dX * corrFactor1))
    end if
    fighter1.updateBoundingBoxes()
    fighter2.updateBoundingBoxes()
  end if
end

on updateCollisions me
  count = collisionGroup.getCount()
  repeat with i = 1 to count
    repeat with j = 1 to count
      if i <> j then
        sourceObj = collisionGroup.getIndex(i)
        targetObj = collisionGroup.getIndex(j)
        if sourceObj.collidesWith(targetObj) then
          sourceObj.registerCollision(targetObj)
        end if
      end if
    end repeat
  end repeat
  repeat with o in collisionGroup.getList()
    o.processCollisions()
  end repeat
end

on updateProjectiles me
  killList = []
  repeat with i = 1 to projectileGroup.getCount()
    o = projectileGroup.getIndex(i)
    if o.isAlive() then
      if not o.isFrozen() then
        o.update()
      end if
      next repeat
    end if
    killList.append(o)
  end repeat
  repeat with o in killList
    me.killProjectile(o)
  end repeat
end

on updateEffects me
  killList = []
  repeat with i = 1 to effectGroup.getCount()
    o = effectGroup.getIndex(i)
    if o.isAlive() then
      if not o.isFrozen() then
        o.update()
      end if
      next repeat
    end if
    killList.append(o)
  end repeat
  repeat with o in killList
    me.killEffect(o)
  end repeat
end

on setPause me, b
  paused = b
end

on setStage me, i
  case i of
    GAMESTAGE_INTRO:
      g.goFrame = label("SCREEN_GAME")
    GAMESTAGE_PLAY:
      g.goFrame = label("SCREEN_GAME_PLAY")
    GAMESTAGE_KO:
      g.goFrame = label("SCREEN_GAME_KO")
    GAMESTAGE_TIMEUP:
      g.goFrame = label("SCREEN_GAME_TIMEUP")
    GAMESTAGE_WIN:
      g.goFrame = label("SCREEN_GAME_WIN")
    GAMESTAGE_SCORE:
      g.goFrame = label("SCREEN_GAME_SCORE")
  end case
  gameStage = i
  initStage = 1
end

on advanceStage me
  me.setStage(gameStage + 1)
end

on update me
  if controlsPopup.isVisible() <> paused then
    controlsPopup.setVisible(paused)
  end if
  case gameStage of
    GAMESTAGE_INTRO:
      if initStage then
        initStage = 0
        titan.setPos(-150, 0)
        villain.setPos(150, 0)
        clock.reset()
        player.reset()
        enemy.reset()
        hud.reset()
        playerAdapter.reset()
        enemyAdapter.reset()
        roundNum = roundNum + 1
        roundState = ROUNDSTATE_FIGHT_IN_PROGRESS
        paused = 0
        controlsPopup.setVisible(paused)
        playerAdapter.setEnabled(0)
        enemyAdapter.setEnabled(0)
      end if
      player.update()
      enemy.update()
      scene.update()
      hud.update()
      if the frame = (marker(1) - 1) then
        me.advanceStage()
      end if
    GAMESTAGE_PLAY:
      if initStage then
        initStage = 0
        playerAdapter.setEnabled(1)
        enemyAdapter.setEnabled(1)
        if roundNum = 1 then
          case random(4) of
            1:
              musicEventID = g.main.audioMgr.playSound(g.assets.AUDIO.MUSIC_LOOP2, 50, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
            2:
              musicEventID = g.main.audioMgr.playSound(g.assets.AUDIO.MUSIC_LOOP3, 50, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
            3:
              musicEventID = g.main.audioMgr.playSound(g.assets.AUDIO.MUSIC_LOOP4, 50, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
            4:
              musicEventID = g.main.audioMgr.playSound(g.assets.AUDIO.MUSIC_LOOP5, 50, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
          end case
        end if
      end if
      if not paused then
        prevTime = clock.getTime()
        clock.update()
        currTime = clock.getTime()
        playerAdapter.update()
        enemyAdapter.update()
        player.update()
        enemy.update()
        me.updateProjectiles()
        me.checkFighterOverlap()
        me.updateCollisions()
        me.updateEffects()
        scene.update()
        hud.update()
        if enemy.getHealth() = 0 then
          playerWins = playerWins + 1
          if g.playMode = g.PLAYMODE_AS_TITANS then
            hud.setTitanWins(playerWins)
            roundState = ROUNDSTATE_TITAN_WINS_BY_DAMAGE
          else
            hud.setVillainWins(playerWins)
            roundState = ROUNDSTATE_VILLAIN_WINS_BY_DAMAGE
          end if
          if playerWins = 2 then
            me.setStage(GAMESTAGE_KO)
          else
            me.setStage(GAMESTAGE_WIN)
          end if
        else
          if player.getHealth() = 0 then
            enemyWins = enemyWins + 1
            if g.playMode = g.PLAYMODE_AS_TITANS then
              hud.setVillainWins(enemyWins)
              roundState = ROUNDSTATE_VILLAIN_WINS_BY_DAMAGE
            else
              hud.setTitanWins(enemyWins)
              roundState = ROUNDSTATE_TITAN_WINS_BY_DAMAGE
            end if
            if enemyWins = 2 then
              me.setStage(GAMESTAGE_KO)
            else
              me.setStage(GAMESTAGE_WIN)
            end if
          else
            if currTime <= 10 then
              if prevTime <> currTime then
                g.main.audioMgr.playSound(g.assets.AUDIO.SFX_TIME_WARNING, 75, g.SFX_EVENT_PRIORITY_LOW)
              end if
              if currTime = 0 then
                if player.getHealthScalar() > enemy.getHealthScalar() then
                  playerWins = playerWins + 1
                  if g.playMode = g.PLAYMODE_AS_TITANS then
                    hud.setTitanWins(playerWins)
                    roundState = ROUNDSTATE_TITAN_WINS_BY_TIME
                  else
                    hud.setVillainWins(playerWins)
                    roundState = ROUNDSTATE_VILLAIN_WINS_BY_TIME
                  end if
                  me.setStage(GAMESTAGE_TIMEUP)
                else
                  enemyWins = enemyWins + 1
                  if g.playMode = g.PLAYMODE_AS_TITANS then
                    hud.setVillainWins(enemyWins)
                    roundState = ROUNDSTATE_VILLAIN_WINS_BY_TIME
                  else
                    hud.setTitanWins(enemyWins)
                    roundState = ROUNDSTATE_TITAN_WINS_BY_TIME
                  end if
                  me.setStage(GAMESTAGE_TIMEUP)
                end if
              end if
            end if
          end if
        end if
      end if
    GAMESTAGE_KO:
      if initStage then
        initStage = 0
        g.gameSpeed = 0.40000000000000002
        g.main.audioMgr.stopSound(g.assets.AUDIO.MUSIC_LOOP2)
        g.main.audioMgr.stopSound(g.assets.AUDIO.MUSIC_LOOP3)
        g.main.audioMgr.stopSound(g.assets.AUDIO.MUSIC_LOOP4)
        g.main.audioMgr.stopSound(g.assets.AUDIO.MUSIC_LOOP5)
        if (roundState = ROUNDSTATE_TITAN_WINS_BY_DAMAGE) or (roundState = ROUNDSTATE_TITAN_WINS_BY_TIME) then
          musicEventID = g.main.audioMgr.playSound(g.assets.AUDIO.MUSIC_TEEN_LOOP, 70, g.SFX_EVENT_PRIORITY_LOW)
        else
          musicEventID = g.main.audioMgr.playSound(g.assets.AUDIO.MUSIC_KEYBOARD_LOOP, 50, g.SFX_EVENT_PRIORITY_LOW)
        end if
        playerAdapter.setEnabled(0)
        enemyAdapter.setEnabled(0)
      end if
      player.update()
      enemy.update()
      me.updateProjectiles()
      me.checkFighterOverlap()
      me.updateEffects()
      scene.update()
      hud.update()
      if the frame = (marker(1) - 1) then
        if not player.isAlive() or not enemy.isAlive() then
          me.setStage(GAMESTAGE_WIN)
        end if
      end if
    GAMESTAGE_TIMEUP:
      if initStage then
        initStage = 0
        playerAdapter.setEnabled(0)
        enemyAdapter.setEnabled(0)
      end if
      player.update()
      enemy.update()
      me.updateProjectiles()
      me.checkFighterOverlap()
      me.updateEffects()
      scene.update()
      hud.update()
      if the frame = (marker(1) - 1) then
        me.setStage(GAMESTAGE_WIN)
      end if
    GAMESTAGE_WIN:
      if initStage then
        initStage = 0
      end if
      player.update()
      enemy.update()
      me.updateProjectiles()
      me.checkFighterOverlap()
      me.updateEffects()
      scene.update()
      hud.update()
      if the frame = (marker(1) - 1) then
        b = ((roundState = ROUNDSTATE_TITAN_WINS_BY_DAMAGE) and not villain.isAlive()) or ((roundState = ROUNDSTATE_VILLAIN_WINS_BY_DAMAGE) and not titan.isAlive()) or (roundState = ROUNDSTATE_TITAN_WINS_BY_TIME) or (roundState = ROUNDSTATE_VILLAIN_WINS_BY_TIME)
        if b then
          if (playerWins = 2) or (enemyWins = 2) then
            me.setStage(GAMESTAGE_SCORE)
          else
            me.setStage(GAMESTAGE_INTRO)
          end if
        end if
      end if
    GAMESTAGE_SCORE:
      if initStage then
        initStage = 0
        delayFrames = 30
      end if
      player.update()
      enemy.update()
      me.updateProjectiles()
      me.checkFighterOverlap()
      me.updateEffects()
      scene.update()
      hud.update()
      delayFrames = delayFrames - 1
      if delayFrames = 0 then
        if playerWins = 2 then
          g.defeatedEnemies[g.playerID][g.enemyID] = 1
          if matchScore > g.playerScores[g.playerID][g.enemyID] then
            g.playerScores[g.playerID][g.enemyID] = matchScore
          end if
          if g.playMode = g.PLAYMODE_AS_TITANS then
            playerFighterOrder = g.TITAN_FIGHTER_ORDER
            enemyFighterOrder = g.VILLAIN_FIGHTER_ORDER
            playerOrderIndex = playerFighterOrder.getPos(g.titanID)
            enemyOrderIndex = enemyFighterOrder.getPos(g.villainID)
          else
            playerFighterOrder = g.VILLAIN_FIGHTER_ORDER
            enemyFighterOrder = g.TITAN_FIGHTER_ORDER
          end if
          playerOrderIndex = playerFighterOrder.getPos(g.playerID)
          enemyOrderIndex = enemyFighterOrder.getPos(g.enemyID)
          if enemyOrderIndex < enemyFighterOrder.count then
            nextEnemyID = enemyFighterOrder[enemyOrderIndex + 1]
            if g.availableEnemies[nextEnemyID] then
              g.unlockedEnemies[g.playerID][nextEnemyID] = 1
              g.enemyID = nextEnemyID
              if g.playMode = g.PLAYMODE_AS_TITANS then
                g.villainID = nextEnemyID
              else
                g.titanID = nextEnemyID
              end if
            end if
          else
            if not g.victories[g.playerID] then
              g.victories[g.playerID] = 1
              g.goFrame = label("Win")
            end if
          end if
        end if
        if not g.goFrame then
          g.goFrame = label("SCREEN_SELECTFIGHTER")
        end if
      end if
  end case
end

on paint me
  player.paint()
  enemy.paint()
  repeat with o in projectileGroup.getList()
    o.paint()
  end repeat
  repeat with o in effectGroup.getList()
    o.paint()
  end repeat
  scene.paint()
  hud.paint()
end

on addProjectile me, o
  projectileGroup.addToGroup(o)
  collisionGroup.addToGroup(o)
end

on removeProjectile me, o
  projectileGroup.removeFromGroup(o)
  collisionGroup.removeFromGroup(o)
end

on freezeProjectiles me, owner, b
  repeat with o in projectileGroup.getList()
    if o.owner = owner then
      o.setFrozen(b)
    end if
  end repeat
end

on killProjectile me, o
  projectileGroup.removeFromGroup(o)
  collisionGroup.removeFromGroup(o)
  o.destroy()
end

on addEffect me, o
  effectGroup.addToGroup(o)
end

on removeEffect me, o
  effectGroup.removeFromGroup(o)
end

on killEffect me, o
  effectGroup.removeFromGroup(o)
  o.destroy()
end

on freezeEffects me, owner, b
  repeat with o in effectGroup.getList()
    if o.owner = owner then
      o.setFrozen(b)
    end if
  end repeat
end

on getTime me
  return clock.getTime()
end

on getScore me
  return matchScore
end

on addScore me, points
  matchScore = matchScore + points
end

on awardPoints me, fighterObj, points
  if fighterObj = enemy then
    hitChainMultiplier = 1
    exit
  else
    if points = 0 then
      hitChainMultiplier = 1
    else
      me.addScore(integer(points * 10 * hitChainMultiplier * g.difficulty))
      if hitChainMultiplier < 10 then
        hitChainMultiplier = hitChainMultiplier + 1
      end if
    end if
  end if
  prevHitTimestamp = g.frameTimestamp
end

on canSummon me, summoner, fighterID
  return playerCanSummon[fighterID]
end

on summonTitan me, summoner, fighterID
  case fighterID of
    g.FIGHTER_ID_ROBIN:
      class = g.classes.Class_SummonRobinEffect
    g.FIGHTER_ID_RAVEN:
      class = g.classes.Class_SummonRavenEffect
    g.FIGHTER_ID_CYBORG:
      class = g.classes.Class_SummonCyborgEffect
    g.FIGHTER_ID_STARFIRE:
      class = g.classes.Class_SummonStarfireEffect
    g.FIGHTER_ID_BEASTBOY:
      class = g.classes.Class_SummonBeastboyEffect
    otherwise:
      return 
  end case
  effect = new(class, summoner, summoner.pos, point(0, 0), summoner.dir)
  me.addEffect(effect)
  hud.useSummonPortrait(fighterID)
  playerCanSummon[fighterID] = 0
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_SUMMON_TITAN, 100, g.SFX_EVENT_PRIORITY_LOW)
  return effect
end

on keyDown me, event
  case event.keyCode of
    g.KEYCODE_ESC:
      g.goFrame = label("SCREEN_SELECTFIGHTER")
    g.KEYCODE_P:
      if gameStage = GAMESTAGE_PLAY then
        me.setPause(not paused)
        if not paused then
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_CHARACTERSWITCH3, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
      end if
  end case
  playSound = 0
  if cheat_toggleFPS.checkKey(event.keyCode) then
    hud.showFPS(not hud.isFPS())
    playSound = 1
  end if
  if cheat_toggleAI.checkKey(event.keyCode) then
    g.game.enemyAdapter.setEnabled(not g.game.enemyAdapter.isEnabled())
    playSound = 1
  end if
  if cheat_reduceVillainHealth.checkKey(event.keyCode) then
    villain.health = 100
    playSound = 1
  end if
  if cheat_reduceTitanHealth.checkKey(event.keyCode) then
    titan.health = 100
    playSound = 1
  end if
  if cheat_invulnerability.checkKey(event.keyCode) then
    if player.naturalDefense then
      player.naturalDefense = 0
    else
      player.naturalDefense = 100
    end if
    playSound = 1
  end if
  if playSound then
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNFIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
  end if
end

on keyUp me, event
end
