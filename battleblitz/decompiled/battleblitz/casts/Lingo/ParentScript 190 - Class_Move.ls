property owner, MOVETYPE_UNDEFINED, MOVETYPE_ATTACK, MOVETYPE_INTERRUPTIBLE, MOVETYPE_VULNERABLE, MOVETYPE_INIT_OWNER_DIR, MOVETYPE_USES_PROJECTILE, MOVETYPE_IMMOBILE, MOVETYPE_MELEE, moveType, moveDone, animation, age, attackMasks, defenseMasks, attackDamage, defenseRating, stunDuration, hitOpponent
global g

on new me, obj
  owner = obj
  MOVETYPE_UNDEFINED = 0
  MOVETYPE_ATTACK = 1
  MOVETYPE_INTERRUPTIBLE = 2
  MOVETYPE_VULNERABLE = 4
  MOVETYPE_INIT_OWNER_DIR = 8
  MOVETYPE_USES_PROJECTILE = 16
  MOVETYPE_IMMOBILE = 32
  MOVETYPE_MELEE = 64
  moveType = MOVETYPE_UNDEFINED
  me.setType(MOVETYPE_INTERRUPTIBLE)
  moveDone = 0
  age = 0
  attackMasks = []
  defenseMasks = []
  attackDamage = 0
  defenseRating = 0
  stunDuration = g.STUN_DURATION_DEFAULT
  hitOpponent = 0
  return me
end

on destroy me
  return VOID
end

on update me
  age = age + 1
  if not voidp(animation) then
    if age > 1 then
      animation.advance()
    end if
    moveDone = animation.isDone()
  end if
end

on isDone me
  return moveDone
end

on reset me
  moveDone = 0
  age = 0
  contacts = 0
  animation.reset()
  hitOpponent = 0
end

on stop me
end

on setType me, attrib
  moveType = bitOr(moveType, attrib)
end

on clearType me, attrib
  moveType = bitAnd(moveType, bitNot(attrib))
end

on resetType me, attrib
  moveType = MOVETYPE_UNDEFINED
end

on hasType me, attrib
  return bitAnd(moveType, attrib) <> 0
end

on isAttack me
  return me.hasType(MOVETYPE_ATTACK)
end

on setAttack me, b
  if b then
    me.setType(MOVETYPE_ATTACK)
  else
    me.clearType(MOVETYPE_ATTACK)
  end if
end

on isInterruptible me
  return me.hasType(MOVETYPE_INTERRUPTIBLE)
end

on setInterruptible me, b
  if b then
    me.setType(MOVETYPE_INTERRUPTIBLE)
  else
    me.clearType(MOVETYPE_INTERRUPTIBLE)
  end if
end

on isVulnerable me
  return me.hasType(MOVETYPE_VULNERABLE)
end

on setVulnerable me, b
  if b then
    me.setType(MOVETYPE_VULNERABLE)
  else
    me.clearType(MOVETYPE_VULNERABLE)
  end if
end

on isInitOwnerDir me
  return me.hasType(MOVETYPE_INIT_OWNER_DIR)
end

on setInitOwnerDir me, b
  if b then
    me.setType(MOVETYPE_INIT_OWNER_DIR)
  else
    me.clearType(MOVETYPE_INIT_OWNER_DIR)
  end if
end

on usesProjectile me
  return me.hasType(MOVETYPE_USES_PROJECTILE)
end

on setUsesProjectile me, b
  if b then
    me.setType(MOVETYPE_USES_PROJECTILE)
  else
    me.clearType(MOVETYPE_USES_PROJECTILE)
  end if
end

on isImmobile me
  return me.hasType(MOVETYPE_IMMOBILE)
end

on setImmobile me, b
  if b then
    me.setType(MOVETYPE_IMMOBILE)
  else
    me.clearType(MOVETYPE_IMMOBILE)
  end if
end

on isMelee me
  return me.hasType(MOVETYPE_MELEE)
end

on setMelee me, b
  if b then
    me.setType(MOVETYPE_MELEE)
  else
    me.clearType(MOVETYPE_MELEE)
  end if
end

on getVisibleMember me
  return me.animation.getMember()
end

on getAttackMaskMember me
  return attackMasks[me.animation.currIndex]
end

on getDefenseMaskMember me
  return defenseMasks[me.animation.currIndex]
end

on getFlipX me
  return 0
end

on getFlipY me
  return 0
end

on dirChanged me
end

on getAttackRect me
  m = me.getAttackMaskMember()
  if m.number > 0 then
    p = m.regPoint
    return m.rect - rect(p, p)
  else
    return rect(0, 0, 0, 0)
  end if
end

on getDefenseRect me
  m = me.getDefenseMaskMember()
  if m.number > 0 then
    p = m.regPoint
    return m.rect - rect(p, p)
  else
    return rect(0, 0, 0, 0)
  end if
end

on hasHitOpponent me
  return hitOpponent
end

on opponentHit me
  hitOpponent = 1
  if me.owner.opponent.isBlocking() or not me.owner.opponent.getMove().isVulnerable() then
    return 0
  else
    return 1
  end if
end

on getAge me
  return age
end
