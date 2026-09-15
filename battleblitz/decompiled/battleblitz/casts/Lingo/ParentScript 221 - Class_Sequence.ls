property done
global g

on new me
  done = 0
  return me
end

on destroy me
  return VOID
end

on update me
end

on paint me
end

on isDone me
  return done
end
