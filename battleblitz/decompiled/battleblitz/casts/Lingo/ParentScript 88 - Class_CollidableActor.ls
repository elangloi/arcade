property ancestor, attBox, defBox, collisions, contactTable
global g

on new me, initPos, initVel, initDir
  ancestor = new(g.classes.Class_AnimatedActor, initPos, initVel, initDir)
  collisions = []
  attBox = rect(0, 0, 0, 0)
  defBox = rect(0, 0, 0, 0)
  contactTable = new(g.classes.Class_ObjectTable)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on updateBoundingBoxes me
  me.updateAttackBoundingBox()
  me.updateDefenseBoundingBox()
end

on updateAttackBoundingBox me
end

on updateDefenseBoundingBox me
end

on collidesWith me, actor
  return me.attBox.intersect(actor.defBox) <> g.RECT_0
end

on registerCollision me, actor
  collisions.append(actor)
end

on processCollisions me
  repeat with i = 1 to collisions.count
  end repeat
  resetCollisions()
end

on resetCollisions me
  collisions = []
end

on reactToCollision me
  nothing()
end

on getAttackBox me
  return attBox
end

on getDefenseBox me
  return defBox
end
