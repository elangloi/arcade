// Round watchers for cabinets that can't post `arcade:round` themselves.
//
// Single-player Battle Blitz is the historical recreation and stays byte-for-byte untouched, so
// instead of it telling the shell a match ended, the shell looks: the frame is same-origin and the
// game leaves its globals on `window.G` (main.js). A match is best of 3; it's over when either
// side reaches two round wins.
import { awardRound } from './tickets'

interface BlitzGame { playerWins: number; enemyWins: number }
type BlitzWindow = Window & { G?: { g?: { game?: BlitzGame } } }

function watchBattleBlitz(frame: HTMLIFrameElement) {
  let game: BlitzGame | undefined
  let reported = false
  const h = window.setInterval(() => {
    let g: BlitzGame | undefined
    try { g = (frame.contentWindow as BlitzWindow | null)?.G?.g?.game } catch { return }   // mid-navigation
    if (g !== game) { game = g; reported = false }
    if (!g) return
    const over = g.playerWins >= 2 || g.enemyWins >= 2
    if (over && !reported) {
      reported = true
      awardRound({ game: 'battleblitz', won: g.playerWins > g.enemyWins, roundsWon: g.playerWins })
    } else if (!over) reported = false
  }, 250)
  return () => window.clearInterval(h)
}

const WATCHERS: Record<string, (frame: HTMLIFrameElement) => () => void> = {
  'single/battleblitz': watchBattleBlitz,
}

// Starts the watcher for this cabinet, if it has one. Returns the cleanup.
export function watchRounds(key: string, frame: HTMLIFrameElement | null) {
  const w = frame && WATCHERS[key]
  return w ? w(frame) : () => {}
}
