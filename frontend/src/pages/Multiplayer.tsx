import { useEffect, useState } from 'react'
import { Cabinet, CabinetGrid, ComingSoon } from '@/components/Cabinet'
import { Sprinkles } from '@/components/Deco'
import { RailSection, RailTitle } from '@/components/Rail'
import { multiplayer } from '@/lib/games'
import { stats } from '@/lib/mp'

export default function Multiplayer() {
  const [line, setLine] = useState('connecting…')
  useEffect(() => {
    let alive = true
    const tick = () => stats().then(s => alive && setLine(`${s.online} online · ${s.queued} waiting · ${s.playing} fighting`)).catch(() => alive && setLine('offline'))
    tick(); const h = setInterval(tick, 5000)
    return () => { alive = false; clearInterval(h) }
  }, [])
  return (
    <>
      <Sprinkles />
      <RailSection>
        <RailTitle>Multiplayer</RailTitle>
        <p className="rounded-2xl bg-arcade-navy-deep px-3 py-1.5 text-center text-[.68rem] font-bold uppercase leading-snug tracking-[.08em] whitespace-pre-line text-arcade-green">
          <span className="mr-1.5 inline-block size-2 rounded-full bg-arcade-green shadow-[0_0_8px_var(--color-arcade-green)] blink" />{line.replaceAll(' · ', '\n')}
        </p>
      </RailSection>
      <CabinetGrid>{multiplayer().map(g => <Cabinet key={g.slug} game={g} />)}<ComingSoon /></CabinetGrid>
    </>
  )
}
