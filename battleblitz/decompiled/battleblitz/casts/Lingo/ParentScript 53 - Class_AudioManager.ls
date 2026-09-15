property CHANNEL_COUNT, FADE_NONE, FADE_IN, FADE_OUT, eventCounter, channelEventIDs, channelMembers, channelVolumes, channelPriorities, channelFadeDirections, channelFadeDurations, channelFadeStartVolumes, channelFadeEndVolumes
global g

on new me
  CHANNEL_COUNT = 8
  FADE_NONE = 0
  FADE_IN = 1
  FADE_OUT = 2
  eventCounter = 0
  channelEventIDs = g.util.newArray(CHANNEL_COUNT, 0)
  channelMembers = g.util.newArray(CHANNEL_COUNT, VOID)
  channelVolumes = g.util.newArray(CHANNEL_COUNT, 0)
  channelPriorities = g.util.newArray(CHANNEL_COUNT, 0)
  channelFadeDirections = g.util.newArray(CHANNEL_COUNT, FADE_NONE)
  channelFadeDurations = g.util.newArray(CHANNEL_COUNT, 0)
  channelFadeStartVolumes = g.util.newArray(CHANNEL_COUNT, 0)
  channelFadeEndVolumes = g.util.newArray(CHANNEL_COUNT, 0)
  repeat with i = 1 to CHANNEL_COUNT
    me.clearChannel(i)
  end repeat
  return me
end

on destroy me
  return VOID
end

on clearChannel me, chan
  sound(chan).stop()
  channelEventIDs[chan] = 0
  channelMembers[chan] = VOID
  channelVolumes[chan] = 0
  channelPriorities[chan] = 0
  channelFadeDirections[chan] = FADE_NONE
  channelFadeDurations[chan] = 0
  channelFadeStartVolumes[chan] = 0
  channelFadeEndVolumes[chan] = 0
end

on playInChannel me, mem, chan, vol, pri
  channelVolumes[chan] = vol
  channelMembers[chan] = mem
  channelPriorities[chan] = pri
  me.setChannelVolume(chan, vol)
  sound(chan).play(mem)
end

on setChannelVolume me, chan, vol
  channelVolumes[chan] = vol
  sound(chan).volume = integer(vol * 2.54999999999999982)
end

on update me
  repeat with i = 1 to CHANNEL_COUNT
    if channelEventIDs[i] then
      if channelFadeDirections[i] = FADE_IN then
        vol = channelVolumes[i] + integer((channelFadeEndVolumes[i] - channelFadeStartVolumes[i]) / channelFadeDurations[i])
        if vol < channelFadeEndVolumes[i] then
          vol = channelFadeEndVolumes[i]
        end if
        me.setChannelVolume(i, vol)
        if vol = channelFadeEndVolumes[i] then
          channelFadeDirections[i] = FADE_NONE
          channelFadeDurations[i] = 0
          channelFadeStartVolumes[i] = 0
          channelFadeEndVolumes[i] = 0
        end if
      else
        if channelFadeDirections[i] = FADE_OUT then
          vol = channelVolumes[i] - integer((channelFadeStartVolumes[i] - channelFadeEndVolumes[i]) / channelFadeDurations[i])
          if vol < channelFadeEndVolumes[i] then
            vol = channelFadeEndVolumes[i]
          end if
          me.setChannelVolume(i, vol)
          if vol = channelFadeEndVolumes[i] then
            if vol = 0 then
              me.clearChannel(i)
            else
              channelFadeDirections[i] = FADE_NONE
              channelFadeDurations[i] = 0
              channelFadeStartVolumes[i] = 0
              channelFadeEndVolumes[i] = 0
            end if
          end if
        end if
      end if
      if not sound(i).isBusy() then
        me.clearChannel(i)
      end if
    end if
  end repeat
end

on playSound me, mem, vol, pri
  if voidp(mem) then
    exit
  end if
  if voidp(vol) then
    vol = 100
  end if
  if voidp(pri) then
    pri = g.SFX_EVENT_PRIORITY_NONE
  end if
  chan = 0
  repeat with i = 1 to CHANNEL_COUNT
    if voidp(channelMembers[i]) then
      chan = i
      exit repeat
      next repeat
    end if
    if pri > channelPriorities[i] then
      if chan > 0 then
        if channelPriorities[i] < channelPriorities[chan] then
          chan = i
        end if
        next repeat
      end if
      chan = i
    end if
  end repeat
  if chan then
    eventCounter = eventCounter + 1
    me.clearChannel(chan)
    me.playInChannel(mem, chan, vol, pri)
    channelEventIDs[chan] = eventCounter
    return eventCounter
  else
    return 0
  end if
end

on stopSound me, arg
  if integerp(arg) then
    i = channelEventIDs.getPos(arg)
  else
    i = channelMembers.getPos(arg)
  end if
  if not i then
    exit
  end if
  me.clearChannel(i)
end

on stopAllSounds me
  repeat with i = 1 to CHANNEL_COUNT
    me.clearChannel(i)
  end repeat
end

on isPlaying me, arg
  if integerp(arg) then
    return channelEventIDs.getPos(arg) <> 0
  else
    return channelMembers.getPos(arg) <> 0
  end if
end

on fadeOutSound me, arg, endVol, dur
  if integerp(arg) then
    chan = channelEventIDs.getPos(arg)
  else
    chan = channelMembers.getPos(arg)
  end if
  if not chan then
    exit
  end if
  startVol = channelVolumes[chan]
  if endVol >= startVol then
    exit
  end if
  channelFadeStartVolumes[chan] = startVol
  channelFadeEndVolumes[chan] = endVol
  channelFadeDirections[chan] = FADE_OUT
  channelFadeDurations[chan] = integer(dur * g.FRAME_RATE)
end

on fadeInEvent me, arg, endVol, dur
  if integerp(arg) then
    chan = channelEventIDs.getPos(arg)
  else
    chan = channelMembers.getPos(arg)
  end if
  if not chan then
    exit
  end if
  startVol = channelVolumes[chan]
  if endVol <= startVol then
    exit
  end if
  channelFadeStartVolumes[chan] = startVol
  channelFadeEndVolumes[chan] = endVol
  channelFadeDirections[chan] = FADE_IN
  channelFadeDurations[chan] = integer(dur * g.FRAME_RATE)
end

on getEventID me, mem
  i = channelMembers.getPos(mem)
  if i then
    return channelEventIDs[i]
  else
    return 0
  end if
end
