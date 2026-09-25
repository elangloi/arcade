// The ticket counter in the header. When a machine pays out it bumps, and a "+N" slip drops out under it.
import { useEffect, useState } from 'react'
import { GAMES } from '@/lib/games'
import { tickets, useTickets, type Payout } from '@/lib/tickets'
import { cn } from '@/lib/utils'

const gameName = (id: string) => {
  const g = GAMES.find(x => x.slug === id.replace(/-2p$/, '') && (id.endsWith('-2p') ? x.mode === 'multi' : x.mode === 'single'))
  return g?.subtitle?.replace(/ · .*/, '') ?? g?.title ?? id
}

export function TicketCounter() {
  const { total, seq } = useTickets()
  const [slip, setSlip] = useState<(Payout & { id: number }) | null>(null)
  useEffect(() => tickets.subscribe((_total, p) => setSlip({ ...p, id: Date.now() })), [])
  useEffect(() => {
    if (!slip) return
    const h = setTimeout(() => setSlip(null), 3200)
    return () => clearTimeout(h)
  }, [slip])

  return (
    <span className="relative">
      <span key={seq} title="Tickets won this visit" aria-live="polite" className={cn('ticket-badge', seq > 0 && 'ticket-bump')}>
        <span className="ticket-stub" aria-hidden="true">ADMIT<br />ONE</span>
        <span className="tabular-nums">{total}</span>
        <span className="sr-only"> tickets</span>
      </span>
      {slip && (
        <span key={slip.id} className="ticket-slip" role="status">
          <b>+{slip.tickets}</b> {slip.tickets === 1 ? 'ticket' : 'tickets'}
          <small>{gameName(slip.game)} · {slip.reason}</small>
        </span>
      )}
    </span>
  )
}
