// Sparkles that fall off the mouse while you browse the machines (the shell mounts this on the
// front of house and the two floor pages, never over a game). Each sparkle is a throwaway element
// animated with the Web Animations API, so moving the mouse never re-renders React.
import { useEffect, useRef } from 'react'

const STAR = '<path d="M12 1.5 14.6 9.4 22.5 12 14.6 14.6 12 22.5 9.4 14.6 1.5 12 9.4 9.4Z" fill="currentColor"/>'
const HEART = '<path d="M12 21s-8-5.2-8-11a4.5 4.5 0 0 1 8-2.8A4.5 4.5 0 0 1 20 10c0 5.8-8 11-8 11Z" fill="currentColor"/>'
const COLORS = ['var(--color-arcade-yellow)', 'var(--color-arcade-yellow)', 'var(--color-arcade-pink)', 'var(--color-arcade-pink)', 'var(--color-arcade-red)', 'var(--color-arcade-blue)']
const EVERY_MS = 28     // at most one sparkle this often
const MAX_LIVE = 60

export function CursorSparkles() {
  const box = useRef<HTMLDivElement>(null)
  useEffect(() => {
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) return
    let last = 0, live = 0
    const onMove = (e: PointerEvent) => {
      if (e.pointerType !== 'mouse' || !box.current) return
      const now = performance.now()
      if (now - last < EVERY_MS || live >= MAX_LIVE) return
      last = now
      const el = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
      const size = 8 + Math.random() * 10
      el.setAttribute('viewBox', '0 0 24 24')
      el.innerHTML = Math.random() < 0.8 ? STAR : HEART
      el.style.cssText = `position:absolute;left:${e.clientX}px;top:${e.clientY}px;width:${size}px;height:${size}px;color:${COLORS[Math.floor(Math.random() * COLORS.length)]};pointer-events:none`
      box.current.appendChild(el)
      live++
      const dx = (Math.random() - 0.5) * 36, dy = 40 + Math.random() * 50, spin = (Math.random() - 0.5) * 240
      el.animate([
        { transform: 'translate(-50%, -50%) scale(.4) rotate(0deg)', opacity: 0 },
        { transform: 'translate(-50%, -50%) scale(1) rotate(0deg)', opacity: 1, offset: 0.12 },
        { transform: `translate(calc(-50% + ${dx}px), calc(-50% + ${dy}px)) scale(.3) rotate(${spin}deg)`, opacity: 0 },
      ], { duration: 700 + Math.random() * 500, easing: 'cubic-bezier(.3,.2,.6,1)' })
        .finished.catch(() => {}).finally(() => { el.remove(); live-- })
    }
    window.addEventListener('pointermove', onMove, { passive: true })
    return () => window.removeEventListener('pointermove', onMove)
  }, [])
  return <div ref={box} className="pointer-events-none fixed inset-0 z-[60] overflow-hidden" aria-hidden="true" />
}
