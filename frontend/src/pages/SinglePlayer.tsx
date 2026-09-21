import { Cabinet, CabinetGrid } from '@/components/Cabinet'
import { PageTitle, Sprinkles } from '@/components/Deco'
import { singlePlayer } from '@/lib/games'

export default function SinglePlayer() {
  return (
    <>
      <Sprinkles />
      <PageTitle title="Single player" sub="five cabinets · no waiting" />
      <CabinetGrid>{singlePlayer().map(g => <Cabinet key={g.slug} game={g} />)}</CabinetGrid>
    </>
  )
}
