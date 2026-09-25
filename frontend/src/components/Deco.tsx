// Little decorations shared by the pages: the star, the heart, the claw, floating sprinkles.
import type { CSSProperties, SVGProps } from 'react'
import { usePrizes, type PetKind } from '@/lib/prizes'
import { PetFace } from './Doodles'

export const Star = (p: SVGProps<SVGSVGElement>) => (
  <svg viewBox="0 0 24 24" aria-hidden="true" {...p}><path d="M12 1.5 14.6 9.4 22.5 12 14.6 14.6 12 22.5 9.4 14.6 1.5 12 9.4 9.4Z" fill="currentColor" /></svg>
)
export const Heart = (p: SVGProps<SVGSVGElement>) => (
  <svg viewBox="0 0 24 24" aria-hidden="true" {...p}><path d="M12 21s-8-5.2-8-11a4.5 4.5 0 0 1 8-2.8A4.5 4.5 0 0 1 20 10c0 5.8-8 11-8 11Z" fill="currentColor" /></svg>
)

// The claw; with a `pet` (from the prize counter) it's holding one — the prongs close around its head.
export function Claw({ pet }: { pet?: PetKind | null }) {
  return (
    <svg className="sway mx-auto -mb-1.5 block h-[110px] w-[72px] overflow-visible" viewBox="0 0 72 110" aria-hidden="true">
      <rect x="34" y="0" width="4" height="46" fill="#c9cdf5" />
      <rect x="26" y="44" width="20" height="14" rx="4" fill="#fbf57a" stroke="#e5c94d" strokeWidth="3" />
      {pet && <g transform="translate(36 87)"><PetFace kind={pet} /></g>}
      <path d="M36 58 C 14 66, 10 84, 20 100" fill="none" stroke="#ff5a72" strokeWidth="7" strokeLinecap="round" />
      <path d="M36 58 C 58 66, 62 84, 52 100" fill="none" stroke="#ff5a72" strokeWidth="7" strokeLinecap="round" />
      {!pet && <path d="M36 58 L 36 96" fill="none" stroke="#ff5a72" strokeWidth="7" strokeLinecap="round" />}
      <circle cx="36" cy="58" r="7" fill="#5566ff" stroke="#3a46c8" strokeWidth="3" />
    </svg>
  )
}

// The drifting stars and hearts behind the pages. Kept right of ~18vw so none of them sits on the
// left rail (the claw, the marquee, the token pot).
const SPRINKLES: { kind: 'star' | 'heart'; color: string; pos: CSSProperties; size: number; delay: number }[] = [
  { kind: 'star', color: 'text-arcade-yellow', pos: { left: '22vw', top: '14vh' }, size: 26, delay: -2 },
  { kind: 'heart', color: 'text-arcade-pink', pos: { right: '8vw', top: '24vh' }, size: 30, delay: -4 },
  { kind: 'heart', color: 'text-arcade-red', pos: { left: '38vw', bottom: '8vh' }, size: 28, delay: -1 },
  { kind: 'star', color: 'text-arcade-pink', pos: { right: '14vw', bottom: '16vh' }, size: 30, delay: -3 },
  { kind: 'star', color: 'text-arcade-blue', pos: { left: '48vw', top: '32vh' }, size: 18, delay: -5 },
  { kind: 'heart', color: 'text-arcade-yellow', pos: { right: '28vw', top: '9vh' }, size: 20, delay: -2.5 },
  { kind: 'star', color: 'text-arcade-yellow', pos: { right: '4vw', top: '58vh' }, size: 22, delay: -1.5 },
  { kind: 'heart', color: 'text-arcade-pink', pos: { left: '27vw', top: '56vh' }, size: 22, delay: -3.5 },
  { kind: 'star', color: 'text-arcade-red', pos: { left: '64vw', bottom: '28vh' }, size: 16, delay: -0.5 },
  { kind: 'heart', color: 'text-arcade-blue', pos: { right: '38vw', bottom: '5vh' }, size: 18, delay: -4.5 },
  { kind: 'star', color: 'text-arcade-pink', pos: { left: '58vw', top: '6vh' }, size: 14, delay: -2.2 },
  { kind: 'heart', color: 'text-arcade-red', pos: { right: '20vw', top: '42vh' }, size: 16, delay: -5.5 },
]

export function Sprinkles() {
  return (
    <>
      {SPRINKLES.map((p, i) => {
        const Shape = p.kind === 'star' ? Star : Heart
        return <Shape key={i} className={`float pointer-events-none fixed opacity-90 ${p.color}`} style={{ ...p.pos, width: p.size, height: p.size, animationDelay: `${p.delay}s` }} />
      })}
    </>
  )
}

// Page header: big yellow title with twinkling stars and a pink pill under it.
export function PageTitle({ title, sub, claw = false }: { title: string; sub: string; claw?: boolean }) {
  const { pet } = usePrizes()
  return (
    <header className="relative z-10 mb-8 text-center">
      {claw && <Claw pet={pet} />}
      <h1 className="arcade-title text-[clamp(2.4rem,7vw,4.2rem)]">
        <Star className="twinkle mr-1 inline-block size-[.6em] align-[.08em] text-arcade-pink" />
        {title}
        <Star className="twinkle ml-1 inline-block size-[.6em] align-[.08em] text-arcade-pink [animation-delay:.8s]" />
      </h1>
      <p className="arcade-pill mt-3.5"><span className="coin mr-1.5 size-[.7em] align-[-.05em] blink" />{sub}</p>
    </header>
  )
}
