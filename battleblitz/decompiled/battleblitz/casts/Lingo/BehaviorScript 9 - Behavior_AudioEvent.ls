property assetGroup, soundName, volumeLevel, stopAtEndSprite, soundMem
global g

on beginSprite me
  if not voidp(g.main) then
    assetObj = g.assets.getaProp(assetGroup)
    if not voidp(assetObj) then
      soundMem = assetObj.getaProp(soundName)
      if not voidp(soundMem) then
        g.main.audioMgr.playSound(soundMem, volumeLevel, g.SFX_EVENT_PRIORITY_LOW)
      end if
    end if
  end if
end

on endSprite me
  if not voidp(g) then
    if not voidp(g.main) then
      if stopAtEndSprite then
        if not voidp(soundMem) then
          g.main.audioMgr.stopSound(soundMem)
        end if
      end if
    end if
  end if
end

on getPropertyDescriptionList me
  props = [:]
  props.addProp(#soundName, [#default: #SFX_, #format: #symbol, #comment: "Play sound:"])
  props.addProp(#assetGroup, [#default: #AUDIO, #format: #symbol, #comment: "From asset class:"])
  props.addProp(#volumeLevel, [#default: 100, #format: #integer, #range: [#min: 0, #max: 100], #comment: "At volume:"])
  props.addProp(#stopAtEndSprite, [#default: 0, #format: #boolean, #comment: "Stop on 'endSprite'?"])
  return props
end
