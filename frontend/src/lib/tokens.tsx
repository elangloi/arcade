// Tokens: the cup on the left rail. Put a token in a machine (click the machine, or drag a token onto
// it) and it flies out of the cup, drops into the coin slot, and the machine starts.
//
// Free play for now: the cup never runs out. The drag-and-drop half is react-dnd (provider in
// App.tsx); this file is the part both halves share — the flight animation, the clink, and the
// navigation once the token lands.
import { createContext, useCallback, useContext, useMemo, useRef, type ReactNode, type RefObject } from 'react'
import { useNavigate } from 'react-router-dom'

export const TOKEN = 'token'   // react-dnd item type

type Point = { x: number; y: number }

interface TokenApi {
  cupRef: RefObject<HTMLElement | null>   // the top token in the cup: where clicked tokens fly from
  insert(o: { cabinet: HTMLElement; to: string; from?: Point }): void
  putBack(from: Point | null): void        // a drag that missed every machine
}

const Ctx = createContext<TokenApi | null>(null)

export function useTokens() {
  const api = useContext(Ctx)
  if (!api) throw new Error('useTokens outside <TokenProvider>')
  return api
}

const reducedMotion = () => matchMedia('(prefers-reduced-motion: reduce)').matches
const centre = (el: Element | null | undefined): Point | null => {
  if (!el) return null
  const r = el.getBoundingClientRect()
  return { x: r.left + r.width / 2, y: r.top + r.height / 2 }
}

// One token in flight: an arc from `from` to `to` (a quadratic curve, sampled into keyframes), then
// for a coin slot it turns edge-on and drops through it. Resolves when it's gone.
function fly(from: Point, to: Point, into: 'slot' | 'cup') {
  const el = document.createElement('div')
  el.className = 'token token-flight'
  el.innerHTML = '<svg class="token-star" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 1.5 14.6 9.4 22.5 12 14.6 14.6 12 22.5 9.4 14.6 1.5 12 9.4 9.4Z" fill="currentColor"/></svg>'
  el.style.left = `${from.x}px`
  el.style.top = `${from.y}px`
  document.body.appendChild(el)

  const dx = to.x - from.x, dy = to.y - from.y
  const lift = Math.min(150, 40 + Math.hypot(dx, dy) * 0.3)
  const cx = dx / 2, cy = Math.min(0, dy) - lift              // control point, relative to `from`
  const at = (t: number) => ({ x: 2 * (1 - t) * t * cx + t * t * dx, y: 2 * (1 - t) * t * cy + t * t * dy })
  const tf = (p: Point, rest: string) => `translate(-50%, -50%) translate(${p.x}px, ${p.y}px) ${rest}`

  const arc = [0, 0.2, 0.4, 0.6, 0.8, 1].map((t, i) => ({
    offset: into === 'slot' ? t * 0.7 : t,
    transform: tf(at(t), `rotate(${-720 * t}deg) scale(${1 + 0.25 * Math.sin(Math.PI * t) - (into === 'cup' ? 0.2 * t : 0)})`),
    easing: i === 0 ? 'ease-out' : 'linear',
  }))
  arc[arc.length - 1].easing = 'ease-out'
  const frames: Keyframe[] = into === 'slot'
    ? [
        ...arc,
        { offset: 0.8, transform: tf({ x: dx, y: dy - 18 }, 'rotate(-720deg) scaleX(.16) scaleY(.95)'), opacity: 1, easing: 'ease-in' },   // edge-on above the slot
        { offset: 0.9, transform: tf({ x: dx, y: dy - 4 }, 'rotate(-720deg) scaleX(.16) scaleY(.9)'), opacity: 1, easing: 'ease-in' },
        { offset: 1, transform: tf({ x: dx, y: dy + 10 }, 'rotate(-720deg) scaleX(.16) scaleY(.6)'), opacity: 0 },     // and through it
      ]
    : [...arc.slice(0, -1), { ...arc[arc.length - 1], opacity: 0 }]
  const duration = into === 'slot' ? 720 : 420
  const anim = el.animate(frames, { duration, fill: 'forwards' })
  // a hidden tab never runs the animation clock, so don't let the machine wait on it forever
  const late = new Promise(done => setTimeout(done, duration + 400))
  return Promise.race([anim.finished.catch(() => {}), late]).then(() => el.remove())
}

// A little coin-in-the-machine clink, synthesized so there's no asset to ship.
let audio: AudioContext | null = null
function clink() {
  try {
    audio ??= new AudioContext()
    const t = audio.currentTime
    const ping = (freq: number, at: number, dur: number, vol: number, type: OscillatorType = 'sine') => {
      const o = audio!.createOscillator(), g = audio!.createGain()
      o.type = type; o.frequency.value = freq
      g.gain.setValueAtTime(vol, t + at)
      g.gain.exponentialRampToValueAtTime(0.0001, t + at + dur)
      o.connect(g).connect(audio!.destination)
      o.start(t + at); o.stop(t + at + dur)
    }
    ping(2349, 0, 0.18, 0.08); ping(3136, 0.05, 0.22, 0.06); ping(140, 0.12, 0.12, 0.12, 'triangle')
  } catch { /* no audio: fine */ }
}

export function TokenProvider({ children }: { children: ReactNode }) {
  const navigate = useNavigate()
  const cupRef = useRef<HTMLElement | null>(null)
  const busy = useRef(false)

  const insert = useCallback<TokenApi['insert']>(({ cabinet, to, from }) => {
    if (busy.current) return
    const slot = cabinet.querySelector('.coinslot')
    const start = from ?? centre(cupRef.current)
    const r = slot?.getBoundingClientRect()
    if (!r || !start || reducedMotion()) { clink(); navigate(to); return }
    busy.current = true
    cabinet.classList.add('inserting')
    // a click takes the top token off the pile: the next one rises into its place
    if (!from) cupRef.current?.animate([{ opacity: 0, translate: '0 18px' }, { opacity: 1, translate: '0 0' }], { duration: 380, delay: 220, easing: 'ease-out', fill: 'backwards' })
    fly(start, { x: r.left + r.width / 2, y: r.top + r.height / 2 }, 'slot').then(() => {
      clink()
      cabinet.classList.remove('inserting')
      cabinet.classList.add('clunk')
      setTimeout(() => { busy.current = false; navigate(to) }, 280)
    })
  }, [navigate])

  const putBack = useCallback<TokenApi['putBack']>(from => {
    const home = centre(cupRef.current)
    if (!from || !home || reducedMotion()) return
    fly(from, home, 'cup')
  }, [])

  const api = useMemo(() => ({ cupRef, insert, putBack }), [insert, putBack])
  return <Ctx.Provider value={api}>{children}</Ctx.Provider>
}
