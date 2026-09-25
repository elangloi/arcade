// The ticket counter in the header. When a machine pays out it bumps, and a heart pops out under it: +N tickets!
import { useEffect, useState } from 'react'
import { GAMES } from '@/lib/games'
import { tickets, useTickets, type Payout } from '@/lib/tickets'
import { cn } from '@/lib/utils'
import { Heart } from './Deco'

const gameName = (id: string) => {
  const g = GAMES.find(x => x.slug === id.replace(/-2p$/, '') && (id.endsWith('-2p') ? x.mode === 'multi' : x.mode === 'single'))
  return g?.subtitle?.replace(/ · .*/, '') ?? g?.title ?? id
}

export function TicketCounter() {
  const { total, seq } = useTickets()
  const [slip, setSlip] = useState<(Payout & { id: number }) | null>(null)
  useEffect(() => tickets.subscribe((_total, p) => { if (p.tickets > 0) setSlip({ ...p, id: Date.now() }) }), [])   // wins only, not spending
  useEffect(() => {
    if (!slip) return
    const h = setTimeout(() => setSlip(null), 3200)
    return () => clearTimeout(h)
  }, [slip])

  return (
    <span className="relative">
      <span key={seq} title="Your tickets — trade them in at the prize counter" aria-live="polite" className={cn('ticket-badge', seq > 0 && 'ticket-bump')}>
        <span className="ticket-stub" aria-hidden="true">TICKET</span>
        <span className="tabular-nums">{total}</span>
        <span className="sr-only"> tickets</span>
      </span>
      {slip && (
        <span key={slip.id} className="ticket-heart" role="status" title={`${gameName(slip.game)} · ${slip.reason}`}>
          <Heart className="ticket-heart-shape" />
          <b>+{slip.tickets}</b>
          <span className="ticket-heart-label">{slip.tickets === 1 ? 'ticket!' : 'tickets!'}</span>
        </span>
      )}
    </span>
  )
}
