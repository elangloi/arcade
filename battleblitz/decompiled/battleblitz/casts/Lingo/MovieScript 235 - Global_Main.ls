global g

on prepareMovie
  clearGlobals()
  set the exitLock to 1
  g = new(script("Class_Globals"))
  g.init()
  puppetTempo(999)
end

on stopMovie
  g = g.destroy()
end

on prepareFrame me
  if not voidp(g.main) then
    g.main.update()
    g.main.paint()
  end if
end

on exitFrame me
  if not voidp(g.main) then
    g.main.branch()
  end if
end
