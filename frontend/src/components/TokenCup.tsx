// The token cup on the left rail, and the token you drag out of it.
import { useEffect, type CSSProperties } from 'react'
import { useDrag, useDragLayer } from 'react-dnd'
import { getEmptyImage } from 'react-dnd-html5-backend'
import { cn } from '@/lib/utils'
import { TOKEN, useTokens } from '@/lib/tokens'
import { Star } from './Deco'

export function Token({ className, style }: { className?: string; style?: CSSProperties }) {
  return <span className={cn('token', className)} style={style}><Star className="token-star" /></span>
}

// The token pot: a round pink pot with a happy face, heaped with coins (each with a little face of
// its own). Flat arcade palette, shaded the way the cabinets are — a darker pink on the far side.
const INK = '#2b2450', PINK = '#ff8fcf', PINK_DARK = '#e86fb3', PINK_LIGHT = '#ffc6e6', RED = '#ff5a72'
const YELLOW = '#fbf57a', YELLOW_DARK = '#e5c94d'

// the heap: a back row and a front row, all inside the rim's opening (x 30..130 — the rim itself is
// 20..140 and nothing hangs over it). The live token sits on top, see TokenCup.
const HEAP = [
  { x: 53, y: 41 }, { x: 71, y: 37 }, { x: 89, y: 37 }, { x: 107, y: 41 },
  { x: 44, y: 53 }, { x: 62, y: 51 }, { x: 80, y: 50 }, { x: 98, y: 51 }, { x: 116, y: 53 },
]

function HappyCoin({ x, y }: { x: number; y: number }) {
  return (
    <g transform={`translate(${x} ${y})`}>
      <circle r="14" fill={YELLOW} stroke={YELLOW_DARK} strokeWidth="3" />
      <circle r="9.5" fill="none" stroke={YELLOW_DARK} strokeWidth="1.2" opacity=".6" />
      <circle cx="-4" cy="-1.5" r="1.6" fill={INK} /><circle cx="4" cy="-1.5" r="1.6" fill={INK} />
      <path d="M-3 2.5 Q0 5.5 3 2.5" fill="none" stroke={INK} strokeWidth="1.4" strokeLinecap="round" />
      <ellipse cx="-7" cy="2" rx="2" ry="1.2" fill={RED} opacity=".5" /><ellipse cx="7" cy="2" rx="2" ry="1.2" fill={RED} opacity=".5" />
    </g>
  )
}

const BODY = 'M32 70 C4 86 6 132 50 140 L110 140 C154 132 156 86 128 70 Z'

function CupArt() {
  return (
    <svg viewBox="0 0 160 152" className="block w-full overflow-visible" aria-hidden="true">
      <defs><clipPath id="pot-body"><path d={BODY} /></clipPath></defs>
      <ellipse cx="80" cy="147" rx="54" ry="4" fill="#151747" opacity=".7" />
      {/* feet */}
      <ellipse cx="50" cy="140" rx="10" ry="7" fill={PINK_DARK} />
      <ellipse cx="110" cy="140" rx="10" ry="7" fill={PINK_DARK} />
      {HEAP.map((c, i) => <HappyCoin key={i} {...c} />)}
      {/* the body: dark pink, with the lit side laid over it so a crescent of shade is left bottom-right */}
      <path d={BODY} fill={PINK_DARK} />
      <ellipse cx="72" cy="96" rx="68" ry="46" fill={PINK} clipPath="url(#pot-body)" />
      <path d="M22 90 Q18 102 21 114" fill="none" stroke={PINK_LIGHT} strokeWidth="5" strokeLinecap="round" />
      <circle cx="23" cy="123" r="2.6" fill={PINK_LIGHT} />
      {/* the face */}
      <g className="pot-eyes">
        <circle cx="61" cy="100" r="5.5" fill={INK} /><circle cx="99" cy="100" r="5.5" fill={INK} />
        <circle cx="63" cy="98" r="1.9" fill="#fff" /><circle cx="101" cy="98" r="1.9" fill="#fff" />
      </g>
      <ellipse cx="50" cy="111" rx="6.5" ry="3.8" fill={RED} opacity=".55" />
      <ellipse cx="110" cy="111" rx="6.5" ry="3.8" fill={RED} opacity=".55" />
      <path d="M72 107 Q80 121 88 107 Z" fill={INK} stroke={INK} strokeWidth="2" strokeLinejoin="round" />
      <ellipse cx="80" cy="115.5" rx="4.5" ry="2.6" fill={RED} />
      {/* the rim, over the bottom of the heap */}
      <rect x="20" y="58" width="120" height="15" rx="7.5" fill={PINK} />
      <rect x="20" y="66" width="120" height="7" rx="3.5" fill={PINK_DARK} />
      <rect x="20" y="58" width="120" height="11" rx="5.5" fill={PINK} />
      <path d="M28 61.5 H112" stroke={PINK_LIGHT} strokeWidth="2.5" strokeLinecap="round" />
    </svg>
  )
}

export function TokenCup() {
  const { cupRef, putBack } = useTokens()
  const [{ dragging }, drag, preview] = useDrag(() => ({
    type: TOKEN,
    item: {},
    collect: m => ({ dragging: m.isDragging() }),
    end: (_item, m) => { if (!m.didDrop()) putBack(m.getClientOffset()) },
  }), [putBack])
  // the browser's drag ghost is replaced by <TokenDragLayer> so the token looks the same in hand
  useEffect(() => { preview(getEmptyImage(), { captureDraggingState: true }) }, [preview])

  return (
    <div className="token-cup select-none">
      <div className="relative">
        <CupArt />
        <span
          ref={node => { cupRef.current = node; drag(node) }}
          className={cn('token-grab', dragging && 'opacity-0')}
          title="Drag a token onto a machine"
          aria-label="Token — drag it onto a machine, or click a machine to put one in"
        >
          <Token />
        </span>
      </div>
      <p className="token-cup-caption mt-3 text-center text-[.68rem] font-bold uppercase leading-snug tracking-[.1em] text-arcade-pink">
        drag one to a machine<br /><span className="opacity-70">or click a machine</span>
      </p>
    </div>
  )
}

// What you're holding while you drag: the same token, following the pointer.
export function TokenDragLayer() {
  const { active, p } = useDragLayer(m => ({ active: m.isDragging() && m.getItemType() === TOKEN, p: m.getClientOffset() }))
  if (!active || !p) return null
  return (
    <div className="pointer-events-none fixed inset-0 z-[70]">
      <Token className="token-held" style={{ left: p.x, top: p.y }} />
    </div>
  )
}
