property FIGHTERSTATE_ALIVE, FIGHTERSTATE_FROZEN, FIGHTERSTATE_ON_GROUND, FIGHTERSTATE_DOING_MOVE, FIGHTERSTATE_PUPPET, FIGHTERSTATE_SHAKING, FIGHTERSTATE_HOVERING, FIGHTERSTATE_ENRAGED, FIGHTERSTATE_SHOWTRAILS, SHADOW_WIDTH, WALK_SPEED, HEALTH_MAX, HEALTH_ENRAGED_THRESHOLD, ancestor, opponent, state, moves, moveRef, currMove, prevMove, nextMove, nextMoveArg, moveCount, health, naturalDefense, shadow, trails
global g

on new me, initHealth
  ancestor = new(g.classes.Class_CollidableActor, point(0, 0), point(0, 0), 1)
  FIGHTERSTATE_ALIVE = 1
  FIGHTERSTATE_FROZEN = 2
  FIGHTERSTATE_ON_GROUND = 4
  FIGHTERSTATE_DOING_MOVE = 8
  FIGHTERSTATE_PUPPET = 16
  FIGHTERSTATE_SHAKING = 32
  FIGHTERSTATE_HOVERING = 64
  FIGHTERSTATE_ENRAGED = 128
  FIGHTERSTATE_SHOWTRAILS = 256
  WALK_SPEED = 15.0
  HEALTH_MAX = initHealth
  HEALTH_ENRAGED_THRESHOLD = integer(HEALTH_MAX * 0.20000000000000001)
  state = 0
  me.setState(FIGHTERSTATE_ALIVE)
  me.setState(FIGHTERSTATE_ON_GROUND)
  moves = g.util.newArray(g.MOVE_COUNT_MAX, VOID)
  currMove = 0
  prevMove = 0
  nextMove = 0
  nextMoveArg = 0
  moveRef = VOID
  moveCount = 0
  health = HEALTH_MAX
  naturalDefense = 0
  me.visSprite = g.game.spriteMgr.grabSprite()
  me.visSprite.locZ = g.SPRITE_LOCZ_TITAN_FIGHTER
  me.visSprite.ink = g.INK_BGTRANSPARENT
  shadow = new(g.classes.Class_Shadow, me, 100)
  trails = new(g.classes.Class_ActorTrails, 4, g.SPRITE_LOCZ_TITAN_FIGHTER_BG)
  return me
end

on destroy me
  ancestor.destroy()
  if objectp(trails) then
    trails.destroy()
  end if
  if objectp(shadow) then
    shadow.destroy()
  end if
  repeat with o in moves
    if objectp(o) then
      o.destroy()
    end if
  end repeat
  g.game.spriteMgr.releaseSprite(me.visSprite)
  return VOID
end

on setOpponent me, obj
  opponent = obj
end

on isBlocking me
  return currMove = g.MOVE_BLOCK
end

on setDoingMove me, b
  if b then
    me.setState(FIGHTERSTATE_DOING_MOVE)
  else
    me.clearState(FIGHTERSTATE_DOING_MOVE)
  end if
end

on isDoingMove me
  return me.hasState(FIGHTERSTATE_DOING_MOVE)
end

on setOnGround me, b
  if b then
    me.setState(FIGHTERSTATE_ON_GROUND)
  else
    me.clearState(FIGHTERSTATE_ON_GROUND)
  end if
end

on isOnGround me
  return me.hasState(FIGHTERSTATE_ON_GROUND)
end

on setAlive me, b
  if b then
    me.setState(FIGHTERSTATE_ALIVE)
  else
    me.clearState(FIGHTERSTATE_ALIVE)
  end if
end

on isAlive me
  return me.hasState(FIGHTERSTATE_ALIVE)
end

on setFrozen me, b
  if b then
    me.setState(FIGHTERSTATE_FROZEN)
  else
    me.clearState(FIGHTERSTATE_FROZEN)
  end if
end

on isFrozen me
  return me.hasState(FIGHTERSTATE_FROZEN)
end

on isPuppet me
  return me.hasState(FIGHTERSTATE_PUPPET)
end

on setPuppet me, b
  if b then
    me.setState(FIGHTERSTATE_PUPPET)
  else
    me.clearState(FIGHTERSTATE_PUPPET)
  end if
end

on isShaking me
  return me.hasState(FIGHTERSTATE_SHAKING)
end

on setShaking me, b
  if b then
    me.setState(FIGHTERSTATE_SHAKING)
  else
    me.clearState(FIGHTERSTATE_SHAKING)
  end if
end

on isHovering me
  return me.hasState(FIGHTERSTATE_HOVERING)
end

on setHovering me, b
  if b then
    me.setState(FIGHTERSTATE_HOVERING)
  else
    me.clearState(FIGHTERSTATE_HOVERING)
  end if
end

on isEnraged me
  return me.hasState(FIGHTERSTATE_ENRAGED)
end

on setEnraged me, b
  if b then
    me.setState(FIGHTERSTATE_ENRAGED)
  else
    me.clearState(FIGHTERSTATE_ENRAGED)
  end if
end

on isShowingTrails me
  return me.hasState(FIGHTERSTATE_SHOWTRAILS)
end

on setShowingTrails me, b
  if b then
    me.setState(FIGHTERSTATE_SHOWTRAILS)
  else
    me.clearState(FIGHTERSTATE_SHOWTRAILS)
  end if
end

on resetTrails me
  trails.reset()
end

on getHealth me
  return health
end

on getMove me
  return moveRef
end

on getMoveID me
  return currMove
end

on getPrevMoveID me
  return prevMove
end

on getMoveNumber me
  return moveCount
end

on setMove me, newMove, arg
  if currMove = newMove then
    exit
  end if
  prevMove = currMove
  currMove = newMove
  if not voidp(moveRef) then
    moveRef.stop()
  end if
  moveRef = moves[currMove]
  moveRef.reset(arg)
  if moveRef.isInitOwnerDir() then
    me.updateFacingDir()
  end if
  if moveRef.isInterruptible() then
    me.setDoingMove(0)
  else
    me.setDoingMove(1)
  end if
  me.contactTable.reset()
  me.animation = moveRef.animation
  moveCount = moveCount + 1
end

on queueMove me, newMove, arg
  if newMove = currMove then
    exit
  end if
  if nextMove then
    if g.MOVE_PRIORITIES[newMove] <= g.MOVE_PRIORITIES[nextMove] then
      exit
    end if
  end if
  nextMove = newMove
  nextMoveArg = arg
end

on queueDefaultMove me
  if me.isOnGround() then
    me.queueMove(g.MOVE_STAND, 0)
  else
    me.queueMove(g.MOVE_FALL, 0)
  end if
end

on updateFacingDir me
  oldDir = me.dir
  if me.getPosX() <= opponent.getPosX() then
    me.dir = 1
  else
    me.dir = -1
  end if
  if oldDir <> me.dir then
    moveRef.dirChanged()
  end if
end

on updateAttackBoundingBox me
  r = moveRef.getAttackRect()
  if me.dir < 0 then
    r = rect(-r.right, r.top, -r.left, r.bottom)
  end if
  me.attBox = r.offset(me.getPosX(), me.getPosY())
end

on updateDefenseBoundingBox me
  r = moveRef.getDefenseRect()
  if me.dir < 0 then
    r = rect(-r.right, r.top, -r.left, r.bottom)
  end if
  me.defBox = r.offset(me.getPosX(), me.getPosY())
end

on updateSprites me
  me.visSprite.member = moveRef.getVisibleMember()
  me.visSprite.flipH = bitXor(me.dir = -1, moveRef.getFlipX())
end

on reset me
  state = 0
  me.setState(FIGHTERSTATE_ALIVE)
  me.setState(FIGHTERSTATE_ON_GROUND)
  currMove = 0
  prevMove = 0
  nextMove = 0
  nextMoveArg = 0
  moveRef = VOID
  health = HEALTH_MAX
  me.setMove(g.MOVE_STAND)
end

on update me
  if me.isAlive() then
    if health < HEALTH_ENRAGED_THRESHOLD then
      me.setEnraged(1)
    end if
    if not me.isFrozen() then
      if me.isShowingTrails() then
        trails.update(me)
      else
        trails.update(VOID)
      end if
      if me.isOnGround() then
        if not me.groundCheck() then
          me.queueMove(g.MOVE_FALL, 0)
        end if
      end if
      if not me.isDoingMove() then
        me.updateFacingDir()
      end if
      if nextMove then
        if not me.isPuppet() then
          me.setMove(nextMove, nextMoveArg)
          nextMove = 0
          nextMoveArg = 0
        end if
      end if
      if currMove then
        moveRef.update()
        me.updateSprites()
        newPos = g.main.screen.scene.constrainToBounds(me.pos + (me.vel * g.gameSpeed))
        me.setPos(newPos)
        me.updateBoundingBoxes()
        if moveRef.isDone() then
          me.queueDefaultMove()
        end if
      end if
    end if
  end if
  shadow.update()
end

on paint me
  p = g.screen.scene.scenePosToStagePos(me.pos)
  if me.isShaking() then
    p = p + point(random(7) - 4, random(7) - 4)
  end if
  if me.isHovering() then
    HOVER_PERIOD = 20
    HOVER_VERT_OFFSETS = [0, 3, 5, 6, 6, 5, 3, 0, -3, -5, -6, -6, -5, -3]
    i = (HOVER_PERIOD * (moveRef.age mod HOVER_PERIOD) / (HOVER_PERIOD * HOVER_PERIOD / HOVER_VERT_OFFSETS.count)) + 1
    p = p + point(0, HOVER_VERT_OFFSETS[i])
  end if
  me.visSprite.loc = p
  shadow.paint()
  trails.paint()
end

on setState me, attrib
  state = bitOr(state, attrib)
end

on clearState me, attrib
  state = bitAnd(state, bitNot(attrib))
end

on resetState me, attrib
  state = 0
end

on hasState me, attrib
  return bitAnd(state, attrib) <> 0
end

on processCollisions me
  repeat with i = 1 to me.collisions.count
    target = me.collisions[i]
    if target = opponent then
      if not me.contactTable.hasObject(target) then
        if target.moveRef.isVulnerable() then
          damage = target.reactToCollision(moveRef.attackDamage, moveRef.stunDuration)
          notBlocked = moveRef.opponentHit()
          if notBlocked then
            me.awardPoints(damage)
          else
            me.awardPoints(0)
          end if
        end if
      end if
    end if
    me.contactTable.addObject(target)
  end repeat
  me.resetCollisions()
end

on reactToCollision me, damage, stunDuration
  if voidp(stunDuration) then
    stunDuration = g.STUN_DURATION_DEFAULT
  end if
  actualDamage = damage * (100 - naturalDefense) * (100 - moveRef.defenseRating) / 10000
  health = health - actualDamage
  if health <= 0 then
    health = 0
    me.queueDefeat(stunDuration)
  else
    if actualDamage >= g.DAMAGE_KNOCK_DOWN_THRESHOLD then
      me.queueKnockDown(stunDuration)
    else
      if currMove = g.MOVE_BLOCK then
      else
        if me.hasState(FIGHTERSTATE_ON_GROUND) then
          me.queueStun(stunDuration)
        else
          me.queueKnockDown(stunDuration)
        end if
      end if
    end if
  end if
  return actualDamage
end

on queueStun me, dur
  me.queueMove(g.MOVE_STUN, dur)
end

on queueKnockDown me, dur
  me.queueMove(g.MOVE_KNOCK_DOWN, dur)
end

on queueDefeat me, dur
  me.queueMove(g.MOVE_DEFEAT, dur)
end

on getHealthScalar me
  return float(health) / float(HEALTH_MAX)
end

on fallCheck me
  modifiedCoords = [0, 0]
  if g.game.scene.intersectsGround(me.getPos(), me.getPos() + me.getVel(), modifiedCoords) then
    me.setPosX(modifiedCoords[1])
    me.setPosY(modifiedCoords[2])
    me.setVelY(0.0)
    return 1
  else
    return 0
  end if
end

on groundCheck me, pos
  if voidp(pos) then
    return g.game.scene.onGround(me.getPos())
  else
    return g.game.scene.onGround(pos)
  end if
end

on awardPoints me, points
  g.game.awardPoints(me, points)
end
