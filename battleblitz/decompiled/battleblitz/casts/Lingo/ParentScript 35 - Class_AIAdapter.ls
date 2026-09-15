property CHOICE_DELAY_INITIAL_MIN, CHOICE_DELAY_INITIAL_MAX, CHOICE_DELAY_NORMAL_MIN, CHOICE_DELAY_NORMAL_MAX, CHOICE_DELAY_ENRAGED_MIN, CHOICE_DELAY_ENRAGED_MAX, CHOICE_DELAY_REBOUND_MIN, CHOICE_DELAY_REBOUND_MAX, EVASIVE_MOVE_DURATION, ASSESSMENT_DELAY_DEFAULT, LOOK_AHEAD_FRAMES, AWARENESS_PERCENT, OPPORTUNITY_PERCENT, COUNTER_ATTACK_PERCENT, AGGRESSION_PERCENT_NORMAL, AGGRESSION_PERCENT_ENRAGED, RANGE_THRESHOLD_X_SHORT, RANGE_THRESHOLD_X_MEDIUM, target, targetCurrMoveID, targetCurrDir, targetCurrPos, targetCurrVel, targetCurrBusy, targetPrevMoveID, targetPrevDir, targetPrevPos, targetPrevVel, targetPrevBusy, targetAtSceneEdge, targetAtScreenEdge, targetMove, opponentCurrPos, opponentCurrVel, opponentCurrMoveID, opponentCurrMoveNum, opponentPrevMoveNum, opponentCurrDir, opponentMove, lastChoiceAt, lastAssessmentAt, lastAssessmentMoveNum, assessmentDelay, choiceDelay, enabled
global g

on new me, obj
  target = obj
  RANGE_THRESHOLD_X_SHORT = 100
  RANGE_THRESHOLD_X_MEDIUM = 350
  LOOK_AHEAD_FRAMES = 20
  case g.difficulty of
    g.DIFFICULTY_BEGINNER:
      me.CHOICE_DELAY_INITIAL_MIN = 30
      me.CHOICE_DELAY_INITIAL_MAX = 45
      me.CHOICE_DELAY_NORMAL_MIN = 30
      me.CHOICE_DELAY_NORMAL_MAX = 90
      me.CHOICE_DELAY_ENRAGED_MIN = 20
      me.CHOICE_DELAY_ENRAGED_MAX = 40
      me.CHOICE_DELAY_REBOUND_MIN = 25
      me.CHOICE_DELAY_REBOUND_MAX = 45
      me.EVASIVE_MOVE_DURATION = 30
      me.AWARENESS_PERCENT = 10
      me.COUNTER_ATTACK_PERCENT = 20
      me.ASSESSMENT_DELAY_DEFAULT = 10
      me.AGGRESSION_PERCENT_NORMAL = 20
      me.AGGRESSION_PERCENT_ENRAGED = 40
    g.DIFFICULTY_INTERMEDIATE:
      me.CHOICE_DELAY_INITIAL_MIN = 15
      me.CHOICE_DELAY_INITIAL_MAX = 45
      me.CHOICE_DELAY_NORMAL_MIN = 20
      me.CHOICE_DELAY_NORMAL_MAX = 60
      me.CHOICE_DELAY_ENRAGED_MIN = 10
      me.CHOICE_DELAY_ENRAGED_MAX = 40
      me.CHOICE_DELAY_REBOUND_MIN = 15
      me.CHOICE_DELAY_REBOUND_MAX = 30
      me.EVASIVE_MOVE_DURATION = 20
      me.AWARENESS_PERCENT = 50
      me.COUNTER_ATTACK_PERCENT = 20
      me.ASSESSMENT_DELAY_DEFAULT = 10
      me.AGGRESSION_PERCENT_NORMAL = 40
      me.AGGRESSION_PERCENT_ENRAGED = 60
    g.DIFFICULTY_EXPERT:
      me.CHOICE_DELAY_INITIAL_MIN = 5
      me.CHOICE_DELAY_INITIAL_MAX = 45
      me.CHOICE_DELAY_NORMAL_MIN = 10
      me.CHOICE_DELAY_NORMAL_MAX = 30
      me.CHOICE_DELAY_ENRAGED_MIN = 5
      me.CHOICE_DELAY_ENRAGED_MAX = 20
      me.CHOICE_DELAY_REBOUND_MIN = 0
      me.CHOICE_DELAY_REBOUND_MAX = 10
      me.EVASIVE_MOVE_DURATION = 15
      me.AWARENESS_PERCENT = 90
      me.COUNTER_ATTACK_PERCENT = 20
      me.ASSESSMENT_DELAY_DEFAULT = 5
      me.AGGRESSION_PERCENT_NORMAL = 60
      me.AGGRESSION_PERCENT_ENRAGED = 80
  end case
  targetCurrMoveID = 0
  targetCurrDir = 0
  targetCurrPos = point(0, 0)
  targetCurrVel = point(0, 0)
  targetCurrBusy = 0
  targetPrevMoveID = 0
  targetPrevDir = 0
  targetPrevPos = point(0, 0)
  targetPrevVel = point(0, 0)
  targetPrevBusy = 0
  opponentCurrPos = point(0, 0)
  opponentCurrVel = point(0, 0)
  opponentCurrMoveID = 0
  opponentCurrMoveNum = 0
  opponentPrevMoveNum = 0
  opponentCurrDir = 0
  choiceDelay = CHOICE_DELAY_INITIAL_MAX
  assessmentDelay = 0
  lastChoiceAt = 0
  lastAssessmentAt = 0
  lastAssessmentMoveNum = 0
  enabled = 1
  return me
end

on destroy me
  return VOID
end

on reset me
  choiceDelay = random(CHOICE_DELAY_INITIAL_MAX - CHOICE_DELAY_INITIAL_MIN) + CHOICE_DELAY_INITIAL_MIN
  assessmentDelay = ASSESSMENT_DELAY_DEFAULT
  lastChoiceAt = g.frameCount
  lastAssessmentAt = g.frameCount
  enabled = 1
end

on serviceCurrentMove me
end

on selectAttackMove me
end

on selectPassiveMove me
end

on evadeMeleeAttack me
end

on evadeRangedAttack me, attPos, attVel, framesLeft
end

on blockAttack me
end

on counterAttack me, attPos, attVel, framesLeft
end

on moveToPlayer me
end

on zeroDelays me
  choiceDelay = 0
  assessmentDelay = 0
end

on resetDelays me
  if (targetPrevMoveID = g.MOVE_UNDEFINED) or (targetPrevMoveID = g.MOVE_KNOCK_DOWN) or (targetPrevMoveID = g.MOVE_STUN) or (targetPrevMoveID = g.MOVE_BLOCK) then
    min = CHOICE_DELAY_REBOUND_MIN
    max = CHOICE_DELAY_REBOUND_MAX
  else
    if target.isEnraged() then
      min = CHOICE_DELAY_ENRAGED_MIN
      max = CHOICE_DELAY_ENRAGED_MAX
    else
      min = CHOICE_DELAY_NORMAL_MIN
      max = CHOICE_DELAY_NORMAL_MAX
    end if
  end if
  range = max - min
  if range > 0 then
    choiceDelay = random(max - min) + min
  else
    choiceDelay = min
  end if
  assessmentDelay = 0
end

on update me
  if target.isFrozen() then
    exit
  end if
  if not enabled then
    exit
  end if
  targetPrevMoveID = targetCurrMoveID
  targetPrevDir = targetCurrDir
  targetPrevPos = targetCurrPos
  targetPrevVel = targetCurrVel
  targetPrevBusy = targetCurrBusy
  targetCurrMoveID = target.getMoveID()
  targetCurrDir = target.getDir()
  targetCurrPos = target.getPos()
  targetCurrVel = target.getVel()
  targetCurrBusy = target.isDoingMove()
  targetMove = target.getMove()
  opponentCurrPos = target.opponent.getPos()
  opponentCurrVel = target.opponent.getVel()
  opponentCurrMoveID = target.opponent.getMoveID()
  opponentMove = target.opponent.getMove()
  opponentPrevMoveNum = opponentCurrMoveNum
  opponentCurrMoveNum = target.opponent.getMoveNumber()
  opponentCurrDir = target.opponent.getDir()
  if me.targetCurrDir > 0 then
    targetAtSceneEdge = (targetCurrPos.locH - g.game.scene.getBoundsMinX()) < 100
    targetAtScreenEdge = (targetCurrPos.locH - g.game.scene.getViewRect().left) < 50
  else
    targetAtSceneEdge = (g.game.scene.getBoundsMaxX() - targetCurrPos.locH) < 100
    targetAtScreenEdge = (g.game.scene.getViewRect().right - targetCurrPos.locH) < 50
  end if
  if not targetCurrBusy then
    if targetPrevBusy then
      me.resetDelays()
    end if
    case targetCurrMoveID of
      g.MOVE_BLOCK:
        if opponentMove.hasHitOpponent() or (opponentCurrMoveNum <> opponentPrevMoveNum) then
          me.resetDelays()
        end if
      g.MOVE_WALK_BACKWARD:
        if targetAtSceneEdge or targetAtScreenEdge then
          me.zeroDelays()
        end if
      g.MOVE_WALK_FORWARD:
        if abs(opponentCurrPos.locH - targetCurrPos.locH) <= RANGE_THRESHOLD_X_SHORT then
          me.zeroDelays()
        end if
      otherwise:
        me.serviceCurrentMove()
    end case
    if g.frameCount >= (lastAssessmentAt + assessmentDelay) then
      oppMoveNum = me.target.opponent.getMoveNumber()
      if oppMoveNum <> lastAssessmentMoveNum then
        canChoose = 1
        lastAssessmentAt = g.frameCount
        if (random(100) - 1) < AWARENESS_PERCENT then
          if opponentMove.isAttack() and not opponentMove.hasHitOpponent() then
            if opponentMove.usesProjectile() then
              attackingObj = opponentMove.projectile
              if voidp(attackingObj) then
                attackingObj = target.opponent
              end if
            else
              attackingObj = target.opponent
            end if
            attVel = attackingObj.getVel()
            attPos = attackingObj.getPos()
            if opponentMove.isMelee() then
              dist = attPos.locH - target.getPosX()
              if dist < 150 then
                me.evadeMeleeAttack(dist)
                canChoose = 0
                lastChoiceAt = g.frameCount
                assessmentDelay = EVASIVE_MOVE_DURATION
                lastAssessmentMoveNum = oppMoveNum
              end if
            else
              oppAttBox = attackingObj.getAttackBox()
              tarDefBox = target.getDefenseBox()
              if oppAttBox.width > 0 then
                testBox = oppAttBox
                repeat with i = 0 to LOOK_AHEAD_FRAMES - 1
                  testBox = testBox.offset(attVel.locH, attVel.locV)
                  if testBox.intersect(tarDefBox) <> g.RECT_0 then
                    if (random(100) - 1) < COUNTER_ATTACK_PERCENT then
                      me.counterAttack(attPos, attVel, i)
                    else
                      me.evadeRangedAttack(attPos, attVel, i)
                    end if
                    canChoose = 0
                    lastChoiceAt = g.frameCount
                    assessmentDelay = EVASIVE_MOVE_DURATION
                    lastAssessmentMoveNum = oppMoveNum
                    exit repeat
                  end if
                end repeat
              else
              end if
            end if
          end if
        end if
      end if
      if canChoose then
        if g.frameCount >= (lastChoiceAt + choiceDelay) then
          if targetAtScreenEdge then
            me.moveToPlayer()
          else
            if me.target.isEnraged() then
              threshold = AGGRESSION_PERCENT_ENRAGED
            else
              threshold = AGGRESSION_PERCENT_NORMAL
            end if
            if (random(100) - 1) < threshold then
              me.selectAttackMove()
            else
              me.selectPassiveMove()
            end if
          end if
          lastChoiceAt = g.frameCount
        end if
      end if
    else
    end if
  end if
end

on isEnabled me
  return enabled
end

on setEnabled me, b
  enabled = b
end
