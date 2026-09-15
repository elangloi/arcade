property KEYCODE_UP, KEYCODE_DOWN, KEYCODE_RIGHT, KEYCODE_LEFT, KEYCODE_PUNCH, KEYCODE_KICK, KEYSTATE_MOVE_UP, KEYSTATE_MOVE_DOWN, KEYSTATE_MOVE_RIGHT, KEYSTATE_MOVE_LEFT, KEYSTATE_PUNCH, KEYSTATE_KICK, KEYCOMBO_UP, KEYCOMBO_DOWN, KEYCOMBO_FORWARD, KEYCOMBO_BACKWARD, KEYCOMBO_PUNCH, KEYCOMBO_KICK, target, state, prevTimestamp, enabled, summonRobinCombo, summonRavenCombo, summonCyborgCombo, summonStarfireCombo, summonBeastboyCombo
global g

on new me, obj
  KEYCODE_UP = g.KEYCODE_UP_ARROW
  KEYCODE_DOWN = g.KEYCODE_DOWN_ARROW
  KEYCODE_RIGHT = g.KEYCODE_RIGHT_ARROW
  KEYCODE_LEFT = g.KEYCODE_LEFT_ARROW
  KEYCODE_PUNCH = g.KEYCODE_Z
  KEYCODE_KICK = g.KEYCODE_X
  KEYSTATE_MOVE_UP = 1
  KEYSTATE_MOVE_DOWN = 2
  KEYSTATE_MOVE_RIGHT = 4
  KEYSTATE_MOVE_LEFT = 8
  KEYSTATE_PUNCH = 16
  KEYSTATE_KICK = 32
  KEYCOMBO_UP = 1
  KEYCOMBO_DOWN = 2
  KEYCOMBO_FORWARD = 4
  KEYCOMBO_BACKWARD = 8
  KEYCOMBO_PUNCH = 16
  KEYCOMBO_KICK = 32
  target = obj
  state = 0
  prevTimestamp = g.frameTimestamp
  enabled = 1
  summonRobinCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_FORWARD, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_PUNCH])
  summonRavenCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_PUNCH])
  summonCyborgCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_DOWN, me.KEYCOMBO_DOWN, me.KEYCOMBO_FORWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  summonStarfireCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_FORWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_PUNCH])
  summonBeastboyCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_DOWN, me.KEYCOMBO_PUNCH])
  return me
end

on destroy me
  return VOID
end

on reset me
  state = 0
  me.resetCombos()
  enabled = 1
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

on resetCombos me
  summonRobinCombo.reset()
  summonRavenCombo.reset()
  summonCyborgCombo.reset()
  summonStarfireCombo.reset()
  summonBeastboyCombo.reset()
end

on checkCombo me
end

on updateKeys me
  if me.hasState(KEYSTATE_MOVE_UP) then
    if not keyPressed(KEYCODE_UP) then
      me.clearState(KEYSTATE_MOVE_UP)
    end if
  end if
  if me.hasState(KEYSTATE_MOVE_DOWN) then
    if not keyPressed(KEYCODE_DOWN) then
      me.clearState(KEYSTATE_MOVE_DOWN)
    end if
  end if
  if me.hasState(KEYSTATE_MOVE_RIGHT) then
    if not keyPressed(KEYCODE_RIGHT) then
      me.clearState(KEYSTATE_MOVE_RIGHT)
    end if
  end if
  if me.hasState(KEYSTATE_MOVE_LEFT) then
    if not keyPressed(KEYCODE_LEFT) then
      me.clearState(KEYSTATE_MOVE_LEFT)
    end if
  end if
  if me.hasState(KEYSTATE_PUNCH) then
    if not keyPressed(KEYCODE_PUNCH) then
      me.clearState(KEYSTATE_PUNCH)
    end if
  end if
  if me.hasState(KEYSTATE_KICK) then
    if not keyPressed(KEYCODE_KICK) then
      me.clearState(KEYSTATE_KICK)
    end if
  end if
end

on update me
end

on isEnabled me
  return enabled
end

on setEnabled me, b
  enabled = b
  if enabled then
    me.resetCombos()
  end if
end

on keyDown me, event
  case event.keyCode of
    KEYCODE_UP:
      me.setState(KEYSTATE_MOVE_UP)
      if enabled then
        me.checkCombo(event, KEYCOMBO_UP)
      end if
    KEYCODE_DOWN:
      me.setState(KEYSTATE_MOVE_DOWN)
      if enabled then
        me.checkCombo(event, KEYCOMBO_DOWN)
      end if
    KEYCODE_RIGHT:
      me.setState(KEYSTATE_MOVE_RIGHT)
      if enabled then
        if target.getDir() > 0 then
          me.checkCombo(event, KEYCOMBO_FORWARD)
        else
          me.checkCombo(event, KEYCOMBO_BACKWARD)
        end if
      end if
    KEYCODE_LEFT:
      me.setState(KEYSTATE_MOVE_LEFT)
      if enabled then
        if target.getDir() > 0 then
          me.checkCombo(event, KEYCOMBO_BACKWARD)
        else
          me.checkCombo(event, KEYCOMBO_FORWARD)
        end if
      end if
    KEYCODE_PUNCH:
      me.setState(KEYSTATE_PUNCH)
      if enabled then
        me.checkCombo(event, KEYCOMBO_PUNCH)
      end if
    KEYCODE_KICK:
      me.setState(KEYSTATE_KICK)
      if enabled then
        me.checkCombo(event, KEYCOMBO_KICK)
      end if
  end case
  prevTimestamp = event.timestamp
end

on keyUp me, event
  case event.keyCode of
    KEYCODE_UP:
      me.clearState(KEYSTATE_MOVE_UP)
    KEYCODE_DOWN:
      me.clearState(KEYSTATE_MOVE_DOWN)
    KEYCODE_RIGHT:
      me.clearState(KEYSTATE_MOVE_RIGHT)
    KEYCODE_LEFT:
      me.clearState(KEYSTATE_MOVE_LEFT)
    KEYCODE_PUNCH:
      me.clearState(KEYSTATE_PUNCH)
    KEYCODE_KICK:
      me.clearState(KEYSTATE_KICK)
  end case
end
