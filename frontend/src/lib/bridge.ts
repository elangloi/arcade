// The frame bridge: games run inside an <iframe>; this is the message contract between them and
// the shell. Same-origin postMessage, every message is `{ type: 'arcade:…', … }`.
//
//   game -> shell   arcade:ready                       the game booted (shell may reply with the balance)
//                   arcade:navigate  { to }            'lobby' | 'home' | 'single' | 'multiplayer'
//                   arcade:hud { me, opp, status, rtt, help }   text for the shell to show under the frame
//                   arcade:coins:earn  { game, amount, reason }   (foundation — not credited from games yet)
//                   arcade:coins:spend { game, amount, reason }
//   shell -> game   arcade:coins:balance { balance }
import { coins } from './coins'

export type BridgeNav = 'lobby' | 'home' | 'single' | 'multiplayer'
export interface BridgeMessage { type: string; [k: string]: unknown }
export interface Hud { me: string; opp: string; status: string; rtt: string; help: string }
export interface BridgeHandlers { onNavigate: (to: BridgeNav) => void; onHud?: (hud: Hud) => void }

// Games can only earn coins once the server-side wallet exists; until then earn/spend messages are
// logged so the plumbing can be exercised in dev without minting anything.
const CREDIT_FROM_GAMES = false

export function installBridge(frame: () => HTMLIFrameElement | null, { onNavigate, onHud }: BridgeHandlers) {
  const handler = (ev: MessageEvent<BridgeMessage>) => {
    if (ev.origin !== location.origin) return
    const f = frame()
    if (!f || ev.source !== f.contentWindow) return
    const m = ev.data
    if (!m || typeof m.type !== 'string' || !m.type.startsWith('arcade:')) return
    switch (m.type) {
      case 'arcade:ready':
        f.contentWindow?.postMessage({ type: 'arcade:coins:balance', balance: coins.balance() }, location.origin)
        break
      case 'arcade:navigate':
        onNavigate(m.to as BridgeNav)
        break
      case 'arcade:hud':
        onHud?.(m as unknown as Hud)
        break
      case 'arcade:coins:earn':
      case 'arcade:coins:spend': {
        const { game, amount, reason } = m as unknown as { game: string; amount: number; reason: string }
        if (CREDIT_FROM_GAMES) {
          if (m.type === 'arcade:coins:earn') coins.earn(game, amount, reason); else coins.spend(game, amount, reason)
        } else {
          console.info('[coins] (not enabled yet)', m.type, game, amount, reason)
        }
        f.contentWindow?.postMessage({ type: 'arcade:coins:balance', balance: coins.balance() }, location.origin)
        break
      }
    }
  }
  window.addEventListener('message', handler)
  return () => window.removeEventListener('message', handler)
}
