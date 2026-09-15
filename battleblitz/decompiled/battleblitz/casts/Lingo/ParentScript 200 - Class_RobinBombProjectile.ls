property STATE_FLY, STATE_SKID, STATE_EXPLODE, ancestor, animState, initState, flyAnim, flyAttMembers, skidAnim, skidAttMembers, explodeAnim, explodeAttMembers, stateAge, shadow
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Projectile, owner, initPos, initVel, initDir)
  me.attackDamage = g.DAMAGE_ROBIN_BOMB_THROW
  me.stunDuration = 10
  STATE_FLY = 1
  STATE_SKID = 2
  STATE_EXPLODE = 3
  initState = 1
  animState = 1
  stateAge = 0
  vis = [g.assets.ROBIN.ROBIN_BOMB_01, g.assets.ROBIN.ROBIN_BOMB_01]
  att = [g.MEMBER_0, g.MEMBER_0]
  flyVisMembers = vis
  flyAttMembers = att
  flyAnim = new(g.classes.Class_LoopedAnimation, flyVisMembers)
  vis = [g.assets.ROBIN.ROBIN_BOMB_01, g.assets.ROBIN.ROBIN_BOMB_02, g.assets.ROBIN.FX_ROBIN_BOMB_11, g.assets.ROBIN.FX_ROBIN_BOMB_12, g.assets.ROBIN.FX_ROBIN_BOMB_13, g.assets.ROBIN.FX_ROBIN_BOMB_14]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  skidVisMembers = vis
  skidAttMembers = att
  skidAnim = new(g.classes.Class_PlayOnceAnimation, vis)
  skidAnim.setRepeat(2)
  vis = [g.assets.ROBIN.FX_ROBIN_BOMB_15, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_01, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_02, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_03, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_04, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_05, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_06, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_07, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_08, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_09, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_10, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_11, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_12]
  att = [g.MEMBER_0, g.MEMBER_0, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_02A, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_02A, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_02A, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_02A, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_02A, g.assets.ROBIN.FX_ROBIN_BOMB_EXPLODE_02A, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  explodeVisMembers = vis
  explodeAttMembers = att
  explodeAnim = new(g.classes.Class_PlayOnceAnimation, vis)
  explodeAnim.setRepeat(2)
  me.animation = flyAnim
  me.attackMasks = flyAttMembers
  shadow = new(g.classes.Class_Shadow, me, 35)
  return me
end

on destroy me
  ancestor.destroy()
  if not voidp(shadow) then
    shadow.destroy()
  end if
  return VOID
end

on advanceState
  initState = 1
  animState = animState + 1
  stateAge = 0
end

on update me
  me.age = me.age + 1
  stateAge = stateAge + 1
  if me.alive then
    case animState of
      STATE_FLY:
        if initState then
          initState = 0
          me.setVel(20.0 * me.dir, -10.0)
        end if
        me.accelerate(g.gravity)
        if stateAge > 1 then
          me.animation.advance()
        end if
        if (me.getPosY() + me.getVelY()) >= 0.0 then
          me.setPosY(0.0)
          me.setVelY(0.0)
          advanceState()
        end if
      STATE_SKID:
        if initState then
          initState = 0
          me.animation = skidAnim
          me.attackMasks = explodeAttMembers
        end if
        if stateAge > 1 then
          me.animation.advance()
        end if
        me.setVel(me.getVelX() * 0.5)
        if me.animation.isDone() then
          me.setVel(0.0, 0.0)
          advanceState()
        end if
      STATE_EXPLODE:
        if initState then
          initState = 0
          me.animation = explodeAnim
          me.attackMasks = explodeAttMembers
          g.main.screen.addEffect(new(g.classes.Class_RobinBombColumnEffect, me.owner, me.pos, point(0, 0), me.dir))
          shadow = shadow.destroy()
          g.main.audioMgr.playSound(g.assets.ROBIN.SFX_ROBIN_BOMB_EXPLODE, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if me.animation.isDone() then
          me.kill()
        else
          if stateAge > 1 then
            me.animation.advance()
          end if
        end if
    end case
    me.setPos(me.pos + me.vel)
    me.visSprite.member = me.animation.getMember()
    me.updateBoundingBoxes()
    if me.isOutOfPlay() then
      me.kill()
    end if
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
    g.main.audioMgr.playSound(g.assets.AUDIO.sfx_blocked_attack, 100, g.SFX_EVENT_PRIORITY_LOW)
    return 0
  else
    return 1
  end if
end

on paint me
  ancestor.paint()
  if not voidp(shadow) then
    shadow.paint()
  end if
end
