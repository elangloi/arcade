import { BrowserRouter, Navigate, Outlet, Route, Routes, useLocation } from 'react-router-dom'
import { DndProvider } from 'react-dnd'
import { HTML5Backend } from 'react-dnd-html5-backend'
import { TouchBackend } from 'react-dnd-touch-backend'
import { ArcadeNav } from '@/components/ArcadeNav'
import { TokenCup, TokenDragLayer } from '@/components/TokenCup'
import { TokenProvider } from '@/lib/tokens'
import Home from '@/pages/Home'
import SinglePlayer from '@/pages/SinglePlayer'
import Multiplayer from '@/pages/Multiplayer'
import Lobby from '@/pages/Lobby'
import Play from '@/pages/Play'
import MultiplayerPlay from '@/pages/MultiplayerPlay'

// Drag and drop is mouse-driven HTML5 DnD on desktop; on touch screens that doesn't exist, so the
// touch backend takes over (it needs no drag ghost either — <TokenDragLayer> draws the token).
const dndBackend = matchMedia('(pointer: coarse)').matches ? TouchBackend : HTML5Backend

function Shell() {
  const { pathname } = useLocation()
  const playing = /\/single\/[^/]+$|\/play$/.test(pathname)
  if (playing) return (
    <>
      <ArcadeNav />
      <main className="flex min-h-screen flex-col items-center px-4 pt-16 pb-8"><Outlet /></main>
    </>
  )
  // Browsing: the token cup rides along on the left while the machines scroll past.
  return (
    <>
      <ArcadeNav />
      <div className="mx-auto flex w-full max-w-7xl gap-6 px-4 pt-20 pb-16">
        <aside className="token-rail" aria-label="Token cup">
          <div className="md:sticky md:top-24"><TokenCup /></div>
        </aside>
        <main className="flex min-h-screen min-w-0 flex-1 flex-col items-center"><Outlet /></main>
      </div>
      <footer className="relative z-10 pb-10 text-center text-xs font-bold uppercase tracking-[.1em] text-arcade-pink opacity-90">more machines coming soon</footer>
      <TokenDragLayer />
    </>
  )
}

export default function App() {
  return (
    <DndProvider backend={dndBackend}>
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
              <Route path="*" element={<Navigate to="/" replace />} />
            </Route>
          </Routes>
        </TokenProvider>
      </BrowserRouter>
    </DndProvider>
  )
}
