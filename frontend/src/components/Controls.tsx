// How to play, for the rail beside a game: the controls as keycaps, stacked, plus the game's tip.
import { Mouse, MousePointerClick } from 'lucide-react'
import type { Game } from '@/lib/games'

const ARROWS = new Set(['←', '→', '↑', '↓'])

function Key({ k }: { k: string }) {
  if (k === 'click' || k === 'hold') {
    const Icon = k === 'click' ? MousePointerClick : Mouse
    return <kbd className="keycap keycap-wide"><Icon className="size-3.5" />{k}</kbd>
  }
  return <kbd className={ARROWS.has(k) ? 'keycap text-base' : k.length > 1 ? 'keycap keycap-wide' : 'keycap'}>{k}</kbd>
}

// Card-Jitsu's wheel: each element beats the next one round.
const ELEMENTS = [{ n: 'fire', img: 1 }, { n: 'snow', img: 3 }, { n: 'water', img: 2 }]
function ElementWheel() {
  return (
    <ul className="grid gap-1.5">
      {ELEMENTS.map((e, i) => {
        const next = ELEMENTS[(i + 1) % ELEMENTS.length]
        return (
          <li key={e.n} className="flex items-center gap-1.5 text-xs font-bold">
            <img src={`/img/cardjitsu/elem${e.img}.svg`} alt="" className="size-5" /><span className="capitalize">{e.n}</span>
            <span className="text-muted-foreground">beats</span>
            <img src={`/img/cardjitsu/elem${next.img}.svg`} alt="" className="size-5" /><span>{next.n}</span>
          </li>
        )
      })}
    </ul>
  )
}

// `now` is live guidance from the game itself (the 2P fighter select sends it over the bridge).
export function Controls({ game, now }: { game: Game; now?: string }) {
  return (
    <section className="m-1 rounded-2xl bg-arcade-navy-deep p-3.5 text-arcade-cream shadow-[0_0_0_5px_var(--color-arcade-pink),0_8px_0_5px_var(--color-arcade-pink-dark)]">
      <h2 className="mb-2.5 text-xs font-bold uppercase tracking-[.12em] text-arcade-yellow">How to play</h2>
      {now && <p className="mb-3 rounded-xl bg-arcade-yellow px-2.5 py-1.5 text-xs font-bold leading-snug text-arcade-ink shadow-[inset_0_-2px_0_var(--color-arcade-yellow-dark)]">{now}</p>}
      <ul className="grid gap-2">
        {game.controls.map((c, i) => (
          <li key={i} className="flex items-center gap-2 text-sm font-bold">
            <span className="flex shrink-0 gap-1">{c.keys.map(k => <Key key={k} k={k} />)}</span>
            <span className="leading-tight">{c.label}</span>
          </li>
        ))}
      </ul>
      {game.elements && <div className="mt-3 border-t-2 border-dashed border-arcade-grid pt-3"><ElementWheel /></div>}
      {game.tip && <p className="mt-3 border-t-2 border-dashed border-arcade-grid pt-2.5 text-xs leading-snug text-muted-foreground">{game.tip}</p>}
    </section>
  )
}
