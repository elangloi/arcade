property ancestor
global g

on new me, obj
  ancestor = new(g.classes.Class_AIAdapter, obj)
  case g.difficulty of
    g.DIFFICULTY_BEGINNER:
      me.AGGRESSION_PERCENT_NORMAL = 30
      me.AGGRESSION_PERCENT_ENRAGED = 50
    g.DIFFICULTY_INTERMEDIATE:
      me.AGGRESSION_PERCENT_NORMAL = 45
      me.AGGRESSION_PERCENT_ENRAGED = 65
    g.DIFFICULTY_EXPERT:
      me.AGGRESSION_PERCENT_NORMAL = 70
      me.AGGRESSION_PERCENT_ENRAGED = 80
  end case
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
          if choice < 75 then
            me.target.queueMove(g.MOVE_CINDERBLOCK_DOUBLE_PUNCH, 0)
          else
            me.target.queueMove(g.MOVE_CINDERBLOCK_BACKHAND, 0)
          end if
        end if
      end if
    else
      if me.opponentCurrMoveID = g.MOVE_JUMP then
        if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
          if choice < 25 then
            me.target.queueMove(g.MOVE_PUNCH, 0)
          else
            if choice < 50 then
              me.target.queueMove(g.MOVE_KICK, 0)
            else
              if choice < 75 then
                me.target.queueMove(g.MOVE_CINDERBLOCK_DOUBLE_PUNCH, 0)
              else
                me.target.queueMove(g.MOVE_CINDERBLOCK_BACKHAND, 0)
              end if
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
                me.target.queueMove(g.MOVE_CINDERBLOCK_STOMP, 0)
              else
                me.target.queueMove(g.MOVE_CINDERBLOCK_BACKHAND, 0)
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
            if choice < 70 then
              me.target.queueMove(g.MOVE_CINDERBLOCK_DOUBLE_PUNCH, 0)
            else
              me.target.queueMove(g.MOVE_CINDERBLOCK_BACKHAND, 0)
            end if
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
              me.target.queueMove(g.MOVE_CINDERBLOCK_BACKHAND, 0)
            end if
          end if
        else
          if choice < 100 then
            me.target.queueMove(g.MOVE_CINDERBLOCK_STOMP, 0)
          end if
        end if
      else
        if choice < 50 then
          me.target.queueMove(g.MOVE_CINDERBLOCK_BACKHAND, 0)
        else
          me.target.queueMove(g.MOVE_CINDERBLOCK_STOMP, 0)
        end if
      end if
    else
      if me.opponentCurrMoveID = g.MOVE_JUMP then
        if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
          if choice < 100 then
            me.target.queueMove(g.MOVE_CINDERBLOCK_STOMP, 0)
          end if
        else
          if choice < 100 then
            me.target.queueMove(g.MOVE_CINDERBLOCK_STOMP, 0)
          end if
        end if
      else
        if choice < 100 then
          me.target.queueMove(g.MOVE_CINDERBLOCK_STOMP, 0)
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
      if choice < 100 then
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
          if choice < 100 then
            me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
          end if
        end if
      else
        if choice < 50 then
          me.target.queueMove(g.MOVE_BLOCK, 0)
        else
          me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
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
            me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
          end if
        else
          if choice < 100 then
            me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
          end if
        end if
      else
        if choice < 50 then
          me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
        else
          if choice < 75 then
            me.target.queueMove(g.MOVE_WALK_BACKWARD, 0)
          else
            me.target.queueMove(g.MOVE_STAND, 0)
          end if
        end if
      end if
    else
      if me.opponentCurrMoveID = g.MOVE_JUMP then
        if (me.opponentCurrVel.locH * me.opponentCurrDir) >= 0.0 then
          if choice < 100 then
            me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
          end if
        else
          if choice < 100 then
            me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
          end if
        end if
      else
        if choice < 100 then
          me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
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
      me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
    end if
  else
    if choice < 85 then
      me.target.queueMove(g.MOVE_BLOCK, 0)
    else
      me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
    end if
  end if
end

on evadeRangedAttack me, attPos, attVel, framesLeft
  me.target.queueMove(g.MOVE_BLOCK, 0)
end

on blockAttack me
  me.target.queueMove(g.MOVE_BLOCK, 0)
end

on moveToPlayer me
  choice = random(100) - 1
  if choice < 100 then
    me.target.queueMove(g.MOVE_WALK_FORWARD, 0)
  end if
end
