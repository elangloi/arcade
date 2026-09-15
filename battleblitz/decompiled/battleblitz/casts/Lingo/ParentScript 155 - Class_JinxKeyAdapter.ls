property ancestor, energySpinCombo, energyBallCombo, powerKickCombo, queuedCombo
global g

on new me, obj
  ancestor = new(g.classes.Class_KeyAdapter, obj)
  energySpinCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_KICK])
  energyBallCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_DOWN, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  powerKickCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_FORWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_KICK])
  queuedCombo = VOID
  return me
end

on destroy me
  ancestor.destroy()
  energySpinCombo.destroy()
  energyBallCombo.destroy()
  powerKickCombo.destroy()
  return VOID
end

on reset me
  ancestor.reset()
  energySpinCombo.reset()
  energyBallCombo.reset()
  powerKickCombo.reset()
end

on checkCombo me, event, comboKey
  delay = event.timestamp - me.prevTimestamp
  if energySpinCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_JINX_ENERGY_SPIN
    end if
  end if
  if energyBallCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_JINX_ENERGY_BALL
    end if
  end if
  if powerKickCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_JINX_POWER_KICK
    end if
  end if
end

on update me
  me.updateKeys()
  if not voidp(queuedCombo) then
    me.target.queueMove(queuedCombo)
    queuedCombo = VOID
  else
    if me.target.isDoingMove() then
      if me.target.currMove = g.MOVE_JUMP then
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
                me.target.queueMove(g.MOVE_STAND, 0)
              else
                if me.hasState(me.KEYSTATE_MOVE_RIGHT) then
                  if me.target.getDir() < 0 then
                    me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
                  else
                    me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
                  end if
                else
                  if me.hasState(me.KEYSTATE_MOVE_LEFT) then
                    if me.target.getDir() < 0 then
                      me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
                    else
                      me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
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
