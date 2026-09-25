// A cabinet, playing: the game's own page inside a bezel, with how-to-play in the rail beside it.
// The frame talks to the shell through lib/bridge.ts (navigation, the 2P HUD, round results for
// tickets); a cabinet that can't talk gets a watcher instead (lib/watchers.ts, keyed by `watch`).
import { useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { installBridge, type BridgeNav, type Hud } from '@/lib/bridge'
import { watchRounds } from '@/lib/watchers'
import type { Game } from '@/lib/games'
import { Controls } from './Controls'
import { RailSection } from './Rail'

const NAV_ROUTES: Record<BridgeNav, string> = { home: '/', single: '/single', multiplayer: '/multiplayer', lobby: '/multiplayer/battleblitz' }

// The game pages all print their own help line under their canvas; the shell draws it in the rail
// instead, so hide theirs (same origin, so no change to the games — Battle Blitz stays untouched).
function hideInFrameHelp(frame: HTMLIFrameElement | null) {
  try {
    const d = frame?.contentDocument
    if (!d || d.getElementById('arcade-shell-style')) return
    const st = d.createElement('style')
    st.id = 'arcade-shell-style'
    st.textContent = '#help { display: none !important; }'
    d.head.appendChild(st)
  } catch { /* not ours to style */ }
}

export function GameFrame({ game, src = game.src, title, aspect = game.aspect ?? 1.45, watch }: { game: Game; src?: string; title: string; aspect?: number; watch?: string }) {
  const ref = useRef<HTMLIFrameElement>(null)
  const navigate = useNavigate()
  const [hud, setHud] = useState<Hud | null>(null)
  useEffect(() => installBridge(() => ref.current, { onNavigate: to => navigate(NAV_ROUTES[to] || '/'), onHud: setHud }), [navigate])
  useEffect(() => { ref.current?.focus() }, [src])
  useEffect(() => (watch ? watchRounds(watch, ref.current) : undefined), [watch, src])
  return (
    <div className="relative z-10 flex w-full flex-col items-center gap-4">
      {/* as wide as it can be while the whole game (plus the 2P bar, if any) still fits on screen */}
      <div className="frame w-full max-w-5xl" style={{ aspectRatio: String(aspect), maxWidth: `min(64rem, calc((100dvh - ${hud ? 10 : 7}rem) * ${aspect}))` }}>
        <iframe ref={ref} src={src} onLoad={() => hideInFrameHelp(ref.current)} title={title} className="block h-full w-full border-0 bg-black" allow="autoplay; gamepad; fullscreen" />
      </div>
      {hud && (
        <div className="flex flex-wrap items-center justify-center gap-3 rounded-full bg-arcade-pink px-4 py-1.5 text-sm font-bold tracking-[.04em] text-arcade-ink shadow-[0_4px_0_var(--color-arcade-pink-dark)]">
          <span><span className="mr-1.5 inline-block size-2.5 rounded-full bg-arcade-green align-[.05em]" />{hud.me}</span>
          {hud.status && <span className="rounded-full bg-arcade-yellow px-3 py-0.5 text-xs uppercase tracking-[.08em] shadow-[inset_0_-2px_0_var(--color-arcade-yellow-dark)]">{hud.status}</span>}
          <span><span className="mr-1.5 inline-block size-2.5 rounded-full bg-arcade-red align-[.05em]" />{hud.opp}</span>
          {hud.rtt && <span className="text-xs opacity-70">{hud.rtt}</span>}
        </div>
      )}
      <RailSection><Controls game={game} now={hud?.help} /></RailSection>
    </div>
  )
}
