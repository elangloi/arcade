// Lobby client for the multiplayer service: one session per browser tab, one WebSocket.
import { MP_BASE } from './games'

export interface Welcome { t: 'welcome'; session: string; name: string | null; state: 'idle' | 'queued' | 'matched'; match: { id: string; state: string } | null }
export type ServerMessage =
  | Welcome
  | { t: 'queued'; position: number }
  | { t: 'matched'; matchId: string; opponent: { name: string } }
  | { t: 'opponent_left'; reason: string }
  | { t: 'error'; code: string; msg: string }
  | { t: string; [k: string]: unknown }

export async function getSession(): Promise<{ id: string; name: string | null; state: string }> {
  let id = sessionStorage.getItem('mp.session')
  if (id) {
    const r = await fetch(`${MP_BASE}/api/session/${encodeURIComponent(id)}`, { cache: 'no-store' })
    if (r.ok) { const j = await r.json(); return { id, name: j.name, state: j.state } }
  }
  const r = await fetch(`${MP_BASE}/api/session`, { method: 'POST' })
  if (!r.ok) throw new Error('could not create a session')
  id = (await r.json()).sessionId as string
  sessionStorage.setItem('mp.session', id)
  return { id, name: null, state: 'idle' }
}

export function connect(session: string, name: string | null, onMessage: (m: ServerMessage) => void, onClose: (code: number) => void) {
  const url = new URL(`${MP_BASE}/ws`, location.href)
  url.protocol = url.protocol === 'https:' ? 'wss:' : 'ws:'
  url.searchParams.set('session', session)
  const ws = new WebSocket(url)
  ws.onopen = () => ws.send(JSON.stringify({ t: 'hello', name: name || undefined }))
  ws.onmessage = ev => onMessage(JSON.parse(ev.data))
  ws.onclose = ev => onClose(ev.code)
  return {
    send: (m: object) => { if (ws.readyState === 1) ws.send(JSON.stringify(m)) },
    close: () => ws.close(),
  }
}

export async function stats(): Promise<{ online: number; queued: number; playing: number }> {
  return (await fetch(`${MP_BASE}/api/stats`, { cache: 'no-store' })).json()
}
