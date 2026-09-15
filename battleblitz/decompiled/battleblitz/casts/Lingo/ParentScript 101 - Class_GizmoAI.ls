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

on serviceCurrentMove me
  case me.targetCurrMoveID of
    g.MOVE_GIZMO_AIR_BLOCK:
      if me.opponentMove.hasHitOpponent() or (me.opponentCurrMoveNum <> me.opponentPrevMoveNum) then
        me.resetDelays()
      end if
    g.MOVE_GIZMO_FLY_BACKWARD:
      if me.targetAtSceneEdge or me.targetAtScreenEdge then
        me.zeroDelays()
      end if
    g.MOVE_GIZMO_FLY_FORWARD:
      if abs(me.opponentCurrPos.locH - me.targetCurrPos.locH) <= me.RANGE_THRESHOLD_X_SHORT then
        me.zeroDelays()
      end if
  end case
end

on selectAttackMove me
  diff = me.opponentCurrPos - me.targetCurrPos
  choice = random(100) - 1
  if me.target.isFlying() then
    if abs(diff.locH) < me.RANGE_THRESHOLD_X_SHORT then
      if me.targetAtSceneEdge then
        if choice < 100 then
          me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
        end if
      else
        if me.opponentCurrMoveID = g.MOVE_JUMP then
          if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
            if choice < 100 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
            end if
          else
            if choice < 100 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
            end if
          end if
        else
          if choice < 100 then
            me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
          end if
        end if
      end if
    else
      if diff.locH < me.RANGE_THRESHOLD_X_MEDIUM then
        if me.opponentCurrMoveID = g.MOVE_JUMP then
          if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_AIR_MISSILE, 0)
            end if
          else
            if choice < 15 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
            else
              if choice < 45 then
                me.target.queueMove(g.MOVE_GIZMO_AIR_MISSILE, 0)
              else
                me.target.queueMove(g.MOVE_GIZMO_HIGH_AIR_MISSILE, 0)
              end if
            end if
          end if
        else
          if choice < 20 then
            me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
          else
            if choice < 60 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_MISSILE, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_HIGH_AIR_MISSILE, 0)
            end if
          end if
        end if
      else
        if me.opponentCurrMoveID = g.MOVE_JUMP then
          if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
            if choice < 20 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
            else
              if choice < 60 then
                me.target.queueMove(g.MOVE_GIZMO_AIR_MISSILE, 0)
              else
                me.target.queueMove(g.MOVE_GIZMO_HIGH_AIR_MISSILE, 0)
              end if
            end if
          else
            if choice < 40 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_HIGH_AIR_MISSILE, 0)
            end if
          end if
        else
          if choice < 40 then
            me.target.queueMove(g.MOVE_GIZMO_AIR_CANNON, 0)
          else
            me.target.queueMove(g.MOVE_GIZMO_HIGH_AIR_MISSILE, 0)
          end if
        end if
      end if
    end if
  else
    if abs(diff.locH) < me.RANGE_THRESHOLD_X_SHORT then
      if me.targetAtSceneEdge then
        if choice < 100 then
          me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
        end if
      else
        if me.opponentCurrMoveID = g.MOVE_JUMP then
          if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
            end if
          else
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
            end if
          end if
        else
          if choice < 50 then
            me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
          else
            me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
          end if
        end if
      end if
    else
      if diff.locH < me.RANGE_THRESHOLD_X_MEDIUM then
        if me.opponentCurrMoveID = g.MOVE_JUMP then
          if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
            end if
          else
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
            end if
          end if
        else
          if choice < 50 then
            me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
          else
            me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
          end if
        end if
      else
        if me.opponentCurrMoveID = g.MOVE_JUMP then
          if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
            end if
          else
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
            end if
          end if
        else
          if choice < 50 then
            me.target.queueMove(g.MOVE_GIZMO_CANNON, 0)
          else
            me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
          end if
        end if
      end if
    end if
  end if
end

on selectPassiveMove me
  diff = me.opponentCurrPos - me.targetCurrPos
  choice = random(100) - 1
  if me.target.isFlying() then
    if abs(diff.locH) < me.RANGE_THRESHOLD_X_SHORT then
      if me.targetAtSceneEdge then
        if choice < 75 then
          me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.targetCurrDir)
        else
          me.target.queueMove(g.MOVE_GIZMO_AIR_BLOCK, 0)
        end if
      else
        if me.opponentCurrMoveID = g.MOVE_JUMP then
          if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_HOVER, 0)
            end if
          else
            if choice < 60 then
              me.target.queueMove(g.MOVE_GIZMO_FLY_BACKWARD, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, -me.targetCurrDir)
            end if
          end if
        else
          if choice < 25 then
            me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.targetCurrDir)
          else
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, -me.targetCurrDir)
            else
              if choice < 75 then
                me.target.queueMove(g.MOVE_GIZMO_AIR_BLOCK, 0)
              else
                me.target.queueMove(g.MOVE_GIZMO_FLY_BACKWARD, 0)
              end if
            end if
          end if
        end if
      end if
    else
      if diff.locH < me.RANGE_THRESHOLD_X_MEDIUM then
        if me.opponentCurrMoveID = g.MOVE_JUMP then
          if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
            if choice < 40 then
              me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD, 0)
            else
              if choice < 80 then
                me.target.queueMove(g.MOVE_GIZMO_FLY_BACKWARD, 0)
              else
                if choice < 90 then
                  me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, -me.targetCurrDir)
                else
                  me.target.queueMove(g.MOVE_GIZMO_LAND, 0)
                end if
              end if
            end if
          else
            if choice < 60 then
              me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.targetCurrDir)
            end if
          end if
        else
          if choice < 35 then
            me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD, 0)
          else
            if choice < 50 then
              me.target.queueMove(g.MOVE_GIZMO_FLY_BACKWARD, 0)
            else
              if choice < 80 then
                me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.targetCurrDir)
              else
                if choice < 90 then
                  me.target.queueMove(g.MOVE_GIZMO_HOVER, 0)
                else
                  me.target.queueMove(g.MOVE_GIZMO_LAND, 0)
                end if
              end if
            end if
          end if
        end if
      else
        if me.opponentCurrMoveID = g.MOVE_JUMP then
          if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
            if choice < 60 then
              me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.targetCurrDir)
            end if
          else
            if choice < 60 then
              me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.targetCurrDir)
            end if
          end if
        else
          if choice < 50 then
            me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD, 0)
          else
            me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.targetCurrDir)
          end if
        end if
      end if
    end if
  else
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
          if choice < 50 then
            me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
          else
            if choice < 75 then
              me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
            else
              if choice < 95 then
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
            if choice < 100 then
              me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
            end if
          else
            if choice < 100 then
              me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
            end if
          end if
        else
          if choice < 100 then
            me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
          end if
        end if
      end if
    end if
  end if
end

on evadeMeleeAttack me, dist
  choice = random(100) - 1
  if me.targetAtSceneEdge then
    if me.target.isFlying() then
      if choice < 70 then
        me.target.queueMove(g.MOVE_GIZMO_AIR_BLOCK, 0)
      else
        me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.target.getDir())
      end if
    else
      if choice < 70 then
        me.target.queueMove(g.MOVE_BLOCK, 0)
      else
        me.target.queueMove(g.MOVE_JUMP, me.target.getDir())
      end if
    end if
  else
    if me.target.isFlying() then
      if choice < 60 then
        me.target.queueMove(g.MOVE_GIZMO_AIR_BLOCK, 0)
      else
        if choice < 70 then
          me.target.queueMove(g.MOVE_GIZMO_FLY_BACKWARD, 0)
        else
          if choice < 80 then
            me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, -me.target.getDir())
          else
            if choice < 90 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, 0)
            else
              me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.target.getDir())
            end if
          end if
        end if
      end if
    else
      if choice < 60 then
        me.target.queueMove(g.MOVE_BLOCK, 0)
      else
        if choice < 70 then
          me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
        else
          if choice < 90 then
            me.target.queueMove(g.MOVE_JUMP, -me.target.getDir())
          else
            if choice < 90 then
              me.target.queueMove(g.MOVE_JUMP, 0)
            else
              me.target.queueMove(g.MOVE_JUMP, me.target.getDir())
            end if
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
    if me.target.isFlying() then
      if framesLeft > 15 then
        me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.targetCurrDir)
      else
        me.target.queueMove(g.MOVE_GIZMO_AIR_BLOCK, 0)
      end if
    else
      if framesLeft > 15 then
        me.target.queueMove(g.MOVE_JUMP, me.targetCurrDir)
      else
        me.target.queueMove(g.MOVE_BLOCK, 0)
      end if
    end if
  else
    attackPoint = [0.0, 0.0]
    b = g.util.getLineIntersection(x, y + 500.0, x, y - 500.0, attPos.locH + (attVel.locH * -10.0), attPos.locV + (attVel.locV * -10.0), attPos.locH + (attVel.locH * 10.0), attPos.locV + (attVel.locV * 10.0), attackPoint)
    if b then
      Ay = attackPoint[2]
      if Ay < (y + 10) then
        if me.target.isFlying() then
          if choice < 50 then
            me.target.queueMove(g.MOVE_GIZMO_AIR_BLOCK, 0)
          else
            me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD, 0)
          end if
        else
          if choice < 50 then
            me.target.queueMove(g.MOVE_BLOCK, 0)
          else
            me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
          end if
        end if
      else
        if me.target.isFlying() then
          if choice < 50 then
            me.target.queueMove(g.MOVE_GIZMO_AIR_BLOCK, 0)
          else
            if choice < 60 then
              me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, -me.targetCurrDir)
            else
              if choice < 80 then
                me.target.queueMove(g.MOVE_GIZMO_FLY_BACKWARD, 0)
              else
                me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, 0)
              end if
            end if
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
      end if
    else
      me.blockAttack()
    end if
  end if
end

on blockAttack me
  if me.target.isFlying() then
    if me.targetAtScreenEdge or me.targetAtSceneEdge then
      me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.targetCurrDir)
    else
      me.target.queueMove(g.MOVE_GIZMO_FLY_BACKWARD, 0)
    end if
  else
    me.target.queueMove(g.MOVE_BLOCK, 0)
  end if
end

on moveToPlayer me
  choice = random(100) - 1
  if me.target.isFlying() then
    if choice < 50 then
      me.target.queueMove(g.MOVE_GIZMO_FLY_FORWARD, 0)
    else
      me.target.queueMove(g.MOVE_GIZMO_AIR_JUMP, me.target.getDir())
    end if
  else
    if choice < 70 then
      me.target.queueMove(g.MOVE_GIZMO_TAKE_OFF, 0)
    else
      if choice < 50 then
        me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
      else
        me.target.queueMove(g.MOVE_JUMP, me.target.getDir())
      end if
    end if
  end if
end
