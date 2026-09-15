property ancestor
global g

on new me, owner, initPos, initVel, initDir
  ancestor = new(g.classes.Class_Effect, owner, initPos, initVel, initDir)
  vis = [g.assets.JINX.JINX_NEWFIST_01, g.assets.JINX.JINX_NEWFIST_02, g.assets.JINX.JINX_NEWFIST_03, g.assets.JINX.JINX_NEWFIST_04, g.assets.JINX.JINX_NEWFIST_05, g.assets.JINX.JINX_NEWFIST_06, g.assets.JINX.JINX_NEWFIST_07, g.assets.JINX.JINX_NEWFIST_08, g.assets.JINX.JINX_NEWFIST_09, g.assets.JINX.JINX_NEWFIST_10]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end
