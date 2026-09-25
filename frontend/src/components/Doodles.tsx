// Crayon doodles: the claw pets and the confetti stickers. Pastel fills with a darker, slightly
// wobbly outline and a speckled crayon grain — all from one SVG filter, <CrayonDefs>, mounted once
// in App so every inline SVG on the page (and the mouse-trail sparkles) can use url(#arcade-crayon).
import type { PetKind } from '@/lib/prizes'

// pastel versions of the arcade palette, plus the earthy bits the animals need
export const D = {
  ink: '#2b2450', pink: '#ffb3d9', pinkD: '#f58cc0', pinkL: '#ffd9ec', yel: '#fff08a', yelD: '#f2cf5b',
  blue: '#b7d4ff', blueD: '#86a9f0', lilac: '#d9c9ff', lilacD: '#b49ef0', red: '#ff6f86', redD: '#e0506a',
  green: '#b9e8a0', greenD: '#8cc873', cream: '#fff6e8', creamD: '#e6d3b3', tan: '#e3b98a', tanD: '#c4945f',
  brown: '#c79a6e', brownD: '#9c6f45', peach: '#ffc796', peachD: '#f4a066',
}

export function CrayonDefs() {
  return (
    <svg width="0" height="0" className="pointer-events-none absolute" aria-hidden="true">
      <defs>
        <filter id="arcade-crayon" x="-15%" y="-15%" width="130%" height="130%">
          {/* wobble the edges like a hand-drawn line */}
          <feTurbulence type="fractalNoise" baseFrequency=".35" numOctaves="2" seed="4" result="wobble" />
          <feDisplacementMap in="SourceGraphic" in2="wobble" scale="1.8" xChannelSelector="R" yChannelSelector="G" result="drawn" />
          {/* and knock tiny specks out of it, like crayon on paper */}
          <feTurbulence type="fractalNoise" baseFrequency="1.6" numOctaves="1" seed="9" result="grain" />
          <feColorMatrix in="grain" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  -2.4 0 0 0 2.25" result="specks" />
          <feComposite in="drawn" in2="specks" operator="in" />
        </filter>
      </defs>
    </svg>
  )
}

const line = { strokeWidth: 1.8, strokeLinejoin: 'round' as const, strokeLinecap: 'round' as const }
const Dots = ({ y = 0, gap = 6 }: { y?: number; gap?: number }) => (
  <g fill={D.ink}><circle cx={-gap} cy={y} r="1.5" /><circle cx={gap} cy={y} r="1.5" /></g>
)
const Cheeks = ({ y = 4, gap = 10 }: { y?: number; gap?: number }) => (
  <g fill={D.pinkD} opacity=".6"><ellipse cx={-gap} cy={y} rx="2.6" ry="1.5" /><ellipse cx={gap} cy={y} rx="2.6" ry="1.5" /></g>
)
const Smile = ({ y = 4 }: { y?: number }) => <path d={`M-2.2 ${y} Q0 ${y + 2.2} 2.2 ${y}`} fill="none" stroke={D.ink} strokeWidth="1.1" strokeLinecap="round" />

// A pet's head, centred on 0,0 (about 34 wide), for dropping into another SVG like the claw.
export function PetFace({ kind }: { kind: PetKind }) {
  let face
  switch (kind) {
    case 'bear': face = (
      <g>
        <circle cx="-12" cy="-10.5" r="6.5" fill={D.brown} stroke={D.brownD} {...line} /><circle cx="12" cy="-10.5" r="6.5" fill={D.brown} stroke={D.brownD} {...line} />
        <circle cx="-12" cy="-10.5" r="3" fill={D.tan} /><circle cx="12" cy="-10.5" r="3" fill={D.tan} />
        <ellipse rx="16.5" ry="14.5" fill={D.brown} stroke={D.brownD} {...line} />
        <ellipse cx="0" cy="4.5" rx="6.5" ry="4.8" fill={D.tan} />
        <Dots y={-2} /><Cheeks y={3} gap={11} />
        <ellipse cx="0" cy="2.4" rx="1.9" ry="1.3" fill={D.ink} />
        <Smile y={4.4} />
      </g>); break
    case 'bunny': face = (
      <g>
        <ellipse cx="-7" cy="-17" rx="6" ry="11" fill={D.pink} stroke={D.pinkD} {...line} transform="rotate(-8 -7 -17)" />
        <ellipse cx="7" cy="-17" rx="6" ry="11" fill={D.pink} stroke={D.pinkD} {...line} transform="rotate(8 7 -17)" />
        <ellipse cx="-7" cy="-16" rx="2.6" ry="6.5" fill={D.pinkL} transform="rotate(-8 -7 -16)" />
        <ellipse cx="7" cy="-16" rx="2.6" ry="6.5" fill={D.pinkL} transform="rotate(8 7 -16)" />
        <ellipse rx="16" ry="13.5" fill={D.pink} stroke={D.pinkD} {...line} />
        <ellipse cx="0" cy="5" rx="11.5" ry="7" fill={D.cream} />
        <Dots y={1} /><Cheeks y={5.5} gap={10.5} />
        <Smile y={5} />
      </g>); break
    case 'dog': face = (
      <g>
        <ellipse rx="15.5" ry="14" fill={D.cream} stroke={D.creamD} {...line} />
        <path d="M-10 -11 C-19 -12 -21 0 -17 7 C-15 10 -11 8 -11 3 Z" fill={D.brown} stroke={D.brownD} {...line} />
        <path d="M10 -11 C19 -12 21 0 17 7 C15 10 11 8 11 3 Z" fill={D.brown} stroke={D.brownD} {...line} />
        <Dots y={-1} gap={5.5} /><Cheeks y={4.5} gap={9} />
        <ellipse cx="0" cy="3" rx="2.2" ry="1.5" fill={D.ink} />
        <path d="M0 4.4 L0 5.6 M-2.4 6 Q-1.2 7.4 0 5.6 Q1.2 7.4 2.4 6" fill="none" stroke={D.ink} strokeWidth="1" strokeLinecap="round" />
      </g>); break
    case 'cat': face = (
      <g>
        <path d="M-15 -3 L-13 -19 L-3 -12 Z" fill={D.peach} stroke={D.peachD} {...line} />
        <path d="M15 -3 L13 -19 L3 -12 Z" fill={D.peach} stroke={D.peachD} {...line} />
        <path d="M-11.5 -7 L-11 -14.5 L-6.5 -11 Z" fill={D.pinkL} /><path d="M11.5 -7 L11 -14.5 L6.5 -11 Z" fill={D.pinkL} />
        <ellipse rx="16.5" ry="13.5" fill={D.peach} stroke={D.peachD} {...line} />
        <Dots y={0} /><Cheeks y={4.5} gap={10.5} />
        <path d="M-2.6 3.6 Q-1.3 5.6 0 3.6 Q1.3 5.6 2.6 3.6" fill="none" stroke={D.ink} strokeWidth="1" strokeLinecap="round" />
        <g stroke={D.ink} strokeWidth=".7" strokeLinecap="round" opacity=".7" fill="none">
          <path d="M-10 2 L-20 0" /><path d="M-10 4 L-20 5.5" /><path d="M10 2 L20 0" /><path d="M10 4 L20 5.5" />
        </g>
      </g>); break
  }
  return <g filter="url(#arcade-crayon)">{face}</g>
}

export function PetBadge({ kind, className }: { kind: PetKind; className?: string }) {
  return <svg viewBox="-24 -32 48 50" className={className} aria-hidden="true"><PetFace kind={kind} /></svg>
}

// The confetti stickers, as SVG markup on a 24×24 box (the mouse trail stamps them straight into
// the DOM; <Doodle> renders one in React).
const s = (fill: string, stroke: string) => `fill="${fill}" stroke="${stroke}" stroke-width="1.5" stroke-linejoin="round" stroke-linecap="round"`
const petal = (fill: string, stroke: string, core: string) =>
  [[12, 6.5], [17.2, 10.3], [15.2, 16.4], [8.8, 16.4], [6.8, 10.3]].map(([x, y]) => `<circle cx="${x}" cy="${y}" r="3.8" ${s(fill, stroke)}/>`).join('') + `<circle cx="12" cy="12" r="3" ${s(core, D.yelD)}/>`
export const DOODLES: string[] = [
  // star
  `<path d="M12 2.8 14.7 8.8 21.2 9.5 16.3 13.8 17.7 20.2 12 16.9 6.3 20.2 7.7 13.8 2.8 9.5 9.3 8.8Z" ${s(D.yel, D.yelD)}/>`,
  // heart
  `<path d="M12 20.5s-8-5-8-10.6A4.3 4.3 0 0 1 12 7.4a4.3 4.3 0 0 1 8 2.5c0 5.6-8 10.6-8 10.6Z" ${s(D.pink, D.pinkD)}/>`,
  // flowers
  petal(D.pink, D.pinkD, D.yel),
  petal(D.blue, D.blueD, D.yel),
  // cloud
  `<path d="M6.5 18a4 4 0 0 1-.4-8 5.5 5.5 0 0 1 10.4-1.6A4.3 4.3 0 0 1 18 18Z" ${s(D.blue, D.blueD)}/>`,
  // rainbow
  `<g fill="none" stroke-width="2.8" stroke-linecap="round"><path d="M3 18a9 9 0 0 1 18 0" stroke="${D.pinkD}"/><path d="M6.2 18a5.8 5.8 0 0 1 11.6 0" stroke="${D.yelD}"/><path d="M9.3 18a2.7 2.7 0 0 1 5.4 0" stroke="${D.blueD}"/></g>`,
  // cherries
  `<path d="M8 15C9 9 12 6 15.5 3.5M16 14.5C15.5 10 15.5 6 15.5 3.5" fill="none" stroke="${D.greenD}" stroke-width="1.5" stroke-linecap="round"/><circle cx="8" cy="16.5" r="3.8" ${s(D.red, D.redD)}/><circle cx="16.3" cy="16" r="3.8" ${s(D.red, D.redD)}/>`,
  // ice cream
  `<path d="M7.5 11 12 22 16.5 11Z" ${s(D.tan, D.tanD)}/><circle cx="12" cy="9" r="5.2" ${s(D.pink, D.pinkD)}/><circle cx="12" cy="3.4" r="1.9" ${s(D.red, D.redD)}/>`,
  // cupcake
  `<path d="M6.3 13 7.8 21h8.4l1.5-8Z" ${s(D.yel, D.yelD)}/><path d="M5.2 13.5C4.8 8.4 8 6.8 12 6.8s7.2 1.6 6.8 6.7Z" ${s(D.pink, D.pinkD)}/><circle cx="12" cy="5" r="1.9" ${s(D.red, D.redD)}/>`,
  // butterfly
  `<ellipse cx="7.4" cy="8.6" rx="4.4" ry="4" ${s(D.yel, D.yelD)}/><ellipse cx="16.6" cy="8.6" rx="4.4" ry="4" ${s(D.yel, D.yelD)}/><ellipse cx="8.2" cy="15.4" rx="3.4" ry="3" ${s(D.peach, D.peachD)}/><ellipse cx="15.8" cy="15.4" rx="3.4" ry="3" ${s(D.peach, D.peachD)}/><rect x="10.8" y="5.5" width="2.4" height="13.5" rx="1.2" ${s(D.lilac, D.lilacD)}/>`,
  // loop
  `<path d="M3 16c4 0 5-9 9-7.5s-.5 6.5-2.5 4.5 1.5-7 6-6 4 5 5.5 5.5" fill="none" stroke="${D.peachD}" stroke-width="2.6" stroke-linecap="round"/>`,
  // squiggle
  `<path d="M3 13c1.5-4 3.5-4 4.5 0s3 4 4.5 0 3-4 4.5 0 3 4 4.5 0" fill="none" stroke="${D.greenD}" stroke-width="2.6" stroke-linecap="round"/>`,
]

export function Doodle({ i, className }: { i: number; className?: string }) {
  return <svg viewBox="0 0 24 24" className={className} aria-hidden="true"><g filter="url(#arcade-crayon)" dangerouslySetInnerHTML={{ __html: DOODLES[i % DOODLES.length] }} /></svg>
}

// The fortune cookie: two toasty lobes pinched at a fold, with a face. Cracked, the halves fall
// apart (still smiling, eyes shut happy) and the fortune slip pops up between them.
const COOKIE_L = 'M8 31 C5 17 19 8 32 12 C31 18 31 24 32 29 C24 35 13 37 8 31 Z'
const COOKIE_R = 'M56 31 C59 17 45 8 32 12 C33 18 33 24 32 29 C40 35 51 37 56 31 Z'
const COOKIE = 'M8 31 C5 17 19 8 32 12 C45 8 59 17 56 31 C51 37 40 35 32 29 C24 35 13 37 8 31 Z'
export function FortuneCookie({ cracked, className }: { cracked?: boolean; className?: string }) {
  const shine = (side: -1 | 1) => <path d={side < 0 ? 'M13 27 C12 19 20 14 27 15' : 'M51 27 C52 19 44 14 37 15'} fill="none" stroke={D.yel} strokeWidth="2.4" strokeLinecap="round" opacity=".8" />
  const half = (d: string, side: -1 | 1) => (
    <g transform={`translate(${side * 5} 3) rotate(${side * 14} 32 30)`}>
      <path d={d} fill={D.tan} stroke={D.tanD} {...line} />{shine(side)}
    </g>
  )
  return (
    <svg viewBox="0 0 64 44" className={className} aria-hidden="true">
      <g filter="url(#arcade-crayon)">
        {cracked && (
          <g transform="rotate(-6 32 16)">
            <rect x="21" y="4" width="22" height="13" rx="2" fill={D.cream} stroke={D.creamD} {...line} />
            <path d="M25 9 H39 M25 12.5 H35" stroke={D.pinkD} strokeWidth="1.2" strokeLinecap="round" />
          </g>
        )}
        {cracked ? <>{half(COOKIE_L, -1)}{half(COOKIE_R, 1)}</> : (
          <g>
            <path d={COOKIE} fill={D.tan} stroke={D.tanD} {...line} />{shine(-1)}{shine(1)}
            <path d="M32 12 C30.6 14.5 30.6 16.5 32 18.5" fill="none" stroke={D.tanD} {...line} />
          </g>
        )}
        {cracked ? (
          <g fill="none" stroke={D.ink} strokeWidth="1.3" strokeLinecap="round">
            <path d="M16 23 Q18 21 20 23" /><path d="M44 23 Q46 21 48 23" />
          </g>
        ) : (
          <g>
            <circle cx="25" cy="21" r="1.6" fill={D.ink} /><circle cx="39" cy="21" r="1.6" fill={D.ink} />
            <path d="M29.6 24.6 Q32 26.8 34.4 24.6" fill="none" stroke={D.ink} strokeWidth="1.2" strokeLinecap="round" />
          </g>
        )}
        <g fill={D.pinkD} opacity=".6">
          {cracked ? <><ellipse cx="15" cy="27" rx="2.6" ry="1.5" /><ellipse cx="49" cy="27" rx="2.6" ry="1.5" /></> : <><ellipse cx="20.5" cy="25" rx="2.6" ry="1.5" /><ellipse cx="43.5" cy="25" rx="2.6" ry="1.5" /></>}
        </g>
      </g>
    </svg>
  )
}
