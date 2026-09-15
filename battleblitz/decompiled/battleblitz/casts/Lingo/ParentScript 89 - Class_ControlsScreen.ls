property SCREENSTAGE_INTRO, SCREENSTAGE_OUTRO, ancestor, screenStage, initStage, delayFrames
global g

on new me
  ancestor = new(g.classes.Class_Screen)
  SCREENSTAGE_INTRO = 1
  SCREENSTAGE_OUTRO = 2
  return me
end

on destroy me
  if me.loaded then
    me.unload()
  end if
  ancestor.destroy()
  return VOID
end

on load me
  me.loaded = 1
end

on unload me
  me.loaded = 0
end

on update me
end
