property loaded
global g

on new me
  loaded = 0
  return me
end

on destroy me
  if loaded then
    me.unload()
  end if
  return VOID
end

on load me
  me.loaded = 0
end

on unload me
  me.loaded = 0
end

on update
end

on paint me
end
