property ancestor, groundPunchCombo, jumpPunchCombo, shoulderBargeCombo, queuedCombo
global g

on new me, obj
  ancestor = new(g.classes.Class_KeyAdapter, obj)
  groundPunchCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_DOWN, me.KEYCOMBO_DOWN, me.KEYCOMBO_KICK])
  jumpPunchCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_DOWN, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  shoulderBargeCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_FORWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_KICK])
  queuedCombo = VOID
  return me
end

on destroy me
  ancestor.destroy()
  groundPunchCombo.destroy()
  jumpPunchCombo.destroy()
  shoulderBargeCombo.destroy()
  return VOID
end

on reset me
  ancestor.reset()
  groundPunchCombo.reset()
  jumpPunchCombo.reset()
  shoulderBargeCombo.reset()
end

on checkCombo me, event, comboKey
  delay = event.timestamp - me.prevTimestamp
  if groundPunchCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_MAMMOTH_GROUND_PUNCH
    end if
  end if
  if jumpPunchCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_MAMMOTH_JUMP_PUNCH
    end if
  end if
  if shoulderBargeCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_MAMMOTH_SHOULDER_BARGE
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
end
