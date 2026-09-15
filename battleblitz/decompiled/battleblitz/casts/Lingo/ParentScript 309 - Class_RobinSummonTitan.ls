property ancestor, STATE_LEADIN, STATE_ATTACK, STATE_FINISH, moveState, initState, stateAge, summonEffect, summonedFighterID
global g

on new me, obj
  ancestor = new(g.classes.Class_Move, obj)
  me.setAttack(0)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.ROBIN.ROBIN_THROW_01, g.assets.ROBIN.ROBIN_THROW_02, g.assets.ROBIN.ROBIN_THROW_09, g.assets.ROBIN.ROBIN_STANDUP_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.ROBIN.ROBIN_THROW_01D, g.assets.ROBIN.ROBIN_THROW_02D, g.assets.ROBIN.ROBIN_THROW_02D, g.assets.ROBIN.ROBIN_STANDUP_01D]
  order = [1, 2, 3, 4]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LEADIN = 1
  STATE_ATTACK = 2
  STATE_FINISH = 3
  moveState = 1
  initState = 1
  stateAge = 0
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  stateAge = 0
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
  summonedFighterID = arg
end

on setState me, i
  initState = 1
  moveState = i
  stateAge = 0
end

on advanceState me
  me.setState(moveState + 1)
end

on update me
  me.age = me.age + 1
  stateAge = stateAge + 1
  if not me.moveDone then
    case moveState of
      STATE_LEADIN:
        if initState then
          initState = 0
        end if
        if stateAge = 5 then
          me.animation.advance()
        else
          if stateAge >= 8 then
            me.advanceState()
          end if
        end if
      STATE_ATTACK:
        if initState then
          initState = 0
          me.animation.advance()
          g.game.addEffect(new(g.classes.Class_RobinSummonEffect, me.owner, me.owner.pos + point(120.0 * me.owner.dir, -105.0), point(0, 0), me.owner.dir))
          summonEffect = g.game.summonTitan(me.owner, summonedFighterID)
          me.owner.opponent.setFrozen(1)
          g.game.freezeProjectiles(me.owner.opponent, 1)
          g.game.freezeEffects(me.owner.opponent, 1)
        end if
        if not summonEffect.isAlive() then
          summonEffect = VOID
          me.owner.opponent.setFrozen(0)
          g.game.freezeProjectiles(me.owner.opponent, 0)
          g.game.freezeEffects(me.owner.opponent, 0)
          me.advanceState()
        end if
      STATE_FINISH:
        if initState then
          me.animation.advance()
          initState = 0
        end if
        if stateAge = 4 then
          me.animation.advance()
        else
          if stateAge >= 8 then
            me.moveDone = 1
          end if
        end if
    end case
  end if
end
