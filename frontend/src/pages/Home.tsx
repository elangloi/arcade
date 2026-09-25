import { Link } from 'react-router-dom'
import { Cabinet, CabinetGrid, ComingSoon } from '@/components/Cabinet'
import { PageTitle, Sprinkles } from '@/components/Deco'
import { singlePlayer, multiplayer } from '@/lib/games'

function Section({ title, to, children }: { title: string; to: string; children: React.ReactNode }) {
  return (
    <section className="relative z-10 mb-12 flex w-full max-w-5xl flex-col items-center">
      <h2 className="mb-9">
        <Link to={to} className="arcade-title group inline-flex items-baseline gap-2 text-[clamp(2rem,5vw,2.75rem)] transition-transform hover:-translate-y-0.5">
          {title}<span className="text-arcade-pink transition-transform group-hover:translate-x-1">›</span>
        </Link>
      </h2>
      {children}
    </section>
  )
}

export default function Home() {
  return (
    <>
      <Sprinkles />
      {/* from md up the title and claw live in the left rail (App.tsx) */}
      <div className="md:hidden"><PageTitle title="Arcade" sub="insert coin · pick a game" claw /></div>
      <Section title="Single player" to="/single">
        <CabinetGrid>{singlePlayer().map(g => <Cabinet key={g.slug} game={g} />)}</CabinetGrid>
      </Section>
      <Section title="Multiplayer" to="/multiplayer">
        <CabinetGrid>{multiplayer().map(g => <Cabinet key={g.slug} game={g} />)}<ComingSoon /></CabinetGrid>
      </Section>
    </>
  )
}
