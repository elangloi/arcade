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

// The pile showing over the rim (drawn, not draggable) — the live token sits on top of it.
const PILE = [
  { x: 36, y: 47, r: -18 }, { x: 58, y: 42, r: 10 }, { x: 82, y: 46, r: -6 }, { x: 104, y: 41, r: 16 }, { x: 124, y: 47, r: -12 },
  { x: 48, y: 36, r: 22 }, { x: 72, y: 33, r: -14 }, { x: 96, y: 32, r: 8 }, { x: 116, y: 37, r: -20 },
]

function CupArt() {
  return (
    <svg viewBox="0 0 160 170" className="block w-full" aria-hidden="true">
      <defs>
        <clipPath id="cup-body"><path d="M18 52 H142 L126 164 Q80 172 34 164 Z" /></clipPath>
        <radialGradient id="tok" cx="40%" cy="35%" r="70%"><stop offset="0" stopColor="#fffbc2" /><stop offset=".55" stopColor="#fbf57a" /><stop offset="1" stopColor="#e5c94d" /></radialGradient>
      </defs>
      {/* the opening, then the heap of tokens in it */}
      <ellipse cx="80" cy="52" rx="62" ry="12" fill="#2b2450" />
      {PILE.map((t, i) => (
        <g key={i} transform={`translate(${t.x} ${t.y}) rotate(${t.r})`}>
          <ellipse rx="15" ry="9" fill="#e5c94d" transform="translate(0 2.5)" />
          <ellipse rx="15" ry="9" fill="url(#tok)" stroke="#d4b43c" strokeWidth="1.5" />
          <ellipse rx="10" ry="5.5" fill="none" stroke="#e5c94d" strokeWidth="1.5" />
        </g>
      ))}
      {/* the cup: pink with candy stripes and a navy label */}
      <path d="M18 52 H142 L126 164 Q80 172 34 164 Z" fill="#ff8fcf" />
      <g clipPath="url(#cup-body)" fill="#e86fb3">
        {[-60, -30, 0, 30, 60].map(o => <path key={o} d={`M${80 + o - 7} 50 L${80 + o * 0.8 - 5} 172 H${80 + o * 0.8 + 5} L${80 + o + 7} 50 Z`} />)}
        <path d="M0 150 H160 V172 H0 Z" fill="#e86fb3" />
      </g>
      <rect x="34" y="92" width="92" height="30" rx="9" fill="#151747" />
      <text x="80" y="113" textAnchor="middle" fontSize="17" fontWeight="700" letterSpacing="2" fill="#fbf57a" fontFamily="Fredoka, ui-rounded, sans-serif">TOKENS</text>
      {/* the front lip of the rim goes over the heap */}
      <path d="M17 52 A63 12 0 0 0 143 52" fill="none" stroke="#e86fb3" strokeWidth="7" strokeLinecap="round" />
      <path d="M17 50 A63 12 0 0 0 143 50" fill="none" stroke="#ffc2e4" strokeWidth="2" strokeLinecap="round" opacity=".7" />
    </svg>
  )
}

export function TokenCup() {
  const { cupRef, played, putBack } = useTokens()
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
      <p className="token-cup-caption mx-auto mt-2 w-fit rounded-full bg-arcade-navy-deep px-3 py-1 text-[.68rem] font-bold uppercase tracking-[.1em] text-arcade-yellow shadow-[inset_0_-2px_0_#0d0f30]">
        free play · {played} in
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
