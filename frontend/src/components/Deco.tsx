// Little decorations shared by the pages: the star, the heart, the claw, floating sprinkles.
import type { SVGProps } from 'react'

export const Star = (p: SVGProps<SVGSVGElement>) => (
  <svg viewBox="0 0 24 24" aria-hidden="true" {...p}><path d="M12 1.5 14.6 9.4 22.5 12 14.6 14.6 12 22.5 9.4 14.6 1.5 12 9.4 9.4Z" fill="currentColor" /></svg>
)
export const Heart = (p: SVGProps<SVGSVGElement>) => (
  <svg viewBox="0 0 24 24" aria-hidden="true" {...p}><path d="M12 21s-8-5.2-8-11a4.5 4.5 0 0 1 8-2.8A4.5 4.5 0 0 1 20 10c0 5.8-8 11-8 11Z" fill="currentColor" /></svg>
)

export function Claw() {
  return (
    <svg className="sway mx-auto -mb-1.5 block h-[110px] w-[72px]" viewBox="0 0 72 110" aria-hidden="true">
      <rect x="34" y="0" width="4" height="46" fill="#c9cdf5" />
      <rect x="26" y="44" width="20" height="14" rx="4" fill="#fbf57a" stroke="#e5c94d" strokeWidth="3" />
      <path d="M36 58 C 14 66, 10 84, 20 100" fill="none" stroke="#ff5a72" strokeWidth="7" strokeLinecap="round" />
      <path d="M36 58 C 58 66, 62 84, 52 100" fill="none" stroke="#ff5a72" strokeWidth="7" strokeLinecap="round" />
      <path d="M36 58 L 36 96" fill="none" stroke="#ff5a72" strokeWidth="7" strokeLinecap="round" />
      <circle cx="36" cy="58" r="7" fill="#5566ff" stroke="#3a46c8" strokeWidth="3" />
    </svg>
  )
}

export function Sprinkles() {
  const cls = 'float pointer-events-none fixed size-[30px] opacity-90'
  return (
    <>
      <Star className={`${cls} text-arcade-yellow`} style={{ left: '6vw', top: '18vh', animationDelay: '-2s' }} />
      <Heart className={`${cls} text-arcade-pink`} style={{ right: '8vw', top: '24vh', animationDelay: '-4s' }} />
      <Heart className={`${cls} text-arcade-red`} style={{ left: '12vw', bottom: '12vh', animationDelay: '-1s' }} />
      <Star className={`${cls} text-arcade-pink`} style={{ right: '14vw', bottom: '16vh', animationDelay: '-3s' }} />
    </>
  )
}

// Page header: big yellow title with twinkling stars and a pink pill under it.
export function PageTitle({ title, sub, claw = false }: { title: string; sub: string; claw?: boolean }) {
  return (
    <header className="relative z-10 mb-8 text-center">
      {claw && <Claw />}
      <h1 className="arcade-title text-[clamp(2.4rem,7vw,4.2rem)]">
        <Star className="twinkle mr-1 inline-block size-[.6em] align-[.08em] text-arcade-pink" />
        {title}
        <Star className="twinkle ml-1 inline-block size-[.6em] align-[.08em] text-arcade-pink [animation-delay:.8s]" />
      </h1>
      <p className="arcade-pill mt-3.5"><span className="coin mr-1.5 size-[.7em] align-[-.05em] blink" />{sub}</p>
    </header>
  )
}
