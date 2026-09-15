property ancestor, owner, state, alive, age, frozen
global g

on new me, obj, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Actor, initPos, initVel, initDir)
  owner = obj
  alive = 1
  frozen = 0
  age = 0
  me.visSprite = g.game.spriteMgr.grabSprite()
  me.visSprite.locZ = g.SPRITE_LOCZ_EFFECTS_FOREGROUND
  me.visSprite.ink = 36
  me.visSprite.blend = 85
  me.visSprite.flipH = initDir < 0
  return me
end

on destroy me
  ancestor.destroy()
  if alive then
    me.kill()
  end if
  return VOID
end

on kill me
  alive = 0
  g.game.spriteMgr.releaseSprite(me.visSprite)
  me.visSprite = sprite(0)
end

on isAlive me
  return alive
end

on isFrozen me
  return frozen
end

on setFrozen me, b
  frozen = b
end

on update me
  if alive then
    if not frozen then
      age = age + 1
      if me.animation.isDone() then
        me.kill()
      else
        if alive then
          me.setPos(me.pos + me.vel)
          if age > 1 then
            me.animation.advance()
          end if
          if me.visSprite.spriteNum > 0 then
            me.visSprite.member = me.animation.getMember()
          end if
        end if
      end if
    end if
  end if
end
