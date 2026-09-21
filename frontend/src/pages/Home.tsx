import { Link } from 'react-router-dom'
import { Cabinet, CabinetGrid, ComingSoon } from '@/components/Cabinet'
import { PageTitle, Sprinkles } from '@/components/Deco'
import { singlePlayer, multiplayer } from '@/lib/games'

function Section({ title, to, children }: { title: string; to: string; children: React.ReactNode }) {
  return (
    <section className="relative z-10 mb-12 flex w-full max-w-5xl flex-col items-center">
      <Link to={to} className="arcade-pill mb-8 bg-arcade-navy-deep text-arcade-yellow shadow-[0_4px_0_#0d0f30] hover:bg-arcade-ink">{title} ›</Link>
      {children}
    </section>
  )
}

export default function Home() {
  return (
    <>
      <Sprinkles />
      <PageTitle title="Arcade" sub="insert coin · pick a game" claw />
      <Section title="Single player" to="/single">
        <CabinetGrid>{singlePlayer().map(g => <Cabinet key={g.slug} game={g} />)}</CabinetGrid>
      </Section>
      <Section title="Multiplayer" to="/multiplayer">
        <CabinetGrid>{multiplayer().map(g => <Cabinet key={g.slug} game={g} />)}<ComingSoon /></CabinetGrid>
      </Section>
    </>
  )
}
