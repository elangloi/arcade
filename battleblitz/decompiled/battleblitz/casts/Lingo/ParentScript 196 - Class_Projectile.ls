property ancestor, owner, armed, attackDamage, stunDuration, alive, attackMasks, age, hitOpponent, frozen
global g

on new me, obj, initPos, initVel, initDir
  ancestor = new(g.classes.Class_CollidableActor, initPos, initVel, initDir)
  owner = obj
  attackMasks = []
  attackDamage = 0
  stunDuration = 0
  alive = 1
  armed = 1
  frozen = 0
  hitOpponent = 0
  age = 0
  me.visSprite = g.game.spriteMgr.grabSprite()
  me.visSprite.locZ = g.SPRITE_LOCZ_PROJECTILES
  me.visSprite.ink = g.INK_BGTRANSPARENT
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
  g.game.spriteMgr.releaseSprite(me.visSprite)
  me.visSprite = sprite(0)
  alive = 0
end

on isAlive me
  return alive
end

on isArmed me
  return armed
end

on setArmed me, b
  armed = b
end

on isFrozen me
  return frozen
end

on setFrozen me, b
  frozen = b
end

on isOutOfPlay me
  if me.dir > 0 then
    if me.getPosX() > (g.game.scene.getViewRect().right + 100) then
      return 1
    end if
  else
    if me.getPosX() < (g.game.scene.getViewRect().left - 100) then
      return 1
    end if
  end if
  return 0
end

on getAttackMaskMember me
  return attackMasks[me.animation.currIndex]
end

on getAttackRect me
  m = me.getAttackMaskMember()
  if m.number > 0 then
    p = m.regPoint
    return m.rect - rect(p, p)
  else
    return rect(0, 0, 0, 0)
  end if
end

on updateAttackBoundingBox me
  r = me.getAttackRect()
  if me.dir < 0 then
    r = rect(-r.right, r.top, -r.left, r.bottom)
  end if
  me.attBox = r.offset(me.getPosX(), me.getPosY())
end

on update me
  if alive then
    if not frozen then
      age = age + 1
      me.setPos(me.pos + me.vel)
      if not voidp(me.animation) then
        if age > 1 then
          me.animation.advance()
        end if
        if me.visSprite.spriteNum > 0 then
          me.visSprite.member = me.animation.getMember()
        end if
        me.updateBoundingBoxes()
        if me.animation.isDone() then
          me.kill()
        end if
      end if
    end if
  end if
end

on paint me
  p = g.screen.scene.scenePosToStagePos(me.pos)
  me.visSprite.loc = p
end

on processCollisions me
  if not armed then
    exit
  end if
  repeat with i = 1 to me.collisions.count
    target = me.collisions[i]
    if target = me.owner.opponent then
      if not me.contactTable.hasObject(target) then
        damage = target.reactToCollision(attackDamage, stunDuration)
        hitOpponent = 1
        notBlocked = me.triggerPayoff()
        if notBlocked then
          me.owner.awardPoints(damage)
        else
          me.owner.awardPoints(0)
        end if
      end if
    end if
    me.contactTable.addObject(target)
  end repeat
  me.resetCollisions()
end

on triggerPayoff me
  if not me.alive then
    return 0
  end if
  me.kill()
  return 0
end
