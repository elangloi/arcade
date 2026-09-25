import { useState } from 'react'
import { BrowserRouter, Link, Navigate, Outlet, Route, Routes, useLocation } from 'react-router-dom'
import { DndProvider } from 'react-dnd'
import { HTML5Backend } from 'react-dnd-html5-backend'
import { TouchBackend } from 'react-dnd-touch-backend'
import { ArcadeNav } from '@/components/ArcadeNav'
import { Claw } from '@/components/Deco'
import { CrayonDefs } from '@/components/Doodles'
import { CursorSparkles } from '@/components/CursorSparkles'
import { RailSlot } from '@/components/Rail'
import { TokenCup, TokenDragLayer } from '@/components/TokenCup'
import { TokenProvider } from '@/lib/tokens'
import { usePrizes } from '@/lib/prizes'
import Home from '@/pages/Home'
import SinglePlayer from '@/pages/SinglePlayer'
import Multiplayer from '@/pages/Multiplayer'
import Lobby from '@/pages/Lobby'
import Play from '@/pages/Play'
import MultiplayerPlay from '@/pages/MultiplayerPlay'
import Prizes from '@/pages/Prizes'

// Drag and drop is mouse-driven HTML5 DnD on desktop; on touch screens that doesn't exist, so the
// touch backend takes over (it needs no drag ghost either — <TokenDragLayer> draws the token).
// The floor pages and the prize counter (not a game, not the lobby) get your sparkle flavour falling off the mouse.
const SPARKLY = new Set(['/', '/single', '/multiplayer', '/prizes'])

const dndBackend = matchMedia('(pointer: coarse)').matches ? TouchBackend : HTML5Backend

function Shell() {
  const { pathname } = useLocation()
  const playing = /\/single\/[^/]+$|\/play$/.test(pathname)
  const [slot, setSlot] = useState<HTMLElement | null>(null)   // where pages put their heading (<RailSection>)
  const { pet } = usePrizes()   // the claw holds your claw pet, if you've got one
  // Playing: the frame, with how-to-play stacked in a rail on its left.
  if (playing) return (
    <RailSlot.Provider value={slot}>
      <ArcadeNav />
      <div className="mx-auto flex w-full max-w-7xl gap-6 px-4 pt-16 pb-8">
        <aside className="play-rail" aria-label="How to play"><div ref={setSlot} className="sticky top-16" /></aside>
        <main className="flex min-w-0 flex-1 flex-col items-center"><Outlet /></main>
      </div>
    </RailSlot.Provider>
  )
  // Browsing: the token cup rides along on the left while the machines scroll past.
  return (
    <RailSlot.Provider value={slot}>
      <ArcadeNav />
      <div className="mx-auto flex w-full max-w-7xl gap-6 px-4 pt-20 pb-16">
        {/* the left rail: the claw and the marquee stick to the top, the token cup to the bottom */}
        <aside className="arcade-rail" aria-label="Arcade">
          <div className="rail-head">
            <Claw pet={pet} />
            <Link to="/" className="arcade-title block text-center text-[2.4rem]">Arcade</Link>
            <p className="arcade-pill mt-3 block text-center text-[.68rem] leading-snug"><span className="coin mr-1 size-[.8em] align-[-.1em] blink" />insert coin<br />pick a game</p>
            <div ref={setSlot} className="mt-7 empty:hidden" />
          </div>
          <div className="rail-cup"><TokenCup /></div>
        </aside>
        <main className="flex min-h-screen min-w-0 flex-1 flex-col items-center"><Outlet /></main>
      </div>
      <footer className="relative z-10 pb-10 text-center text-xs font-bold uppercase tracking-[.1em] text-arcade-pink opacity-90">more machines coming soon</footer>
      <TokenDragLayer />
      {SPARKLY.has(pathname) && <CursorSparkles />}
    </RailSlot.Provider>
  )
}

export default function App() {
  return (
    <DndProvider backend={dndBackend}>
      <CrayonDefs />
      <BrowserRouter>
        <TokenProvider>
          <Routes>
            <Route element={<Shell />}>
              <Route path="/" element={<Home />} />
              <Route path="/single" element={<SinglePlayer />} />
              <Route path="/single/:slug" element={<Play />} />
              <Route path="/multiplayer" element={<Multiplayer />} />
              <Route path="/multiplayer/battleblitz" element={<Lobby />} />
              <Route path="/multiplayer/battleblitz/play" element={<MultiplayerPlay />} />
              <Route path="/prizes" element={<Prizes />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Route>
          </Routes>
        </TokenProvider>
      </BrowserRouter>
    </DndProvider>
  )
}
