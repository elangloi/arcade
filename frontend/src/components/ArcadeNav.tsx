import { Link, useLocation } from 'react-router-dom'
import { ChevronDown, Gamepad2, Gift, Swords, Users } from 'lucide-react'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel, DropdownMenuSeparator,
  DropdownMenuSub, DropdownMenuSubContent, DropdownMenuSubTrigger, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { GAMES, routeFor, singlePlayer, multiplayer, type Game } from '@/lib/games'
import { Star } from './Deco'
import { TicketCounter } from './TicketCounter'

// Where are we? Turns the route into breadcrumbs for the bar. The Arcade button already means
// "home", so the trail starts at the section: Single player › Game (› Fight).
function crumbs(pathname: string): { label: string; to: string }[] {
  const out: { label: string; to: string }[] = []
  const [, section, slug, sub] = pathname.split('/')
  if (section === 'single') out.push({ label: 'Single player', to: '/single' })
  if (section === 'multiplayer') out.push({ label: 'Multiplayer', to: '/multiplayer' })
  if (section === 'prizes') out.push({ label: 'Prize counter', to: '/prizes' })
  const g = GAMES.find(x => x.mode === (section === 'single' ? 'single' : 'multi') && x.slug === slug)
  if (g) out.push({ label: g.subtitle ? `${g.title} ${g.subtitle}` : g.title, to: routeFor(g) })
  if (g && sub === 'play') out.push({ label: 'Fight', to: pathname })
  return out
}

function GameItem({ g }: { g: Game }) {
  return (
    <DropdownMenuItem asChild>
      <Link to={routeFor(g)} className="cursor-pointer">
        <span className="font-bold">{g.title}</span>
        {g.subtitle && <span className="text-arcade-ink/60 text-xs">{g.subtitle}</span>}
      </Link>
    </DropdownMenuItem>
  )
}

export function ArcadeNav() {
  const { pathname } = useLocation()
  const trail = crumbs(pathname)

  return (
    <header className="fixed inset-x-0 top-0 z-50 h-12 bg-arcade-pink text-arcade-ink shadow-[0_4px_0_var(--color-arcade-pink-dark),0_8px_18px_rgba(0,0,0,.35)]">
      <div className="mx-auto flex h-full max-w-6xl items-center gap-2 px-3">
        {/* split button: "Arcade" goes to the front of house, the chevron opens the game menus */}
        <div className="flex h-9 shrink-0 items-stretch rounded-full bg-arcade-navy-deep text-arcade-yellow shadow-[inset_0_-3px_0_#0d0f30]">
          <Link to="/" className="flex items-center gap-1.5 rounded-l-full pr-2 pl-3 text-sm font-bold uppercase tracking-[.08em] outline-none transition-colors hover:bg-arcade-ink focus-visible:ring-3 focus-visible:ring-arcade-yellow/60">
            <Star className="size-4 text-arcade-pink" /> Arcade
          </Link>
          <span className="my-2 w-px bg-arcade-yellow/25" aria-hidden="true" />
          <DropdownMenu>
            <DropdownMenuTrigger aria-label="Games menu" className="flex items-center rounded-r-full pr-2.5 pl-1.5 outline-none transition-colors hover:bg-arcade-ink focus-visible:ring-3 focus-visible:ring-arcade-yellow/60 data-[state=open]:bg-arcade-ink">
              <ChevronDown className="size-4 opacity-80 transition-transform in-data-[state=open]:rotate-180" />
            </DropdownMenuTrigger>
            <DropdownMenuContent align="start" alignOffset={-80} sideOffset={10} className="w-64 rounded-2xl border-4 border-arcade-ink bg-arcade-cream p-1.5 font-sans text-arcade-ink shadow-[6px_6px_0_var(--color-arcade-ink)] ring-0">
              <DropdownMenuLabel className="text-xs uppercase tracking-[.12em] text-arcade-ink/60">Where to?</DropdownMenuLabel>
              <DropdownMenuSub>
                <DropdownMenuSubTrigger className="font-bold"><Gamepad2 className="text-arcade-blue" /> Single player</DropdownMenuSubTrigger>
                <DropdownMenuSubContent className="w-60 rounded-2xl border-4 border-arcade-ink bg-arcade-cream p-1.5 font-sans text-arcade-ink shadow-[6px_6px_0_var(--color-arcade-ink)] ring-0">
                  <DropdownMenuItem asChild><Link to="/single" className="cursor-pointer text-xs uppercase tracking-[.1em] text-arcade-ink/60">All cabinets</Link></DropdownMenuItem>
                  <DropdownMenuSeparator className="bg-arcade-ink/15" />
                  {singlePlayer().map(g => <GameItem key={g.slug} g={g} />)}
                </DropdownMenuSubContent>
              </DropdownMenuSub>
              <DropdownMenuSub>
                <DropdownMenuSubTrigger className="font-bold"><Users className="text-arcade-green-dark" /> Multiplayer</DropdownMenuSubTrigger>
                <DropdownMenuSubContent className="w-60 rounded-2xl border-4 border-arcade-ink bg-arcade-cream p-1.5 font-sans text-arcade-ink shadow-[6px_6px_0_var(--color-arcade-ink)] ring-0">
                  <DropdownMenuItem asChild><Link to="/multiplayer" className="cursor-pointer text-xs uppercase tracking-[.1em] text-arcade-ink/60">Lobby floor</Link></DropdownMenuItem>
                  <DropdownMenuSeparator className="bg-arcade-ink/15" />
                  {multiplayer().map(g => <GameItem key={g.slug} g={g} />)}
                </DropdownMenuSubContent>
              </DropdownMenuSub>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        <nav aria-label="Breadcrumb" className="flex min-w-0 items-center gap-1 overflow-hidden text-xs font-bold uppercase tracking-[.08em]">
          {trail.map((c, i) => (
            <span key={c.to} className="flex items-center gap-1">
              {i > 0 && <span className="text-arcade-pink-dark">›</span>}
              {i === trail.length - 1
                ? <span className="rounded-full bg-arcade-yellow px-2.5 py-1 shadow-[inset_0_-2px_0_var(--color-arcade-yellow-dark)]">{c.label}</span>
                : <Link to={c.to} className="rounded-full px-2 py-1 transition-colors hover:bg-arcade-yellow">{c.label}</Link>}
            </span>
          ))}
        </nav>

        <div className="flex-1" />

        {pathname.startsWith('/multiplayer') && (
          <Link to="/multiplayer/battleblitz" className="hidden items-center gap-1 rounded-full px-2.5 py-1 text-xs font-bold uppercase tracking-[.08em] hover:bg-arcade-yellow sm:flex">
            <Swords className="size-3.5" /> Find a fight
          </Link>
        )}

        {/* your tickets (lib/tickets.ts, kept in localStorage); tokens live in the pot on the left rail */}
        <TicketCounter />

        <Link to="/prizes" className="flex h-9 shrink-0 items-center gap-1.5 rounded-full bg-arcade-navy-deep px-3 text-sm font-bold uppercase tracking-[.08em] text-arcade-yellow shadow-[inset_0_-3px_0_#0d0f30] outline-none transition-colors hover:bg-arcade-ink focus-visible:ring-3 focus-visible:ring-arcade-yellow/60">
          <Gift className="size-4 text-arcade-pink" /><span className="hidden sm:inline">Prizes</span><span className="sr-only sm:hidden">Prize counter</span>
        </Link>
      </div>
    </header>
  )
}
