property pos, visSprite
global g

on new me, initPos, initLocZ
  me.setPos(initPos)
  visSprite = g.game.spriteMgr.grabSprite()
  visSprite.loc = pos
  visSprite.ink = 36
  visSprite.locZ = initLocZ
  return me
end

on destroy me
  g.game.spriteMgr.releaseSprite(visSprite)
  return VOID
end

on update me
end

on paint me
  visSprite.loc = pos
end

on getPosX me
  return pos.locH
end

on getPosY me
  return pos.locV
end

on getPos me
  return pos
end

on setPosX me, x
  pos.locH = float(x)
end

on setPosY me, y
  pos.locV = float(y)
end

on setPos me, a1, a2
  if ilk(a1) = #point then
    pos = point(float(a1.locH), float(a1.locV))
  else
    pos = point(float(a1), float(a2))
  end if
end

on moveBy me, a1, a2
  if ilk(a1) = #point then
    pos = pos + a1
  else
    pos = pos + point(float(a1), float(a2))
  end if
end

on getFlipX me
  return visSprite.flipH
end

on setFlipX me, b
  visSprite.flipH = b
end

on getFlipY me
  return visSprite.flipV
end

on setFlipY me, b
  visSprite.flipV = b
end

on setVisible me, b
  visSprite.visible = b
end

on isVisible me
  return visSprite.visible
end

on getSprite me
  return visSprite
end

on setMember me, mem
  visSprite.member = mem
end

on getMember me
  return visSprite.member
end

on setInk me, i
  visSprite.ink = i
end

on getInk me
  return visSprite.ink
end
