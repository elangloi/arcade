// Tickets: what the machines pay out when a round ends. Kept in localStorage, so they're per browser
// and survive a reload. Nobody's guarding them — editing localStorage buys you prizes, and that's fine.
//
// Games don't decide their own payout. They report what happened (`arcade:round` over the frame
// bridge, see bridge.ts) and `ticketsFor` below turns that into tickets, so every rule is here.
import { useEffect, useState } from 'react'

// What a game reports at the end of a round. `game` is the cabinet's id; the rest depends on it.
export type RoundResult =
  | { game: 'battleblitz'; won: boolean; roundsWon: number }                         // one best-of-3 match
  | { game: 'battleblitz-2p'; won: boolean; reason: 'ko' | 'forfeit' | 'desync'; draw?: boolean }
  | { game: 'sandwichstacker'; score: number }                                       // lives ran out
  | { game: 'pizzatron'; pizzas: number; ending: 'lame' | 'lose' | 'win' | 'perfect' }
  | { game: 'cardjitsu'; won: boolean; beltUp: boolean }

export interface Payout { game: string; tickets: number; reason: string }

export function ticketsFor(r: RoundResult): Payout {
  switch (r.game) {
    // A match is best of 3 against the CPU: a ticket for every round you take, 3 more for the match.
    case 'battleblitz': {
      const n = Math.max(1, r.roundsWon + (r.won ? 3 : 0))
      return { game: r.game, tickets: n, reason: r.won ? 'match won' : 'match over' }
    }
    // Beating a person pays better than beating the CPU; a desync doesn't count for either side.
    case 'battleblitz-2p': {
      if (r.reason === 'desync') return { game: r.game, tickets: 0, reason: 'out of sync' }
      if (r.draw) return { game: r.game, tickets: 2, reason: 'draw' }
      if (r.reason === 'forfeit') return { game: r.game, tickets: r.won ? 3 : 0, reason: r.won ? 'win by forfeit' : 'forfeit' }
      return { game: r.game, tickets: r.won ? 6 : 2, reason: r.won ? 'KO win' : 'good fight' }
    }
    // Endless: stacking a 10-high sandwich is ~275 points, an extra life every 1000.
    case 'sandwichstacker': {
      const n = Math.min(20, 1 + Math.floor(r.score / 250))
      return { game: r.game, tickets: n, reason: `${r.score} points` }
    }
    // A shift is 40 orders (5 mistakes and you're out): a ticket per 4 good pizzas, 5 more for a perfect shift.
    case 'pizzatron': {
      const n = 1 + Math.floor(r.pizzas / 4) + (r.ending === 'perfect' ? 5 : 0)
      return { game: r.game, tickets: n, reason: r.ending === 'perfect' ? 'perfect shift' : `${r.pizzas} pizzas` }
    }
    // One match against the Sensei; a new belt is worth a bonus.
    case 'cardjitsu': {
      const n = (r.won ? 4 : 1) + (r.beltUp ? 3 : 0)
      return { game: r.game, tickets: n, reason: r.beltUp ? 'new belt' : r.won ? 'Sensei beaten' : 'match over' }
    }
  }
}

type Listener = (total: number, last: Payout) => void   // last.tickets < 0 for a spend

const KEY = 'arcade.tickets.v1'

class Tickets {
  private total = (() => { try { return Math.max(0, Math.floor(Number(localStorage.getItem(KEY)) || 0)) } catch { return 0 } })()
  private save() { try { localStorage.setItem(KEY, String(this.total)) } catch { /* private mode etc. */ } }
  private listeners = new Set<Listener>()
  balance() { return this.total }
  award(p: Payout) {
    if (!(p.tickets > 0)) return this.total
    this.total += Math.floor(p.tickets)
    this.save()
    for (const fn of this.listeners) fn(this.total, p)
    return this.total
  }
  // Trading tickets in at the prize counter. False (and nothing spent) when the balance can't cover it.
  spend(amount: number, reason: string) {
    if (!(amount > 0) || amount > this.total) return false
    this.total -= Math.floor(amount)
    this.save()
    for (const fn of this.listeners) fn(this.total, { game: 'prizes', tickets: -Math.floor(amount), reason })
    return true
  }
  subscribe(fn: Listener) { this.listeners.add(fn); return () => { this.listeners.delete(fn) } }
}

export const tickets = new Tickets()

// Runs the rules and credits the result. Unknown games (or malformed reports) pay nothing.
export function awardRound(r: RoundResult): Payout | null {
  try {
    const p = ticketsFor(r)
    if (!p) return null
    tickets.award(p)
    return p
  } catch { return null }
}

// The running total, plus a counter that ticks on every payout (handy as a key to replay animations).
export function useTickets() {
  const [state, setState] = useState(() => ({ total: tickets.balance(), seq: 0 }))
  useEffect(() => tickets.subscribe(total => setState(s => ({ total, seq: s.seq + 1 }))), [])
  return state
}
