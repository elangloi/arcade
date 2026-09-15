property minChannel, maxChannel, chanIndex, channelsInUse
global g

on new me, min, max
  minChannel = min
  maxChannel = max
  channelsInUse = g.util.newArray(maxChannel - minChannel + 1, 0)
  chanIndex = channelsInUse.count
  repeat with i = minChannel to maxChannel
    sprite(i).visible = 1
  end repeat
  return me
end

on destroy me
  me.initAllChannels()
  return VOID
end

on initSprite me, s
  s.width = 0
  s.height = 0
  s.blend = 100
  s.ink = 0
  s.visible = 1
  s.flipH = 0
  s.flipV = 0
  s.locZ = s.spriteNum
  s.member = member(0)
  s.puppet = 0
end

on initChannel me, i
  me.initSprite(sprite(i))
end

on initAllChannels me
  repeat with i = minChannel to maxChannel
    me.initChannel(i)
  end repeat
end

on grabSprite me
  startIndex = chanIndex
  done = 0
  repeat while not done
    chanIndex = chanIndex + 1
    if chanIndex > channelsInUse.count then
      chanIndex = 1
    end if
    if chanIndex = startIndex then
      return sprite(0)
    end if
    if not channelsInUse[chanIndex] then
      done = 1
    end if
  end repeat
  channelsInUse[chanIndex] = 1
  s = sprite(minChannel + chanIndex - 1)
  s.puppet = 1
  return s
end

on releaseSprite me, s
  channelsInUse[s.spriteNum - minChannel + 1] = 0
  me.initSprite(s)
end
