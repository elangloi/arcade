property listeners, monitorList, keyStates
global g

on new me
  monitorList = [g.KEYCODE_A, g.KEYCODE_S, g.KEYCODE_D, g.KEYCODE_F, g.KEYCODE_H, g.KEYCODE_G, g.KEYCODE_Z, g.KEYCODE_X, g.KEYCODE_C, g.KEYCODE_V, g.KEYCODE_B, g.KEYCODE_Q, g.KEYCODE_W, g.KEYCODE_E, g.KEYCODE_R, g.KEYCODE_Y, g.KEYCODE_T, g.KEYCODE_1, g.KEYCODE_2, g.KEYCODE_3, g.KEYCODE_4, g.KEYCODE_6, g.KEYCODE_5, g.KEYCODE_9, g.KEYCODE_7, g.KEYCODE_8, g.KEYCODE_ZERO, g.KEYCODE_O, g.KEYCODE_U, g.KEYCODE_I, g.KEYCODE_P, g.KEYCODE_L, g.KEYCODE_J, g.KEYCODE_K, g.KEYCODE_N, g.KEYCODE_M, g.KEYCODE_SPACEBAR, g.KEYCODE_ESC, g.KEYCODE_LEFT_ARROW, g.KEYCODE_RIGHT_ARROW, g.KEYCODE_DOWN_ARROW, g.KEYCODE_UP_ARROW]
  keyStates = g.util.newArray(256, 0)
  listeners = []
  return me
end

on destroy me
  return VOID
end

on checkKey code
  if keyPressed(code) then
    if not keyStates[code + 1] then
      keyStates[code + 1] = 1
      sendKeyDownEvent(code)
    end if
  else
    if keyStates[code + 1] then
      keyStates[code + 1] = 0
      sendKeyUpEvent(code)
    end if
  end if
end

on sendKeyDownEvent code
  event = [#keyCode: code, #timestamp: the milliSeconds]
  repeat with o in listeners
    o.keyDown(event)
  end repeat
end

on sendKeyUpEvent code
  event = [#keyCode: code, #timestamp: the milliSeconds]
  repeat with o in listeners
    o.keyUp(event)
  end repeat
end

on update me
  repeat with code in monitorList
    checkKey(code)
  end repeat
end

on addListener me, obj
  if listeners.getPos(obj) then
    exit
  end if
  listeners.append(obj)
end

on removeListener me, obj
  i = listeners.getPos(obj)
  if i then
    listeners.deleteAt(i)
  end if
end

on resetListeners me
  listeners = []
end

on resetStates me
  repeat with i = 1 to keyStates.count
    keyStates[i] = 0
  end repeat
end
