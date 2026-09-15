property ancestor, STATE_LAUNCH, STATE_WAIT, STATE_FINISH, moveState, initState, stateAge, projectile
global g

on new me, owner
  ancestor = new(g.classes.Class_Move, owner)
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(1)
  me.setImmobile(0)
  me.setMelee(0)
  vis = [g.assets.PLASMUS.PLASMUS_CHEST_BLAST_01, g.assets.PLASMUS.PLASMUS_CHEST_BLAST_02, g.assets.PLASMUS.PLASMUS_CHEST_BLAST_03, g.assets.PLASMUS.PLASMUS_CHEST_BLAST_04, g.assets.PLASMUS.PLASMUS_CHEST_BLAST_05]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.PLASMUS.PLASMUS_CHEST_BLAST_01D, g.assets.PLASMUS.PLASMUS_CHEST_BLAST_02D, g.assets.PLASMUS.PLASMUS_CHEST_BLAST_03D, g.assets.PLASMUS.PLASMUS_CHEST_BLAST_04D, g.assets.PLASMUS.PLASMUS_CHEST_BLAST_05D]
  me.animation = new(g.classes.Class_PlayOnceAnimation, vis)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_LAUNCH = 1
  STATE_WAIT = 2
  moveState = 1
  initState = 1
  stateAge = 0
  return me
end

on destroy me
  ancestor.destroy()
  return VOID
end

on reset me, arg
  ancestor.reset()
  moveState = 1
  initState = 1
  stateAge = 0
  projectile = VOID
  me.owner.setOnGround(1)
  me.owner.setShaking(0)
  me.owner.setHovering(0)
  me.owner.setShowingTrails(0)
  me.owner.setVel(0.0, 0.0)
end

on advanceState
  initState = 1
  moveState = moveState + 1
  stateAge = 0
end

on update me
  me.age = me.age + 1
  stateAge = stateAge + 1
  if not me.moveDone then
    case moveState of
      STATE_LAUNCH:
        if initState then
          initState = 0
        end if
        if me.stateAge = 4 then
          me.animation.advance()
        else
          if me.stateAge = 16 then
            me.animation.advance()
          else
            if me.stateAge = 18 then
              me.advanceState()
            end if
          end if
        end if
      STATE_WAIT:
        if initState then
          initState = 0
          me.animation.advance()
          projectile = new(g.classes.Class_PlasmusChestBlastProjectile_1, me.owner, me.owner.pos + point(200 * me.owner.dir, -265), point(26.0 * me.owner.dir, -10.0), me.owner.dir)
          g.main.screen.addProjectile(projectile)
          projectile = new(g.classes.Class_PlasmusChestBlastProjectile_2, me.owner, me.owner.pos + point(200 * me.owner.dir, -190), point(30.0 * me.owner.dir, -5.0), me.owner.dir)
          g.main.screen.addProjectile(projectile)
          projectile = new(g.classes.Class_PlasmusChestBlastProjectile_3, me.owner, me.owner.pos + point(220 * me.owner.dir, -85), point(26.0 * me.owner.dir, 5.0), me.owner.dir)
          g.main.screen.addProjectile(projectile)
          g.game.hud.flashScreen(1)
          if random(2) = 1 then
            g.main.audioMgr.playSound(g.assets.PLASMUS.SFX_PLASMUS_ROAR_BIG, 100, g.SFX_EVENT_PRIORITY_LOW)
          end if
        end if
        if me.stateAge = 20 then
          me.animation.advance()
        else
          if me.stateAge >= 26 then
            projectile = VOID
            me.moveDone = 1
          end if
        end if
    end case
  end if
end
