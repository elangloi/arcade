property STATE_SEEK, STATE_BITE, ancestor, animState, initState, walkAnim, walkAttMembers, biteAnim, biteAttMembers, stateAge, shadow
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_PLASMUS_CRAB_THROW
  me.stunDuration = 10
  STATE_SEEK = 1
  STATE_BITE = 2
  initState = 1
  animState = 1
  stateAge = 0
  vis = [g.assets.PLASMUS.PLASMUS_CRAB_01, g.assets.PLASMUS.PLASMUS_CRAB_02, g.assets.PLASMUS.PLASMUS_CRAB_03]
  def = [g.assets.PLASMUS.PLASMUS_CRAB_01D, g.assets.PLASMUS.PLASMUS_CRAB_02D, g.assets.PLASMUS.PLASMUS_CRAB_03D]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  walkVisMembers = vis
  walkAttMembers = att
  walkAnim = new(g.classes.Class_LoopedAnimation, walkVisMembers)
  walkAnim.setRepeat(3)
  vis = [g.assets.PLASMUS.PLASMUS_CRAB_04, g.assets.PLASMUS.PLASMUS_CRAB_05, g.assets.PLASMUS.PLASMUS_CRAB_06]
  def = [g.assets.PLASMUS.PLASMUS_CRAB_03D, g.assets.PLASMUS.PLASMUS_CRAB_03D, g.assets.PLASMUS.PLASMUS_CRAB_03D]
  att = [g.MEMBER_0, g.assets.PLASMUS.PLASMUS_CRAB_06A, g.assets.PLASMUS.PLASMUS_CRAB_06A]
  order = [1, 1, 2, 2, 2, 3, 3, 3, 3]
  biteVisMembers = vis
  biteAttMembers = att
  biteAnim = new(g.classes.Class_IndexedAnimation, vis, order)
  me.animation = walkAnim
  me.attackMasks = walkAttMembers
  shadow = new(g.classes.Class_Shadow, me, 70)
  return me
end

on destroy me
  ancestor.destroy()
  if not voidp(shadow) then
    shadow.destroy()
  end if
  return VOID
end

on setState me, i
  initState = 1
  animState = animState + 1
  stateAge = 0
end

on advanceState me
  me.setState(animState + 1)
end

on melt me
  g.main.screen.addEffect(new(g.classes.Class_PlasmusCrabMeltEffect, me.owner, me.pos, point(0, 0), me.dir))
  me.kill()
end

on update me
  me.age = me.age + 1
  stateAge = stateAge + 1
  if me.alive then
    case animState of
      STATE_SEEK:
        if initState then
          initState = 0
        end if
        if stateAge > 180 then
          me.melt()
        else
          if stateAge > 1 then
            me.animation.advance()
          end if
          diffX = me.owner.opponent.getPosX() - me.getPosX()
          diffY = me.owner.opponent.getPosY() - me.getPosY()
          if diffX > 0.0 then
            me.setDir(1)
          else
            if diffX < 0.0 then
              me.setDir(-1)
            end if
          end if
          me.visSprite.flipH = me.dir < 0
          if (abs(diffX) < 80.0) and (abs(diffY) < 100.0) then
            me.setVel(point(0.0, 0.0))
            me.setState(STATE_BITE)
          else
            me.accelerate(point(2.0 * me.dir, 0.0))
            if abs(me.getVelX()) > 35.0 then
              me.setVelX(35.0 * me.dir)
            end if
          end if
        end if
      STATE_BITE:
        if initState then
          initState = 0
          me.animation = biteAnim
          me.attackMasks = biteAttMembers
          shadow = shadow.destroy()
          g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_CRABBITE, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if me.animation.isDone() then
          me.melt()
        else
          if stateAge > 1 then
            me.animation.advance()
          end if
        end if
    end case
    tmpPos = me.pos + (me.vel * g.gameSpeed)
    newPos = g.main.screen.scene.constrainToBounds(tmpPos.duplicate())
    if newPos <> tmpPos then
      me.melt()
      exit
    end if
    me.setPos(newPos)
    me.visSprite.member = me.animation.getMember()
    me.updateBoundingBoxes()
    if not voidp(shadow) then
      shadow.update()
    end if
  end if
end

on triggerPayoff me
  if not me.alive then
    return 0
  end if
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_STRETCHMISS, 100, g.SFX_EVENT_PRIORITY_LOW)
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_PUNCH_HIT, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 1
  end if
end

on paint me
  ancestor.paint()
  if not voidp(shadow) then
    shadow.paint()
  end if
end
