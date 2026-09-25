// The prize counter: trade tickets for claw pets, sparkle flavours and fortune cookies (lib/prizes.ts).
import { useState, type ReactNode } from 'react'
import { Check } from 'lucide-react'
import { Heart, Sprinkles, Star } from '@/components/Deco'
import { Doodle, FortuneCookie, PetBadge } from '@/components/Doodles'
import { RailSection, RailTitle } from '@/components/Rail'
import { PRIZES, prizes, usePrizes, type Prize, type SparkleFlavor } from '@/lib/prizes'
import { useTickets } from '@/lib/tickets'
import { cn } from '@/lib/utils'

const C = (n: string) => `var(--color-arcade-${n})`

// five of the flavour's sparkles in a little arc
function SparklePreview({ flavor }: { flavor: SparkleFlavor }) {
  if (flavor === 'confetti') return (
    <div className="flex items-end gap-0.5">{[7, 0, 9, 2, 5].map((d, i) => <Doodle key={i} i={d} className={cn('size-7', i % 2 ? '-translate-y-2 rotate-12' : '-rotate-6')} />)}</div>
  )
  const at = [{ x: 8, y: 28, r: -20 }, { x: 26, y: 12, r: 10 }, { x: 46, y: 22, r: -6 }, { x: 64, y: 8, r: 18 }, { x: 80, y: 26, r: -14 }]
  return (
    <svg viewBox="0 0 96 44" className="h-12 w-24" aria-hidden="true">
      {at.map((p, i) => {
        const t = `translate(${p.x} ${p.y}) rotate(${p.r})`
        if (flavor === 'coins') return <g key={i} transform={t}><circle cx="6" cy="6" r="6" fill={C('yellow')} stroke={C('yellow-dark')} strokeWidth="2" /><circle cx="6" cy="6" r="3" fill="none" stroke={C('yellow-dark')} strokeWidth="1" /></g>
        const color = flavor === 'rainbow' ? C(['red', 'yellow', 'green', 'blue', 'pink'][i]) : flavor === 'hearts' ? C(i % 2 ? 'red' : 'pink') : C(['yellow', 'pink', 'yellow', 'blue', 'pink'][i])
        const Shape = flavor === 'hearts' || (flavor === 'classic' && i === 3) ? Heart : Star
        return <g key={i} transform={t} color={color}><Shape width="14" height="14" /></g>
      })}
    </svg>
  )
}

function art(p: Prize, cracked: boolean) {
  if (p.kind === 'pet') return <PetBadge kind={p.pet} className="h-16 w-16" />
  if (p.kind === 'sparkle') return <SparklePreview flavor={p.flavor} />
  return <FortuneCookie cracked={cracked} className="h-14 w-20" />
}

const Price = ({ n }: { n: number }) => <><span className="tabular-nums">{n}</span> tix</>

function PrizeTile({ p }: { p: Prize }) {
  const { total } = useTickets()
  const s = usePrizes()
  const [pop, setPop] = useState(0)
  const owned = p.kind !== 'fortune' && s.owned.has(p.id)
  const using = (p.kind === 'sparkle' && s.sparkle === p.flavor) || (p.kind === 'pet' && s.pet === p.pet)
  const short = owned ? 0 : p.price - total
  const act = () => { if (prizes.buy(p)) setPop(n => n + 1) }

  let button: ReactNode
  if (using) button = <button className="arcade-btn arcade-btn-ghost prize-btn" onClick={p.kind === 'pet' ? act : undefined} disabled={p.kind !== 'pet'} title={p.kind === 'pet' ? 'Put it down' : undefined}><Check className="size-3.5" />{p.kind === 'pet' ? 'Holding' : 'On'}</button>
  else if (owned) button = <button className="arcade-btn arcade-btn-go prize-btn" onClick={act}>{p.kind === 'pet' ? 'Hold' : 'Use'}</button>
  else if (short > 0) button = <button className="arcade-btn prize-btn" disabled><Price n={p.price} /></button>
  else button = <button className="arcade-btn prize-btn" onClick={act}>{p.kind === 'fortune' ? 'Crack · ' : 'Trade · '}<Price n={p.price} /></button>

  return (
    <li key={pop} className={cn('prize-tile', pop > 0 && 'prize-pop', using && 'prize-using')}>
      <div className="grid h-16 place-items-center">{art(p, p.kind === 'fortune' && pop > 0)}</div>
      <p className="font-bold">{p.name}</p>
      <p className="mb-2.5 min-h-8 text-[.7rem] leading-tight text-arcade-ink/60">{p.blurb}</p>
      {button}
      {short > 0 && <p className="mt-1.5 text-[.62rem] font-bold uppercase tracking-[.08em] text-arcade-pink-dark">{short} more to go</p>}
    </li>
  )
}

function Shelf({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="relative z-10 mb-10 w-full last:mb-0">
      <h2 className="arcade-title mb-5 flex items-center gap-2 text-[1.9rem]"><Star className="size-5 text-arcade-pink" />{title}</h2>
      <ul className="grid grid-cols-[repeat(auto-fill,minmax(9rem,1fr))] gap-4">{children}</ul>
    </section>
  )
}

export default function Prizes() {
  const { total } = useTickets()
  const s = usePrizes()
  const shelf = (kind: Prize['kind']) => PRIZES.filter(p => p.kind === kind).map(p => <PrizeTile key={p.id} p={p} />)
  return (
    <>
      <Sprinkles />
      <RailSection>
        <RailTitle>Prize counter</RailTitle>
        <p className="ticket-badge"><span className="ticket-stub" aria-hidden="true">TICKET</span><span className="tabular-nums">{total}</span><span className="sr-only"> tickets</span></p>
      </RailSection>
      <div className="w-full max-w-5xl">
        <Shelf title="Claw pets">{shelf('pet')}</Shelf>
        <Shelf title="Sparkle flavours">{shelf('sparkle')}</Shelf>
        <Shelf title="Fortune cookies">
          {shelf('fortune')}
          {s.fortune && (
            <li key={s.cookies} className="fortune-slip col-span-full self-start sm:col-[span_2]">
              <span className="text-[.62rem] font-bold uppercase tracking-[.12em] text-arcade-red-dark">your fortune</span>
              <p className="font-bold leading-snug">“{s.fortune}”</p>
            </li>
          )}
        </Shelf>
      </div>
    </>
  )
}
