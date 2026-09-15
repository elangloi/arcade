property ancestor, energyBallCombo, boltBarrageCombo, flyingKneeCombo, queuedCombo, queuedComboArg
global g

on new me, obj
  ancestor = new(g.classes.Class_KeyAdapter, obj)
  energyBallCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_DOWN, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  boltBarrageCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_FORWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_PUNCH])
  flyingKneeCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_FORWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_KICK])
  queuedCombo = VOID
  queuedComboArg = VOID
  return me
end

on destroy me
  ancestor.destroy()
  energyBallCombo.destroy()
  boltBarrageCombo.destroy()
  flyingKneeCombo.destroy()
  return VOID
end

on reset me
  ancestor.reset()
  energyBallCombo.reset()
  boltBarrageCombo.reset()
  flyingKneeCombo.reset()
end

on checkCombo me, event, comboKey
  delay = event.timestamp - me.prevTimestamp
  if energyBallCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_STARFIRE_ENERGY_BALL
    end if
  end if
  if boltBarrageCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_STARFIRE_BOLT_BARRAGE
    end if
  end if
  if flyingKneeCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_STARFIRE_FLYING_KNEE
    end if
  end if
  if me.summonRobinCombo.checkKey(comboKey, delay) then
    if g.game.canSummon(me.target, g.FIGHTER_ID_ROBIN) then
      if not me.target.isDoingMove() then
        if me.target.opponent.isOnScreen() then
          queuedCombo = g.MOVE_SUMMON_FIGHTER
          queuedComboArg = g.FIGHTER_ID_ROBIN
        end if
      end if
    end if
  end if
  if me.summonRavenCombo.checkKey(comboKey, delay) then
    if g.game.canSummon(me.target, g.FIGHTER_ID_RAVEN) then
      if not me.target.isDoingMove() then
        if me.target.opponent.isOnScreen() then
          queuedCombo = g.MOVE_SUMMON_FIGHTER
          queuedComboArg = g.FIGHTER_ID_RAVEN
        end if
      end if
    end if
  end if
  if me.summonCyborgCombo.checkKey(comboKey, delay) then
    if g.game.canSummon(me.target, g.FIGHTER_ID_CYBORG) then
      if not me.target.isDoingMove() then
        if me.target.opponent.isOnScreen() then
          queuedCombo = g.MOVE_SUMMON_FIGHTER
          queuedComboArg = g.FIGHTER_ID_CYBORG
        end if
      end if
    end if
  end if
  if me.summonBeastboyCombo.checkKey(comboKey, delay) then
    if g.game.canSummon(me.target, g.FIGHTER_ID_BEASTBOY) then
      if not me.target.isDoingMove() then
        if me.target.opponent.isOnScreen() then
          queuedCombo = g.MOVE_SUMMON_FIGHTER
          queuedComboArg = g.FIGHTER_ID_BEASTBOY
        end if
      end if
    end if
  end if
end

on update me
  if not me.enabled then
    exit
  end if
  me.updateKeys()
  if not voidp(queuedCombo) then
    me.target.queueMove(queuedCombo, queuedComboArg)
    queuedCombo = VOID
    queuedComboArg = VOID
  else
    if me.target.isDoingMove() then
      if me.target.currMove = g.MOVE_JUMP then
        if me.hasState(me.KEYSTATE_KICK) and (me.target.getPosY() < -150) then
          me.target.queueMove(g.MOVE_STARFIRE_DIAG_JUMP_KICK, 0)
        else
          if me.hasState(me.KEYSTATE_MOVE_RIGHT) then
            if not me.target.isOnGround() then
              me.target.accelerate(point(4.0, 0.0))
              if me.target.getVelX() > g.JUMP_VELOCITY.locH then
                me.target.setVelX(g.JUMP_VELOCITY.locH)
              end if
            end if
          else
            if me.hasState(me.KEYSTATE_MOVE_LEFT) then
              if not me.target.isOnGround() then
                me.target.accelerate(point(-4.0, 0.0))
                if me.target.getVelX() < -g.JUMP_VELOCITY.locH then
                  me.target.setVelX(-g.JUMP_VELOCITY.locH)
                end if
              end if
            end if
          end if
        end if
      end if
    else
      if me.hasState(me.KEYSTATE_MOVE_DOWN) then
        me.target.queueMove(g.MOVE_BLOCK, 0)
      else
        if me.hasState(me.KEYSTATE_PUNCH) then
          me.target.queueMove(g.MOVE_PUNCH, 0)
          me.clearState(me.KEYSTATE_PUNCH)
        else
          if me.hasState(me.KEYSTATE_KICK) then
            me.target.queueMove(g.MOVE_KICK, 0)
            me.clearState(me.KEYSTATE_KICK)
          else
            if me.hasState(me.KEYSTATE_MOVE_UP) then
              if me.hasState(me.KEYSTATE_MOVE_RIGHT) then
                me.target.queueMove(g.MOVE_JUMP, 1)
              else
                if me.hasState(me.KEYSTATE_MOVE_LEFT) then
                  me.target.queueMove(g.MOVE_JUMP, -1)
                else
                  me.target.queueMove(g.MOVE_JUMP, 0)
                end if
              end if
              me.clearState(me.KEYSTATE_MOVE_UP)
            else
              if me.hasState(me.KEYSTATE_MOVE_RIGHT) and me.hasState(me.KEYSTATE_MOVE_LEFT) then
                me.target.queueMove(g.MOVE_STAND)
              else
                if me.hasState(me.KEYSTATE_MOVE_RIGHT) then
                  if me.target.getDir() < 0 then
                    me.target.queueMove(g.MOVE_WALK_BACKWARD)
                  else
                    me.target.queueMove(g.MOVE_WALK_FORWARD)
                  end if
                else
                  if me.hasState(me.KEYSTATE_MOVE_LEFT) then
                    if me.target.getDir() < 0 then
                      me.target.queueMove(g.MOVE_WALK_FORWARD)
                    else
                      me.target.queueMove(g.MOVE_WALK_BACKWARD)
                    end if
                  else
                    me.target.queueMove(g.MOVE_STAND, 0)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
