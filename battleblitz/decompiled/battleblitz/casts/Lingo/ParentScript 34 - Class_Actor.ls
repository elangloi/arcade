property pos, vel, dir, animation, visSprite
global g

on new me, initPos, initVel, initDir
  me.setPos(initPos)
  me.setVel(initVel)
  me.setDir(initDir)
  state = 0
  visSprite = sprite(0)
  return me
end

on destroy me
  return VOID
end

on update me
  pos = pos + (vel * g.gameSpeed)
end

on paint me
  visSprite.loc = g.screen.scene.scenePosToStagePos(pos)
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

on getVel me
  return vel
end

on getVelX me
  return vel.locH
end

on getVelY me
  return vel.locV
end

on setVelX me, x
  vel.locH = x
end

on setVelY me, y
  vel.locV = y
end

on setVel me, a1, a2
  if ilk(a1) = #point then
    vel = point(float(a1.locH), float(a1.locV))
  else
    vel = point(float(a1), float(a2))
  end if
end

on setDir me, i
  dir = i
end

on getDir me
  return dir
end

on accelerate me, a1, a2
  if ilk(a1) = #point then
    vel = vel + (a1 * g.gameSpeed)
  else
    vel = vel + (point(float(a1), float(a2)) * g.gameSpeed)
  end if
end

on getSprite me
  return visSprite
end

on isOnScreen me
  return pos.inside(g.game.scene.getViewRect())
end
