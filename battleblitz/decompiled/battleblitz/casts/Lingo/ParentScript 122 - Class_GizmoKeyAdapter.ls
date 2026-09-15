property ancestor, cannonCombo, missileCombo, highMissileCombo, queuedCombo
global g

on new me, obj
  ancestor = new(g.classes.Class_KeyAdapter, obj)
  cannonCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_DOWN, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  missileCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_PUNCH])
  highMissileCombo = new(g.classes.Class_KeyCombo, [me.KEYCOMBO_BACKWARD, me.KEYCOMBO_FORWARD, me.KEYCOMBO_BACKWARD, me.KEYCOMBO_PUNCH])
  queuedCombo = VOID
  return me
end

on destroy me
  ancestor.destroy()
  cannonCombo.destroy()
  missileCombo.destroy()
  highMissileCombo.destroy()
  return VOID
end

on reset me
  ancestor.reset()
  cannonCombo.reset()
  missileCombo.reset()
  highMissileCombo.reset()
end

on checkCombo me, event, comboKey
  delay = event.timestamp - me.prevTimestamp
  if cannonCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      if me.target.isOnGround() then
        queuedCombo = g.MOVE_GIZMO_CANNON
      else
        queuedCombo = g.MOVE_GIZMO_AIR_CANNON
      end if
    end if
  end if
  if highMissileCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      if not me.target.isOnGround() then
        queuedCombo = g.MOVE_GIZMO_HIGH_AIR_MISSILE
      end if
    end if
  end if
  if missileCombo.checkKey(comboKey, delay) then
    if not me.target.isDoingMove() then
      if not me.target.isOnGround() then
        queuedCombo = g.MOVE_GIZMO_AIR_MISSILE
      end if
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
      if (me.target.currMove = g.MOVE_JUMP) or (me.target.currMove = g.MOVE_GIZMO_AIR_JUMP) then
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
      if me.target.isOnGround() then
        if me.hasState(me.KEYSTATE_MOVE_DOWN) then
          me.target.queueMove(g.MOVE_BLOCK)
        else
          if me.hasState(me.KEYSTATE_PUNCH) then
            me.target.queueMove(g.MOVE_PUNCH, 0)
            me.clearState(me.KEYSTATE_PUNCH)
          else
            if me.hasState(me.KEYSTATE_KICK) then
              if me.target.getPosY() = 0 then
                me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
                me.clearState(me.KEYSTATE_KICK)
              else
                me.target.moveBy(0, 2)
                me.target.queueMove(g.MOVE_FALL, 0)
                me.clearState(me.KEYSTATE_KICK)
              end if
            else
              if me.hasState(me.KEYSTATE_MOVE_UP) then
                me.target.queueMove(g.MOVE_JUMP)
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
                      me.target.queueMove(g.MOVE_STAND)
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      else
        if me.hasState(me.KEYSTATE_MOVE_DOWN) then
          me.target.queueMove(g.MOVE_GIZMO_AIR_BLOCK, 0)
        else
          if me.hasState(me.KEYSTATE_PUNCH) then
            me.target.queueMove(g.MOVE_GIZMO_AIR_PUNCH, 0)
            me.clearState(me.KEYSTATE_PUNCH)
          else
            if me.hasState(me.KEYSTATE_KICK) then
              me.target.queueMove(g.MOVE_GIZMO_LAND, 0)
              me.clearState(me.KEYSTATE_KICK)
            else
              if me.hasState(me.KEYSTATE_MOVE_UP) then
                if me.hasState(me.KEYSTATE_MOVE_RIGHT) then
                  me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, 1)
                else
                  if me.hasState(me.KEYSTATE_MOVE_LEFT) then
                    me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, -1)
                  else
                    me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, 0)
                  end if
                end if
              else
                if me.hasState(me.KEYSTATE_MOVE_RIGHT) and me.hasState(me.KEYSTATE_MOVE_LEFT) then
                  me.target.queueMove(g.MOVE_GIZMO_HOVER)
                else
                  if me.hasState(me.KEYSTATE_MOVE_RIGHT) then
                    if me.target.getDir() < 0 then
                      me.target.queueMove(g.MOVE_GIZMO_FLY_BACKWARD)
                    else
                      me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD)
                    end if
                  else
                    if me.hasState(me.KEYSTATE_MOVE_LEFT) then
                      if me.target.getDir() < 0 then
                        me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD)
                      else
                        me.target.queueMove(g.MOVE_GIZMO_FLY_BACKWARD)
                      end if
                    else
                      me.target.queueMove(g.MOVE_GIZMO_HOVER)
                    end if
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
