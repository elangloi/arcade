property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.CYBORG.FX_CYBORG_POWERUP_02, g.assets.CYBORG.FX_CYBORG_POWERUP_03, g.assets.CYBORG.FX_CYBORG_POWERUP_04, g.assets.CYBORG.FX_CYBORG_POWERUP_05, g.assets.CYBORG.FX_CYBORG_POWERUP_06, g.assets.CYBORG.FX_CYBORG_POWERUP_07, g.assets.CYBORG.FX_CYBORG_POWERUP_08, g.assets.CYBORG.FX_CYBORG_POWERUP_09]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
