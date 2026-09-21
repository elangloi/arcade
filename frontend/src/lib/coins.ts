// Coins: the arcade-wide currency. Not a feature yet — this is the seam it will grow through.
//
// Today: one wallet per browser, kept in localStorage, credited by nothing (games don't earn yet).
// Later: swap `LocalCoinProvider` for one backed by the multiplayer service (SQLite `wallets` +
// `ledger` tables keyed by session/player, endpoints under /arcade/multiplayer/api/coins) and let
// the games post `arcade:coins:earn` through the frame bridge (see bridge.ts). The React side only
// ever talks to `coins` through the CoinProvider interface, so nothing above this file changes.
import { useEffect, useState } from 'react'

export interface LedgerEntry {
  at: number
  game: string        // game slug, or 'arcade' for the shell itself
  amount: number      // positive = earned, negative = spent
  reason: string      // 'ko', 'high-score', 'continue', 'unlock:xyz' …
}

export interface CoinProvider {
  balance(): number
  earn(game: string, amount: number, reason: string): number
  spend(game: string, amount: number, reason: string): number   // throws when the wallet can't cover it
  history(): LedgerEntry[]
  subscribe(fn: (balance: number) => void): () => void
}

const KEY = 'arcade.coins.v1'

class LocalCoinProvider implements CoinProvider {
  private ledger: LedgerEntry[] = []
  private listeners = new Set<(b: number) => void>()

  constructor() {
    try { this.ledger = JSON.parse(localStorage.getItem(KEY) || '[]') } catch { this.ledger = [] }
  }
  balance() { return this.ledger.reduce((n, e) => n + e.amount, 0) }
  earn(game: string, amount: number, reason: string) {
    if (!(amount > 0)) throw new Error('earn: amount must be positive')
    return this.push({ at: Date.now(), game, amount: Math.floor(amount), reason })
  }
  spend(game: string, amount: number, reason: string) {
    if (!(amount > 0)) throw new Error('spend: amount must be positive')
    if (this.balance() < amount) throw new Error('not enough coins')
    return this.push({ at: Date.now(), game, amount: -Math.floor(amount), reason })
  }
  history() { return this.ledger.slice() }
  subscribe(fn: (b: number) => void) { this.listeners.add(fn); return () => { this.listeners.delete(fn) } }
  private push(e: LedgerEntry) {
    this.ledger.push(e)
    try { localStorage.setItem(KEY, JSON.stringify(this.ledger.slice(-500))) } catch { /* private mode etc. */ }
    const b = this.balance()
    for (const fn of this.listeners) fn(b)
    return b
  }
}

export const coins: CoinProvider = new LocalCoinProvider()

export function useCoins() {
  const [balance, setBalance] = useState(() => coins.balance())
  useEffect(() => coins.subscribe(setBalance), [])
  return balance
}
