global g

on beginSprite me
  case g.game.roundState of
    g.game.ROUNDSTATE_TITAN_WINS_BY_DAMAGE, g.game.ROUNDSTATE_TITAN_WINS_BY_TIME:
      case g.titanID of
        g.FIGHTER_ID_ROBIN:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_ROBIN
        g.FIGHTER_ID_RAVEN:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_RAVEN
        g.FIGHTER_ID_CYBORG:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_CYBORG
        g.FIGHTER_ID_STARFIRE:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_STARFIRE
        g.FIGHTER_ID_BEASTBOY:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_BEASTBOY
      end case
    g.game.ROUNDSTATE_VILLAIN_WINS_BY_DAMAGE, g.game.ROUNDSTATE_VILLAIN_WINS_BY_TIME:
      case g.villainID of
        g.FIGHTER_ID_JINX:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_JINX
        g.FIGHTER_ID_MAMMOTH:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_MAMMOTH
        g.FIGHTER_ID_GIZMO:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_GIZMO
        g.FIGHTER_ID_CINDERBLOCK:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_CINDERBLOCK
        g.FIGHTER_ID_PLASMUS:
          sprite(me.spriteNum).member = g.assets.GAME_MESSAGES.TXT_WIN_PLASMUS
      end case
  end case
end
