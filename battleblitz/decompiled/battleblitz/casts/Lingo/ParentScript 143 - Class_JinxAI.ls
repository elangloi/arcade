property ancestor
global g

on new me, obj
  ancestor = new(g.classes.Class_AIAdapter, obj)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on selectAttackMove me
  diff = me.opponentCurrPos - me.targetCurrPos
  choice = random(100) - 1
  if abs(diff.locH) < me.RANGE_THRESHOLD_X_SHORT then
    if me.targetAtSceneEdge then
      if choice < 25 then
        me.target.queueMove(g.MOVE_PUNCH, 0)
      else
        if choice < 50 then
          me.target.queueMove(g.MOVE_KICK, 0)
        else
          me.target.queueMove(g.MOVE_JINX_ENERGY_SPIN, 0)
        end if
      end if
    else
      if me.opponentCurrMoveID = g.MOVE_JUMP then
        if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
          if choice < 35 then
            me.target.queueMove(g.MOVE_PUNCH, 0)
          else
            if choice < 70 then
              me.target.queueMove(g.MOVE_KICK, 0)
            else
              me.target.queueMove(g.MOVE_JINX_ENERGY_SPIN, 0)
            end if
          end if
        else
          if choice < 25 then
            me.target.queueMove(g.MOVE_PUNCH, 0)
          else
            if choice < 50 then
              me.target.queueMove(g.MOVE_KICK, 0)
            else
              if choice < 75 then
                me.target.queueMove(g.MOVE_JINX_ENERGY_SPIN, 0)
              else
                me.target.queueMove(g.MOVE_JINX_POWER_KICK, 0)
              end if
            end if
          end if
        end if
      else
        if choice < 35 then
          me.target.queueMove(g.MOVE_PUNCH, 0)
        else
          if choice < 70 then
            me.target.queueMove(g.MOVE_KICK, 0)
          else
            me.target.queueMove(g.MOVE_JINX_ENERGY_SPIN, 0)
          end if
        end if
      end if
    end if
  else
    if diff.locH < me.RANGE_THRESHOLD_X_MEDIUM then
      if me.opponentCurrMoveID = g.MOVE_JUMP then
        if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
          if choice < 35 then
            me.target.queueMove(g.MOVE_PUNCH, 0)
          else
            if choice < 70 then
              me.target.queueMove(g.MOVE_KICK, 0)
            else
              me.target.queueMove(g.MOVE_JINX_ENERGY_SPIN, 0)
            end if
          end if
        else
          if choice < 50 then
            me.target.queueMove(g.MOVE_JINX_ENERGY_BALL, 0)
          else
            me.target.queueMove(g.MOVE_JINX_POWER_KICK, 0)
          end if
        end if
      else
        if choice < 50 then
          me.target.queueMove(g.MOVE_JINX_ENERGY_BALL, 0)
        else
          me.target.queueMove(g.MOVE_JINX_POWER_KICK, 0)
        end if
      end if
    else
      if me.opponentCurrMoveID = g.MOVE_JUMP then
        if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
          if choice < 50 then
            me.target.queueMove(g.MOVE_JINX_ENERGY_BALL, 0)
          else
            me.target.queueMove(g.MOVE_JINX_POWER_KICK, 0)
          end if
        else
          if choice < 50 then
            me.target.queueMove(g.MOVE_JINX_ENERGY_BALL, 0)
          else
            me.target.queueMove(g.MOVE_JINX_POWER_KICK, 0)
          end if
        end if
      else
        if choice < 50 then
          me.target.queueMove(g.MOVE_JINX_ENERGY_BALL, 0)
        else
          me.target.queueMove(g.MOVE_JINX_POWER_KICK, 0)
        end if
      end if
    end if
  end if
end

on selectPassiveMove me
  diff = me.opponentCurrPos - me.targetCurrPos
  choice = random(100) - 1
  if abs(diff.locH) < me.RANGE_THRESHOLD_X_SHORT then
    if me.targetAtSceneEdge then
      if choice < 75 then
        me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
      else
        me.target.queueMove(g.MOVE_BLOCK, 0)
      end if
    else
      if me.opponentCurrMoveID = g.MOVE_JUMP then
        if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
          if choice < 50 then
            me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
          else
            me.target.queueMove(g.MOVE_STAND, 0)
          end if
        else
          if choice < 60 then
            me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
          else
            me.target.queueMove(g.MOVE_JUMP, -me.targetCurrDir)
          end if
        end if
      else
        if choice < 25 then
          me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
        else
          if choice < 50 then
            me.target.queueMove(g.MOVE_JUMP, -me.targetCurrDir)
          else
            if choice < 75 then
              me.target.queueMove(g.MOVE_BLOCK, 0)
            else
              me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
            end if
          end if
        end if
      end if
    end if
  else
    if diff.locH < me.RANGE_THRESHOLD_X_MEDIUM then
      if me.opponentCurrMoveID = g.MOVE_JUMP then
        if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
          if choice < 50 then
            me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
          else
            if choice < 90 then
              me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
            else
              me.target.queueMove(g.MOVE_JUMP, -me.targetCurrDir)
            end if
          end if
        else
          if choice < 60 then
            me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
          else
            me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
          end if
        end if
      else
        if choice < 35 then
          me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
        else
          if choice < 50 then
            me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
          else
            if choice < 85 then
              me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
            else
              me.target.queueMove(g.MOVE_STAND, 0)
            end if
          end if
        end if
      end if
    else
      if me.opponentCurrMoveID = g.MOVE_JUMP then
        if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
          if choice < 60 then
            me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
          else
            me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
          end if
        else
          if choice < 60 then
            me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
          else
            me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
          end if
        end if
      else
        if choice < 50 then
          me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
        else
          me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
        end if
      end if
    end if
  end if
end

on evadeMeleeAttack me, dist
  choice = random(100) - 1
  if me.targetAtSceneEdge then
    if choice < 85 then
      me.target.queueMove(g.MOVE_BLOCK, 0)
    else
      me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
    end if
  else
    if choice < 70 then
      me.target.queueMove(g.MOVE_BLOCK, 0)
    else
      if choice < 100 then
        me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
      else
        if choice < 90 then
          me.target.queueMove(g.MOVE_JUMP, -me.targetCurrDir)
        else
          if choice < 95 then
            me.target.queueMove(g.MOVE_JUMP, 0)
          else
            me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
          end if
        end if
      end if
    end if
  end if
end

on evadeRangedAttack me, attPos, attVel, framesLeft
  choice = random(100) - 1
  x = me.target.getPosX()
  y = me.target.getPosY()
  diffX = attPos.locH - x
  diffY = attPos.locV - y
  if attVel.locH <> 0.0 then
    slope = attVel.locV / attVel.locH
  else
    slope = 999999.0
  end if
  if slope < 0.10000000000000001 then
    if framesLeft > 15 then
      me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
    else
      me.target.queueMove(g.MOVE_BLOCK, 0)
    end if
  else
    attackPoint = [0.0, 0.0]
    if g.util.getLineIntersection(x, y + 500.0, x, y - 500.0, attPos.locH + (attVel.locH * -10.0), attPos.locV + (attVel.locV * -10.0), attPos.locH + (attVel.locH * 10.0), attPos.locV + (attVel.locV * 10.0), attackPoint) then
      Ay = attackPoint[2]
      if Ay < (y + 10) then
        if choice < 50 then
          me.target.queueMove(g.MOVE_BLOCK, 0)
        else
          me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
        end if
      else
        if choice < 50 then
          me.target.queueMove(g.MOVE_BLOCK, 0)
        else
          if choice < 60 then
            me.target.queueMove(g.MOVE_JUMP, -me.targetCurrDir)
          else
            if choice < 80 then
              me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
            else
              me.target.queueMove(g.MOVE_JUMP, 0)
            end if
          end if
        end if
      end if
    else
      me.target.queueMove(g.MOVE_BLOCK, 0)
    end if
  end if
end

on blockAttack me
  me.target.queueMove(g.MOVE_BLOCK, 0)
end

on moveToPlayer me
  choice = random(100) - 1
  if choice < 50 then
    me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
  else
    me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
  end if
end
