property ancestor, otherArm
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.PLASMUS.PLASMUS_PUNCH_02_ARM1]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.animation.setRepeat(2)
  me.visSprite.blend = 75
  otherArm = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.PLASMUS.PLASMUS_PUNCH_02_ARM2]
  otherArm.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  otherArm.animation.setRepeat(2)
  otherArm.visSprite.blend = 50
  return me
end

on destroy me
  ancestor.destroy()
  otherArm.destroy()
  return VOID
end

on update me
  ancestor.update()
  otherArm.update()
  if me.alive then
    if me.age > 1 then
      iBlend1 = me.visSprite.blend - 30
      if iBlend1 < 0 then
        iBlend1 = 0
      end if
      iBlend2 = otherArm.visSprite.blend - 20
      if iBlend2 < 0 then
        iBlend2 = 0
      end if
      me.visSprite.blend = iBlend1
      otherArm.visSprite.blend = iBlend2
    end if
  end if
end

on paint me
  ancestor.paint()
  otherArm.paint()
end
