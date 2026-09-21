// A cabinet, playing: the game's own page inside a bezel, with the controls line under it.
// The frame talks to the shell through lib/bridge.ts (navigation, the 2P HUD, and coins later).
import { useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { installBridge, type BridgeNav, type Hud } from '@/lib/bridge'

const NAV_ROUTES: Record<BridgeNav, string> = { home: '/', single: '/single', multiplayer: '/multiplayer', lobby: '/multiplayer/battleblitz' }

export function GameFrame({ src, title, help, aspect = 1.45 }: { src: string; title: string; help?: string; aspect?: number }) {
  const ref = useRef<HTMLIFrameElement>(null)
  const navigate = useNavigate()
  const [hud, setHud] = useState<Hud | null>(null)
  useEffect(() => installBridge(() => ref.current, { onNavigate: to => navigate(NAV_ROUTES[to] || '/'), onHud: setHud }), [navigate])
  useEffect(() => { ref.current?.focus() }, [src])
  return (
    <div className="relative z-10 flex w-full flex-col items-center gap-4">
      <div className="frame w-full max-w-5xl" style={{ aspectRatio: String(aspect) }}>
        <iframe ref={ref} src={src} title={title} className="block h-full w-full border-0 bg-black" allow="autoplay; gamepad; fullscreen" />
      </div>
      {hud && (
        <div className="flex flex-wrap items-center justify-center gap-3 rounded-full bg-arcade-pink px-4 py-1.5 text-sm font-bold tracking-[.04em] text-arcade-ink shadow-[0_4px_0_var(--color-arcade-pink-dark)]">
          <span><span className="mr-1.5 inline-block size-2.5 rounded-full bg-arcade-green align-[.05em]" />{hud.me}</span>
          {hud.status && <span className="rounded-full bg-arcade-yellow px-3 py-0.5 text-xs uppercase tracking-[.08em] shadow-[inset_0_-2px_0_var(--color-arcade-yellow-dark)]">{hud.status}</span>}
          <span><span className="mr-1.5 inline-block size-2.5 rounded-full bg-arcade-red align-[.05em]" />{hud.opp}</span>
          {hud.rtt && <span className="text-xs opacity-70">{hud.rtt}</span>}
        </div>
      )}
      <p className="min-h-5 text-center text-xs font-bold uppercase tracking-[.08em] text-arcade-pink">{hud?.help || help}</p>
    </div>
  )
}
