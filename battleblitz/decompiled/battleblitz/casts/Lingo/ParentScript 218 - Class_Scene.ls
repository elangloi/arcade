property game, bgMember, bgSprite, stageRect, sceneOrigin, sceneRect, sceneBoundsMinX, sceneBoundsMaxX, viewCenterMinX, viewCenterMaxX, viewCenterMinY, viewCenterMaxY, viewOriginRect, viewRect, viewCenter, viewUpperLeft, platforms, ambientAudioID
global g

on new me, obj
  game = obj
  platforms = []
  platforms.append([point(-1200.0, 0.0), point(1200.0, 0.0)])
  case g.villainID of
    g.FIGHTER_ID_JINX:
      bgMember = g.assets.JINX.JINX_BACKGROUND
      sceneLeftBufferX = 175
      sceneRightBufferX = 300
      platforms.append([point(-1200.0, -236.0), point(-955.0, -236.0)])
      platforms.append([point(712.0, -160.0), point(1200.0, -160.0)])
      platforms.append([point(712.0, -305.0), point(1200.0, -305.0)])
      ambientAudioID = g.main.audioMgr.playSound(g.assets.JINX.SFX_JINX_BG_CROWDNOISE3, 100, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
    g.FIGHTER_ID_MAMMOTH:
      bgMember = g.assets.MAMMOTH.MAMMOTH_BACKGROUND
      sceneLeftBufferX = 210
      sceneRightBufferX = 340
      platforms.append([point(-1200.0, -206.0), point(-840.0, -206.0)])
      platforms.append([point(576.0, -140.0), point(748.0, -140.0)])
      ambientAudioID = g.main.audioMgr.playSound(g.assets.MAMMOTH.SFX_MAMMOTH_AMBIENT, 100, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
    g.FIGHTER_ID_GIZMO:
      bgMember = g.assets.GIZMO.GIZMO_BACKGROUND
      sceneLeftBufferX = 210
      sceneRightBufferX = 300
      platforms.append([point(-1200.0, -205.0), point(-830.0, -205.0)])
      platforms.append([point(715.0, -215.0), point(1200.0, -215.0)])
      ambientAudioID = g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_AMBIENTBACKGROUNDLOOP, 100, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
    g.FIGHTER_ID_CINDERBLOCK:
      bgMember = g.assets.CINDERBLOCK.CINDERBLOCK_BACKGROUND
      sceneLeftBufferX = 200
      sceneRightBufferX = 300
      platforms.append([point(-1200.0, -180.0), point(-930.0, -180.0)])
      platforms.append([point(740.0, -180.0), point(1200.0, -180.0)])
      ambientAudioID = g.main.audioMgr.playSound(g.assets.CINDERBLOCK.SFX_CINDERBLOCK_BG_SIRENS, 60, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
    g.FIGHTER_ID_PLASMUS:
      bgMember = g.assets.PLASMUS.PLASMUS_BACKGROUND
      sceneLeftBufferX = 200
      sceneRightBufferX = 160
      platforms.append([point(-1200.0, -238.0), point(-835.0, -238.0)])
      platforms.append([point(-875.0, -87.0), point(-835.0, -87.0)])
      platforms.append([point(948.0, -148.0), point(985.0, -148.0)])
      platforms.append([point(1005.0, -238.0), point(1200.0, -238.0)])
      platforms.append([point(892.0, -283.0), point(932.0, -283.0)])
      ambientAudioID = g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_AMBIENTLOOPSCARIER, 100, g.SFX_EVENT_PRIORITY_UNINTERRUPTIBLE)
  end case
  bgMember.regPoint = point(1200, 520)
  bgSprite = g.game.spriteMgr.grabSprite()
  bgSprite.member = bgMember
  bgSprite.locZ = g.SPRITE_LOCZ_BACKGROUND
  sceneOrigin = point(0, 0)
  sceneRect = bgMember.rect - rect(bgMember.regPoint, bgMember.regPoint)
  sceneBoundsMinX = sceneRect.left + sceneLeftBufferX
  sceneBoundsMaxX = sceneRect.right - sceneRightBufferX
  stageRect = (the stage).rect
  halfViewWidth = stageRect.width / 2
  halfViewHeight = stageRect.height / 2
  viewCenterMinX = sceneRect.left + halfViewWidth
  viewCenterMaxX = sceneRect.right - halfViewWidth
  viewCenterMinY = sceneRect.top + halfViewHeight
  viewCenterMaxY = sceneRect.bottom - halfViewHeight
  viewOriginRect = rect(-halfViewWidth, -halfViewHeight, halfViewWidth, halfViewHeight)
  viewRect = viewOriginRect
  viewCenter = sceneOrigin
  viewUpperLeft = point(viewRect.left, viewRect.top)
  return me
end

on destroy me
  g.game.spriteMgr.releaseSprite(bgSprite)
  if ambientAudioID then
    g.main.audioMgr.fadeOutSound(ambientAudioID, 0, 0.75)
  end if
  return VOID
end

on onGround me, pos
  repeat with plat in platforms
    if pos.locV = plat[1].locV then
      if (pos.locH >= plat[1].locH) and (pos.locH <= plat[2].locH) then
        return 1
      end if
    end if
  end repeat
  return 0
end

on intersectsGround me, origPos, newPos, retList
  repeat with plat in platforms
    if g.util.getLineIntersection(origPos.locH, origPos.locV, newPos.locH, newPos.locV, plat[1].locH, plat[1].locV, plat[2].locH, plat[2].locV, retList) then
      return 1
    end if
  end repeat
  return 0
end

on update me
  playerPos = game.player.getPos() - point(0, 100)
  enemyPos = game.enemy.getPos() - point(0, 100)
  deltaX = playerPos.locH - enemyPos.locH
  weight = 1.0 - ((abs(deltaX) - 300) / 600.0)
  if weight < 0.0 then
    weight = 0.0
  else
    if weight > 1.0 then
      weight = 1.0
    end if
  end if
  viewCenter = (playerPos + (enemyPos * weight)) / (1.0 + weight)
  if viewCenter.locH < viewCenterMinX then
    viewCenter.locH = viewCenterMinX
  else
    if viewCenter.locH > viewCenterMaxX then
      viewCenter.locH = viewCenterMaxX
    end if
  end if
  if viewCenter.locV < viewCenterMinY then
    viewCenter.locV = viewCenterMinY
  else
    if viewCenter.locV > viewCenterMaxY then
      viewCenter.locV = viewCenterMaxY
    end if
  end if
  viewRect = viewOriginRect + rect(viewCenter, viewCenter)
  viewUpperLeft = point(viewRect.left, viewRect.top)
end

on paint me
  bgSprite.loc = me.scenePosToStagePos(sceneOrigin)
end

on scenePosToStagePos me, p
  return p - viewUpperLeft
end

on constrainToBounds me, p
  if p.locH < sceneBoundsMinX then
    p.locH = sceneBoundsMinX
  else
    if p.locH > sceneBoundsMaxX then
      p.locH = sceneBoundsMaxX
    end if
  end if
  return p
end

on getViewRect me
  return viewRect
end

on getBoundsMaxX me
  return sceneBoundsMaxX
end

on getBoundsMinX me
  return sceneBoundsMinX
end
