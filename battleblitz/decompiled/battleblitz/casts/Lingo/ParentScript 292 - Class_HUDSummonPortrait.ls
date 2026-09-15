property time, HUD_SUMMON_PORTRAITS, HUD_SUMMON_PORTRAITS_GREY, STATE_AVAILABLE, STATE_FLASHING, STATE_EXPIRED, overlay, state, initState, stateAge, fighterID
global g

on new me, id, initPos
  HUD_SUMMON_PORTRAITS = []
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_ROBIN] = g.assets.hud.HUD_SUMMON_PORTRAIT_ROBIN
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_RAVEN] = g.assets.hud.HUD_SUMMON_PORTRAIT_RAVEN
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_CYBORG] = g.assets.hud.HUD_SUMMON_PORTRAIT_CYBORG
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_STARFIRE] = g.assets.hud.HUD_SUMMON_PORTRAIT_STARFIRE
  HUD_SUMMON_PORTRAITS[g.FIGHTER_ID_BEASTBOY] = g.assets.hud.HUD_SUMMON_PORTRAIT_BEASTBOY
  HUD_SUMMON_PORTRAITS_GREY = []
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_ROBIN] = g.assets.hud.HUD_SUMMON_PORTRAIT_ROBIN_GREY
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_RAVEN] = g.assets.hud.HUD_SUMMON_PORTRAIT_RAVEN_GREY
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_CYBORG] = g.assets.hud.HUD_SUMMON_PORTRAIT_CYBORG_GREY
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_STARFIRE] = g.assets.hud.HUD_SUMMON_PORTRAIT_STARFIRE_GREY
  HUD_SUMMON_PORTRAITS_GREY[g.FIGHTER_ID_BEASTBOY] = g.assets.hud.HUD_SUMMON_PORTRAIT_BEASTBOY_GREY
  STATE_AVAILABLE = 1
  STATE_FLASHING = 2
  STATE_EXPIRED = 3
  fighterID = id
  state = STATE_AVAILABLE
  stateAge = 0
  initState = 1
  overlay = new(g.classes.Class_Overlay, initPos, g.SPRITE_LOCZ_HUD_FG)
  return me
end

on destroy me
  overlay.destroy()
  return VOID
end

on reset me
  me.setState(STATE_AVAILABLE)
end

on setState me, i
  state = i
  initState = 1
  stateAge = 0
end

on update me
  stateAge = stateAge + 1
  case state of
    STATE_AVAILABLE:
      if initState then
        initState = 0
        overlay.setMember(HUD_SUMMON_PORTRAITS[fighterID])
      end if
    STATE_FLASHING:
      if initState then
        initState = 0
      end if
      if (stateAge mod 6) = 1 then
        overlay.setMember(g.assets.hud.HUD_SUMMON_PORTRAIT_FLASH)
      else
        if (stateAge mod 6) = 4 then
          overlay.setMember(HUD_SUMMON_PORTRAITS[fighterID])
        end if
      end if
      if stateAge >= 60 then
        me.setState(STATE_EXPIRED)
      end if
    STATE_EXPIRED:
      if initState then
        initState = 0
        overlay.setMember(HUD_SUMMON_PORTRAITS_GREY[fighterID])
      end if
  end case
end

on paint me
end

on trigger me
  me.setState(STATE_FLASHING)
end
