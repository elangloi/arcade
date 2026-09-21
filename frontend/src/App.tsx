import { BrowserRouter, Navigate, Outlet, Route, Routes, useLocation } from 'react-router-dom'
import { ArcadeNav } from '@/components/ArcadeNav'
import Home from '@/pages/Home'
import SinglePlayer from '@/pages/SinglePlayer'
import Multiplayer from '@/pages/Multiplayer'
import Lobby from '@/pages/Lobby'
import Play from '@/pages/Play'
import MultiplayerPlay from '@/pages/MultiplayerPlay'

function Shell() {
  const { pathname } = useLocation()
  const playing = /\/single\/[^/]+$|\/play$/.test(pathname)
  return (
    <>
      <ArcadeNav />
      <main className={`flex min-h-screen flex-col items-center px-4 ${playing ? 'pt-16 pb-8' : 'pt-20 pb-16'}`}>
        <Outlet />
      </main>
      {!playing && <footer className="relative z-10 pb-10 text-center text-xs font-bold uppercase tracking-[.1em] text-arcade-pink opacity-90">more machines coming soon</footer>}
    </>
  )
}

export default function App() {
  return (
    <BrowserRouter>
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
    </BrowserRouter>
  )
}
