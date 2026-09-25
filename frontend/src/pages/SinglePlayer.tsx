import { Cabinet, CabinetGrid } from '@/components/Cabinet'
import { Sprinkles } from '@/components/Deco'
import { RailSection, RailTitle } from '@/components/Rail'
import { singlePlayer } from '@/lib/games'

export default function SinglePlayer() {
  return (
    <>
      <Sprinkles />
      <RailSection><RailTitle>Single player</RailTitle></RailSection>
      <CabinetGrid>{singlePlayer().map(g => <Cabinet key={g.slug} game={g} />)}</CabinetGrid>
    </>
  )
}
