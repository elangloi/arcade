import { Link, useLocation } from 'react-router-dom'
import { ChevronDown, Gamepad2, Home, Swords, Users } from 'lucide-react'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel, DropdownMenuSeparator,
  DropdownMenuSub, DropdownMenuSubContent, DropdownMenuSubTrigger, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { GAMES, routeFor, singlePlayer, multiplayer, type Game } from '@/lib/games'
import { useCoins } from '@/lib/coins'
import { Star } from './Deco'

// Where are we? Turns the route into breadcrumbs for the bar.
function crumbs(pathname: string): { label: string; to: string }[] {
  const out = [{ label: 'Arcade', to: '/' }]
  const [, section, slug, sub] = pathname.split('/')
  if (section === 'single') out.push({ label: 'Single player', to: '/single' })
  if (section === 'multiplayer') out.push({ label: 'Multiplayer', to: '/multiplayer' })
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
  const balance = useCoins()

  return (
    <header className="fixed inset-x-0 top-0 z-50 h-12 bg-arcade-pink text-arcade-ink shadow-[0_4px_0_var(--color-arcade-pink-dark),0_8px_18px_rgba(0,0,0,.35)]">
      <div className="mx-auto flex h-full max-w-6xl items-center gap-2 px-3">
        <DropdownMenu>
          <DropdownMenuTrigger className="flex h-9 items-center gap-1.5 rounded-full bg-arcade-navy-deep px-3 text-sm font-bold uppercase tracking-[.08em] text-arcade-yellow shadow-[inset_0_-3px_0_#0d0f30] outline-none transition-transform hover:-translate-y-px focus-visible:ring-3 focus-visible:ring-arcade-yellow/60 data-[state=open]:bg-arcade-ink">
            <Star className="size-4 text-arcade-pink" /> Arcade <ChevronDown className="size-4 opacity-70" />
          </DropdownMenuTrigger>
          <DropdownMenuContent align="start" sideOffset={10} className="w-64 rounded-2xl border-4 border-arcade-ink bg-arcade-cream p-1.5 font-sans text-arcade-ink shadow-[6px_6px_0_var(--color-arcade-ink)] ring-0">
            <DropdownMenuLabel className="text-xs uppercase tracking-[.12em] text-arcade-ink/60">Where to?</DropdownMenuLabel>
            <DropdownMenuItem asChild><Link to="/" className="cursor-pointer font-bold"><Home className="text-arcade-red" /> Front of house</Link></DropdownMenuItem>
            <DropdownMenuSeparator className="bg-arcade-ink/15" />
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

        {/* the wallet: nobody earns coins yet, but the slot is wired (see lib/coins.ts) */}
        <span title="Coins — coming soon" className="flex items-center gap-1.5 rounded-full bg-arcade-navy-deep px-3 py-1.5 text-xs font-bold tracking-[.08em] text-arcade-yellow shadow-[inset_0_-3px_0_#0d0f30]">
          <span className="coin size-3 blink" /> {balance}
        </span>
      </div>
    </header>
  )
}
