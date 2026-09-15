property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.STARFIRE.FX_STARFIRE_SUMMON_01, g.assets.STARFIRE.FX_STARFIRE_SUMMON_02, g.assets.STARFIRE.FX_STARFIRE_SUMMON_03, g.assets.STARFIRE.FX_STARFIRE_SUMMON_04, g.assets.STARFIRE.FX_STARFIRE_SUMMON_05]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
