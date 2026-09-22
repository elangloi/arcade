// The arcade's catalogue. Every cabinet is a separate static app served behind the proxy; the
// shell shows it inside a frame at its route. `mode` decides which menu it lives under.
export type GameMode = 'single' | 'multi'
export type ArtKind = 'blitz' | 'stack' | 'pizza' | 'cards' | 'blitz2p'

export interface Game {
  slug: string          // route segment in the shell (/single/:slug, /multiplayer/:slug)
  title: string
  subtitle?: string
  tag: string           // little plaque under the screen
  mode: GameMode
  art: ArtKind
  src: string           // where the proxy serves the game itself (used as the frame's src)
  help?: string         // one-line controls reminder shown under the frame
  aspect?: number       // the frame's width / height (the cabinet's own page decides its layout inside)
}

export const GAMES: Game[] = [
  { slug: 'battleblitz', title: 'Teen Titans', subtitle: 'Battle Blitz', tag: 'Cartoon Network · 2003', mode: 'single', art: 'blitz',
    src: '/teen-titans-battle-blitz/web/', aspect: 1.42, help: 'Arrows: move / jump · Down: block · Z: punch · X: kick · P: pause' },
  { slug: 'sandwichstacker', title: 'Lilo & Stitch', subtitle: '625 Sandwich Stacker', tag: 'Disney · 2003', mode: 'single', art: 'stack',
    src: '/lilo-and-stitch-sandwich-stacker/sandwichstacker/web/', aspect: 1.25, help: 'Mouse: move Reuben · catch the right ingredients' },
  { slug: 'pizzatron', title: 'Club Penguin', subtitle: 'Pizzatron 3000', tag: 'Disney · 2007', mode: 'single', art: 'pizza',
    src: '/club-penguin-pizzatron/pizzatron/web/', aspect: 1.3, help: 'Click an ingredient, drop it on the pizza · match the order before it leaves the belt' },
  { slug: 'cardjitsu', title: 'Club Penguin', subtitle: 'Card-Jitsu', tag: 'Disney · 2008', mode: 'single', art: 'cards',
    src: '/club-penguin-card-jitsu/cardjitsu/web/', aspect: 1.35, help: 'Click a card to play it · fire beats snow, snow beats water, water beats fire · same element: higher number wins' },
  { slug: 'battleblitz', title: 'Teen Titans', subtitle: 'Battle Blitz · 2P online', tag: 'Titans vs villains · best of 3', mode: 'multi', art: 'blitz2p',
    src: '/arcade/multiplayer/games/battleblitz/web/', help: 'Arrows: move / jump · Down: block · Z: punch · X: kick · Esc: leave the match' },
]

export const singlePlayer = () => GAMES.filter(g => g.mode === 'single')
export const multiplayer = () => GAMES.filter(g => g.mode === 'multi')
export const findGame = (mode: GameMode, slug?: string) => GAMES.find(g => g.mode === mode && g.slug === slug)
export const routeFor = (g: Game) => (g.mode === 'single' ? `/single/${g.slug}` : `/multiplayer/${g.slug}`)

// The multiplayer service (API + WebSocket + the 2P game). Same origin, behind the proxy prefix.
export const MP_BASE = '/arcade/multiplayer'
