property ancestor, armSwipeCombo, chestBlastCombo, crabThrowCombo, sludgeThrowCombo, queuedCombo
global g

on new me, obj
  ancestor = new(g.classes.Class_KeyAdapter, obj)
  armSwipeCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_DOWN, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  chestBlastCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_FORWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_KICK])
  crabThrowCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_PUNCH])
  sludgeThrowCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  queuedCombo = VOID
  return me
end

on destroy me
  ancestor.destroy()
  armSwipeCombo.destroy()
  chestBlastCombo.destroy()
  crabThrowCombo.destroy()
  sludgeThrowCombo.destroy()
  return VOID
end

on reset me
  ancestor.reset()
  armSwipeCombo.reset()
  chestBlastCombo.reset()
  crabThrowCombo.reset()
  sludgeThrowCombo.reset()
end

on checkCombo me, event, comboKey
  delay = event.timestamp - me.prevTimestamp
  if armSwipeCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_PLASMUS_ARM_SWIPE
    end if
  end if
  if chestBlastCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_PLASMUS_CHEST_BLAST
    end if
  end if
  if crabThrowCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_PLASMUS_CRAB_THROW
    end if
  end if
  if sludgeThrowCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      queuedCombo = g.MOVE_PLASMUS_SLUDGE_THROW
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
          else
            if me.hasState(me.KEYSTATE_MOVE_UP) then
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
