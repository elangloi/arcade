property objList, zLoc, trailLength, blends
global g

on new me, len, z
  trailLength = len
  zLoc = z
  objList = g.util.newArray(trailLength, VOID)
  blends = []
  repeat with i = 1 to trailLength
    blends.append(integer(i * (100.0 / (trailLength + 1))))
  end repeat
  return me
end

on destroy me
  repeat with o in objList
    if objectp(o) then
      o.destroy()
    end if
  end repeat
  return VOID
end

on reset me
  repeat with o in objList
    if objectp(o) then
      o.destroy()
    end if
  end repeat
  objList = g.util.newArray(trailLength, VOID)
end

on update me, actorObj
  if voidp(actorObj) then
    objList.append(VOID)
  else
    objList.append(new(g.classes.Class_StaticActor, actorObj.getSprite().member, zLoc, actorObj.pos, point(0.0, 0.0), actorObj.dir))
  end if
  objList.deleteAt(1)
  repeat with i = 1 to objList.count
    o = objList[i]
    if not voidp(o) then
      if i = 1 then
        o.destroy()
        next repeat
      end if
      o.getSprite().blend = blends[i]
    end if
  end repeat
end

on paint me
  repeat with o in objList
    if not voidp(o) then
      o.paint()
    end if
  end repeat
end
