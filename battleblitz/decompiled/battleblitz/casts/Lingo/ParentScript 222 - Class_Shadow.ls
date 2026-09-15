property ancestor, owner, initWidth, initHeight
global g

on new me, obj, width
  ancestor = new(g.classes.Class_Actor, point(0, 0), point(0, 0), 0)
  mem = g.assets.CHAR_SHARED.FX_SHADOW
  owner = obj
  if not voidp(width) then
    me.setWidth(width)
  else
    me.setWidth(100)
  end if
  me.visSprite = g.game.spriteMgr.grabSprite()
  me.visSprite.member = mem
  me.visSprite.ink = g.INK_MATTE
  me.visSprite.blend = 30
  me.visSprite.locZ = g.SPRITE_LOCZ_SHADOWS
  return me
end

on destroy me
  ancestor.destroy()
  g.game.spriteMgr.releaseSprite(me.visSprite)
  return VOID
end

on calcScale me, h
  scale = 1.0 - abs(h / 500.0)
  if scale < 0.0 then
    return 0.0
  else
    if scale > 1000.0 then
      return 1000.0
    else
      return scale
    end if
  end if
end

on update me
  ancestor.update()
  me.setPosX(owner.getPosX())
  if owner.handler(#isOnGround) then
    if owner.isOnGround() then
      me.setPosY(owner.getPosY())
      scale = me.calcScale(0.0)
    else
      me.setPosY(0.0)
      scale = me.calcScale(owner.getPosY())
    end if
  else
    me.setPosY(0.0)
    scale = me.calcScale(owner.getPosY())
  end if
  me.visSprite.width = initWidth * scale
  me.visSprite.height = initHeight * scale
end

on setWidth me, width
  mem = g.assets.CHAR_SHARED.FX_SHADOW
  initWidth = width
  initHeight = mem.height * float(width) / float(mem.width)
end
