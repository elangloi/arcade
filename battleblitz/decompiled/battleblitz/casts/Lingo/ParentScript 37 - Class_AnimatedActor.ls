property ancestor, animation
global g

on new me, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Actor, initPos, initVel, initDir)
  animation = VOID
  return me
end

on destroy me
  if objectp(animation) then
    animation.destroy()
  end if
  return VOID
end

on update me
  ancestor.update()
  if not voidp(animation) then
    animation.advance()
    if me.visSprite.spriteNum > 0 then
      me.visSprite.member = animation.getMember()
    end if
  end if
end
