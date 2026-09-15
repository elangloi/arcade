property ancestor, scoreNumberMembers
global g

on new me
  ancestor = new(g.classes.Class_Screen)
  scoreNumberMembers = [g.util.findMember("endtext_0"), g.util.findMember("endtext_1"), g.util.findMember("endtext_2"), g.util.findMember("endtext_3"), g.util.findMember("endtext_4"), g.util.findMember("endtext_5"), g.util.findMember("endtext_6"), g.util.findMember("endtext_7"), g.util.findMember("endtext_8"), g.util.findMember("endtext_9")]
  return me
end

on load me
  me.loaded = 1
  if g.playMode = g.PLAYMODE_AS_TITANS then
    playerOrder = g.TITAN_FIGHTER_ORDER
    enemyOrder = g.VILLAIN_FIGHTER_ORDER
  else
    playerOrder = g.VILLAIN_FIGHTER_ORDER
    enemyOrder = g.TITAN_FIGHTER_ORDER
  end if
  totalScore = 0
  repeat with enemyID in enemyOrder
    totalScore = totalScore + g.playerScores[g.playerID][enemyID]
  end repeat
  repeat with i = 1 to 9
    digit = totalScore mod g.POWERS_OF_TEN[i + 1] / g.POWERS_OF_TEN[i]
    sprite(20 + i).member = scoreNumberMembers[digit + 1]
  end repeat
end
