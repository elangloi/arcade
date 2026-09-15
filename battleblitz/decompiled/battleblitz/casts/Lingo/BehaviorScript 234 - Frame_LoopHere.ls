global g

on exitFrame me
  if not g.goFrame then
    g.goFrame = the frame
  end if
  pass()
end
