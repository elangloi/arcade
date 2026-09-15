property pName, pFighter, fighterID, tagSprite
global g

on beginSprite me
  whichName = sprite(me.spriteNum).member.name
  startchar = offset("_", whichName) + 1
  endchar = offset(".", whichName) - 1
  pFighter = chars(whichName, startchar, endchar)
  fighterID = g.main.screen.fighterNames.getOne(pFighter)
  sprite(fighterID + 50).visible = 0
end

on mouseEnter me
  if g.availableEnemies[fighterID] and g.unlockedEnemies[g.playerID][fighterID] and (g.enemyID <> fighterID) then
    sprite(fighterID + 50).visible = 1
    cursor(280)
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEOVERCHARACTERS, 75, g.SFX_EVENT_PRIORITY_LOW)
  end if
end

on mouseLeave me
  sprite(fighterID + 50).visible = 0
  cursor(-1)
end

on mouseDown me
  if g.availableEnemies[fighterID] and g.unlockedEnemies[g.playerID][fighterID] and (g.enemyID <> fighterID) then
    g.main.screen.setOpponent(fighterID)
    cursor(-1)
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNCHARACTERSWITCH, 100, g.SFX_EVENT_PRIORITY_LOW)
    sprite(fighterID + 50).visible = 0
  else
    g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MISCLICK, 60, g.SFX_EVENT_PRIORITY_LOW)
  end if
end
