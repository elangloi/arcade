// The arcade's catalogue. Every cabinet is a separate static app served behind the proxy; the
// shell shows it inside a frame at its route. `mode` decides which menu it lives under.
export type GameMode = 'single' | 'multi'
export type ArtKind = 'blitz' | 'stack' | 'pizza' | 'cards' | 'blitz2p'

// How to play, drawn as keycaps in the rail beside the frame. A key is its label ('Z', '←', 'Esc');
// 'click' and 'hold' are mouse actions.
export interface Control { keys: string[]; label: string }

export interface Game {
  slug: string          // route segment in the shell (/single/:slug, /multiplayer/:slug)
  title: string
  subtitle?: string
  tag: string           // little plaque under the screen
  mode: GameMode
  art: ArtKind
  src: string           // where the proxy serves the game itself (used as the frame's src)
  controls: Control[]
  tip?: string          // one more line under the controls
  elements?: boolean    // Card-Jitsu: show the fire / snow / water wheel
  aspect?: number       // the frame's width / height (the cabinet's own page decides its layout inside)
}

const FIGHT: Control[] = [
  { keys: ['←', '→'], label: 'move' }, { keys: ['↑'], label: 'jump' }, { keys: ['↓'], label: 'block' },
  { keys: ['Z'], label: 'punch' }, { keys: ['X'], label: 'kick' },
]

export const GAMES: Game[] = [
  { slug: 'battleblitz', title: 'Teen Titans', subtitle: 'Battle Blitz', tag: 'Cartoon Network · 2003', mode: 'single', art: 'blitz',
    src: '/teen-titans-battle-blitz/web/', aspect: 1.42,
    controls: [...FIGHT, { keys: ['P'], label: 'pause' }, { keys: ['Esc'], label: 'back to select' }], tip: 'Best of 3 rounds. Land combos to summon a teammate.' },
  { slug: 'sandwichstacker', title: 'Lilo & Stitch', subtitle: '625 Sandwich Stacker', tag: 'Disney · 2003', mode: 'single', art: 'stack',
    src: '/lilo-and-stitch-sandwich-stacker/sandwichstacker/web/', aspect: 1.25,
    controls: [{ keys: ['←', '→'], label: "move Reuben's plate" }, { keys: ['Space'], label: 'next level' }], tip: 'Catch the good stuff, dodge the rotten stuff, finish with bread.' },
  { slug: 'pizzatron', title: 'Club Penguin', subtitle: 'Pizzatron 3000', tag: 'Disney · 2007', mode: 'single', art: 'pizza',
    src: '/club-penguin-pizzatron/pizzatron/web/', aspect: 1.3,
    controls: [{ keys: ['click'], label: 'pick up an ingredient' }, { keys: ['hold'], label: 'spread the sauce' }, { keys: ['click'], label: 'drop it on the pizza' }],
    tip: 'Match the order before the pizza leaves the belt. Five mistakes ends the shift.' },
  { slug: 'cardjitsu', title: 'Club Penguin', subtitle: 'Card-Jitsu', tag: 'Disney · 2008', mode: 'single', art: 'cards',
    src: '/club-penguin-card-jitsu/cardjitsu/web/', aspect: 1.35, elements: true,
    controls: [{ keys: ['click'], label: 'play a card' }], tip: 'Same element: the higher number wins. Win three of one element in three colours, or one of each element in three colours.' },
  { slug: 'battleblitz', title: 'Teen Titans', subtitle: 'Battle Blitz · 2P online', tag: 'Titans vs villains · best of 3', mode: 'multi', art: 'blitz2p',
    src: '/arcade/multiplayer/games/battleblitz/web/', controls: [...FIGHT, { keys: ['Esc'], label: 'leave the match' }], tip: 'Best of 3 rounds.' },
]

export const singlePlayer = () => GAMES.filter(g => g.mode === 'single')
export const multiplayer = () => GAMES.filter(g => g.mode === 'multi')
export const findGame = (mode: GameMode, slug?: string) => GAMES.find(g => g.mode === mode && g.slug === slug)
export const routeFor = (g: Game) => (g.mode === 'single' ? `/single/${g.slug}` : `/multiplayer/${g.slug}`)

// The multiplayer service (API + WebSocket + the 2P game). Same origin, behind the proxy prefix.
export const MP_BASE = '/arcade/multiplayer'
