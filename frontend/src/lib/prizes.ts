// The prize counter's stock and what you've traded for. Like tickets, kept in localStorage (per
// browser, survives a reload); everything here is cosmetic and lives in the shell.
import { useSyncExternalStore } from 'react'
import { tickets } from './tickets'

export type SparkleFlavor = 'classic' | 'hearts' | 'coins' | 'rainbow' | 'confetti'
export type PetKind = 'bear' | 'bunny' | 'dog' | 'cat'

export type Prize =
  | { id: string; kind: 'sparkle'; name: string; blurb: string; price: number; flavor: SparkleFlavor }
  | { id: string; kind: 'pet'; name: string; blurb: string; price: number; pet: PetKind }
  | { id: string; kind: 'fortune'; name: string; blurb: string; price: number }

export const PRIZES: Prize[] = [
  { id: 'sparkle:classic', kind: 'sparkle', flavor: 'classic', name: 'Classic', blurb: 'stars and the odd heart', price: 0 },
  { id: 'sparkle:hearts', kind: 'sparkle', flavor: 'hearts', name: 'Hearts', blurb: 'nothing but love', price: 8 },
  { id: 'sparkle:coins', kind: 'sparkle', flavor: 'coins', name: 'Coins', blurb: 'make it rain', price: 10 },
  { id: 'sparkle:rainbow', kind: 'sparkle', flavor: 'rainbow', name: 'Rainbow', blurb: 'stars in every colour', price: 12 },
  { id: 'sparkle:confetti', kind: 'sparkle', flavor: 'confetti', name: 'Confetti', blurb: 'doodle stickers everywhere', price: 15 },
  { id: 'fortune', kind: 'fortune', name: 'Fortune cookie', blurb: 'ancient wisdom, probably', price: 5 },
  { id: 'pet:bear', kind: 'pet', pet: 'bear', name: 'Bear', blurb: 'a big soft hug', price: 25 },
  { id: 'pet:bunny', kind: 'pet', pet: 'bunny', name: 'Bunny', blurb: 'all ears', price: 25 },
  { id: 'pet:dog', kind: 'pet', pet: 'dog', name: 'Pup', blurb: 'very good', price: 25 },
  { id: 'pet:cat', kind: 'pet', pet: 'cat', name: 'Kitty', blurb: 'judging you, lovingly', price: 30 },
]

// The weirdest real fortunes people have found in their cookies (collected off the internet).
const FORTUNES = [
  'That wasn\'t chicken.',
  'You are not illiterate.',
  'Life difficult.',
  'You laugh now, wait till you get home.',
  'Tomorrow morning, take a left turn as soon as you leave home.',
  'Some fortune cookies contain no fortune.',
  'About time I got out of that cookie.',
  'You will live long enough to become a burden to your children, if you haven\'t already.',
  'Come back later… I am sleeping.',
]

interface State { owned: ReadonlySet<string>; sparkle: SparkleFlavor; pet: PetKind | null; fortune: string | null; cookies: number }

const KEY = 'arcade.prizes.v1'
const DEFAULT: State = { owned: new Set(['sparkle:classic']), sparkle: 'classic', pet: null, fortune: null, cookies: 0 }

function load(): State {
  try {
    const j = JSON.parse(localStorage.getItem(KEY) || 'null')
    if (!j) return DEFAULT
    const owned = new Set<string>(['sparkle:classic', ...(Array.isArray(j.owned) ? j.owned : [])].filter(id => PRIZES.some(p => p.id === id)))
    const has = (id: string) => owned.has(id)
    return {
      owned,
      sparkle: has(`sparkle:${j.sparkle}`) ? j.sparkle : 'classic',
      pet: j.pet && has(`pet:${j.pet}`) ? j.pet : null,
      fortune: typeof j.fortune === 'string' ? j.fortune : null,
      cookies: Number(j.cookies) || 0,
    }
  } catch { return DEFAULT }
}

let state: State = load()
const listeners = new Set<() => void>()
const set = (patch: Partial<State>) => {
  state = { ...state, ...patch }
  try { localStorage.setItem(KEY, JSON.stringify({ ...state, owned: [...state.owned] })) } catch { /* private mode etc. */ }
  for (const fn of listeners) fn()
}

export const prizes = {
  get: () => state,
  subscribe(fn: () => void) { listeners.add(fn); return () => { listeners.delete(fn) } },

  // Trade tickets for a prize. Sparkles and pets are kept (and put straight on); a cookie is eaten.
  buy(p: Prize) {
    if (p.kind !== 'fortune' && state.owned.has(p.id)) { this.use(p); return true }
    if (p.price > 0 && !tickets.spend(p.price, p.name)) return false
    if (p.kind === 'fortune') {
      let f: string
      do f = FORTUNES[Math.floor(Math.random() * FORTUNES.length)]; while (f === state.fortune && FORTUNES.length > 1)
      set({ fortune: f, cookies: state.cookies + 1 })
      return true
    }
    set({ owned: new Set([...state.owned, p.id]) })
    this.use(p)
    return true
  },

  use(p: Prize) {
    if (p.kind === 'sparkle') set({ sparkle: p.flavor })
    else if (p.kind === 'pet') set({ pet: state.pet === p.pet ? null : p.pet })   // using the one it's holding puts it down
  },
}

export function usePrizes() {
  return useSyncExternalStore(prizes.subscribe, prizes.get)
}
