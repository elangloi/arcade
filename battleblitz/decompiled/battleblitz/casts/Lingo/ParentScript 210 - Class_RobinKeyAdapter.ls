property ancestor, discThrowCombo, flyingKickCombo, diagJumpKickCombo, bombThrowCombo, queuedCombo, queuedComboArg
global g

on new me, obj
  ancestor = new(g.classes.Class_KeyAdapter, obj)
  discThrowCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_DOWN, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  flyingKickCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_FORWARD])
  bombThrowCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_FORWARD, me.KEYCOMBO_KICK])
  queuedCombo = VOID
  return me
end

on destroy me
  ancestor.destroy()
  discThrowCombo.destroy()
  flyingKickCombo.destroy()
  bombThrowCombo.destroy()
  return VOID
end

on reset me
  ancestor.reset()
  discThrowCombo.reset()
  flyingKickCombo.reset()
  bombThrowCombo.reset()
end

on checkCombo me, event, comboKey
  delay = event.timestamp - me.prevTimestamp
  if discThrowCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_ROBIN_DISC_THROW
    end if
  end if
  if flyingKickCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_ROBIN_FLYING_KICK
    end if
  end if
  if bombThrowCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_ROBIN_BOMB_THROW
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
  if me.summonStarfireCombo.checkKey(comboKey, delay) then
    if g.game.canSummon(me.target, g.FIGHTER_ID_STARFIRE) then
      if not me.target.isDoingMove() then
        if me.target.opponent.isOnScreen() then
          queuedCombo = g.MOVE_SUMMON_FIGHTER
          queuedComboArg = g.FIGHTER_ID_STARFIRE
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
  else
    if me.target.isDoingMove() then
      if me.target.currMove = g.MOVE_JUMP then
        if me.hasState(me.KEYSTATE_KICK) and (me.target.getPosY() < -200) then
          me.target.queueMove(g.MOVE_ROBIN_DIAG_JUMP_KICK, 0)
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
