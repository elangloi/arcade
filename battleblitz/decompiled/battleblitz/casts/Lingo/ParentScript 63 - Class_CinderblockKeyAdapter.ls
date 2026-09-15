property ancestor, doublePunchCombo, stompCombo, backhandCombo, queuedCombo
global g

on new me, obj
  ancestor = new(g.classes.Class_KeyAdapter, obj)
  doublePunchCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_FORWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  stompCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_DOWN, me.KEYCOMBO_KICK])
  backhandCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  queuedCombo = VOID
  return me
end

on destroy me
  ancestor.destroy()
  doublePunchCombo.destroy()
  stompCombo.destroy()
  backhandCombo.destroy()
  return VOID
end

on reset me
  ancestor.reset()
  doublePunchCombo.reset()
  stompCombo.reset()
  backhandCombo.reset()
end

on checkCombo me, event, comboKey
  delay = event.timestamp - me.prevTimestamp
  if doublePunchCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_CINDERBLOCK_DOUBLE_PUNCH
    end if
  end if
  if stompCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_CINDERBLOCK_STOMP
    end if
  end if
  if backhandCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_CINDERBLOCK_BACKHAND
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
