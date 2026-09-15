property ancestor, STATE_CROUCH, STATE_ASCENT, STATE_LAUNCH, STATE_WAIT, STATE_DESCENT, STATE_LAND, moveState, initState, delayFrames, projectile
global g

on new me, owner
  ancestor = new(g.classes.Class_Move, owner)
  me.attackDamage = g.DAMAGE_GIZMO_CANNON
  me.setAttack(1)
  me.setInterruptible(0)
  me.setVulnerable(1)
  me.setInitOwnerDir(0)
  me.setUsesProjectile(0)
  me.setImmobile(0)
  vis = [g.assets.GIZMO.GIZMO_TAKEOFF_11, g.assets.GIZMO.GIZMO_TAKEOFF_10, g.assets.GIZMO.GIZMO_TAKEOFF_09, g.assets.GIZMO.GIZMO_TAKEOFF_08, g.assets.GIZMO.GIZMO_HOVER_01]
  att = [g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0, g.MEMBER_0]
  def = [g.assets.GIZMO.GIZMO_TAKEOFF_11D, g.assets.GIZMO.GIZMO_TAKEOFF_10D, g.assets.GIZMO.GIZMO_TAKEOFF_09D, g.assets.GIZMO.GIZMO_TAKEOFF_08D, g.assets.GIZMO.GIZMO_HOVER_01D]
  order = [1, 2, 3, 4, 4, 4, 2, 5]
  me.animation = new(g.classes.Class_IndexedAnimation, vis, order)
  me.attackMasks = att
  me.defenseMasks = def
  STATE_CROUCH = 1
  STATE_ASCENT = 2
  STATE_LAUNCH = 3
  STATE_WAIT = 4
  STATE_DESCENT = 5
  STATE_LAND = 6
  moveState = 1
  initState = 1
  delayFrames = 0
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
  delayFrames = 0
  me.owner.setOnGround(0)
end

on advanceState
  initState = 1
  moveState = moveState + 1
end

on update me
  me.age = me.age + 1
  if not me.moveDone then
    case moveState of
      STATE_CROUCH:
        if initState then
          initState = 0
          delayFrames = 2
        end if
        me.owner.moveBy(0.0, 15.0)
        delayFrames = delayFrames - 1
        if delayFrames = 0 then
          advanceState()
        end if
      STATE_ASCENT:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setVelY(-40)
          g.main.screen.addEffect(new(g.classes.Class_DustJumpEffect, me.owner, point(me.owner.getPosX(), 0.0), point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_JUMP_1, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        me.owner.accelerate(g.gravity)
        if me.owner.getVelY() > 0 then
          me.owner.setVel(0, 0)
          advanceState()
        end if
      STATE_LAUNCH:
        if initState then
          initState = 0
        end if
        if me.age > 1 then
          me.animation.advance()
        end if
        if me.animation.orderIndex = 7 then
          advanceState()
        end if
      STATE_WAIT:
        if initState then
          initState = 0
          me.animation.advance()
          delayFrames = 23
          g.main.screen.addEffect(new(g.classes.Class_GizmoHighMissileEffect, me.owner, me.owner.pos + point(50 * me.owner.dir, -75), point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_MISSILEFIRE, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        delayFrames = delayFrames - 1
        baseX = 330
        baseY = 10
        if delayFrames = 16 then
          g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_MISSILEINFLIGHT, 100, g.SFX_EVENT_PRIORITY_LOW)
        else
          if delayFrames = 10 then
            g.main.screen.addEffect(new(g.classes.Class_GroundExplode2Effect, me.owner, point(me.owner.getPosX() + (baseX * me.owner.dir), baseY), point(0, 0), me.owner.dir))
            g.main.screen.addProjectile(new(g.classes.Class_GizmoHighMissileProjectile, me.owner, point(me.owner.getPosX() + (baseX * me.owner.dir), 0.0), point(0, 0), me.owner.dir))
            g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_MISSILEHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
          else
            if delayFrames = 7 then
              g.main.screen.addEffect(new(g.classes.Class_GroundExplode1Effect, me.owner, point(me.owner.getPosX() + ((baseX - 20) * me.owner.dir), baseY + 5), point(0, 0), me.owner.dir))
            else
              if delayFrames = 5 then
                g.main.screen.addEffect(new(g.classes.Class_GroundExplode1Effect, me.owner, point(me.owner.getPosX() + ((baseX + 10) * me.owner.dir), baseY + 10), point(0, 0), me.owner.dir))
                g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_MISSILEHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
              else
                if delayFrames = 4 then
                  g.main.screen.addEffect(new(g.classes.Class_LightColumnEffect, me.owner, point(me.owner.getPosX() + (baseX * me.owner.dir), baseY), point(0, 0), me.owner.dir))
                else
                  if delayFrames = 3 then
                    g.main.screen.addEffect(new(g.classes.Class_GroundExplode2Effect, me.owner, point(me.owner.getPosX() + ((baseX - 30) * me.owner.dir), baseY - 10), point(0, 0), me.owner.dir))
                  else
                    if delayFrames = 0 then
                      g.main.screen.addEffect(new(g.classes.Class_GroundExplode2Effect, me.owner, point(me.owner.getPosX() + ((baseX + 5) * me.owner.dir), baseY + 5), point(0, 0), me.owner.dir))
                      g.main.audioMgr.playSound(g.assets.GIZMO.SFX_GIZMO_MISSILEHIT, 100, g.SFX_EVENT_PRIORITY_LOW)
                      advanceState()
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      STATE_DESCENT:
        if initState then
          initState = 0
          me.animation.advance()
        end if
        me.owner.accelerate(g.gravity)
        if (me.owner.getPosY() + me.owner.getVelY()) >= (me.owner.HOVER_HEIGHT + 12.0) then
          me.owner.setVel(0.0, 0.0)
          me.owner.setPosY(12.0)
          advanceState()
        end if
      STATE_LAND:
        if initState then
          initState = 0
          me.animation.advance()
          me.owner.setVel(0.0, -10.0)
          g.main.screen.addEffect(new(g.classes.Class_DustFallEffect, me.owner, point(me.owner.getPosX(), 0.0), point(0, 0), me.owner.dir))
          g.main.audioMgr.playSound(g.assets.AUDIO.SFX_LANDING_SMALL_PERSON, 100, g.SFX_EVENT_PRIORITY_LOW)
        end if
        if me.owner.getPosY() <= me.owner.HOVER_HEIGHT then
          me.owner.setVel(0.0, 0.0)
          me.owner.setPosY(me.owner.HOVER_HEIGHT)
          me.moveDone = 1
        end if
    end case
  end if
end
