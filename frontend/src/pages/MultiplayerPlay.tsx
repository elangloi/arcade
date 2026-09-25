// The 2P Battle Blitz fight: the game page (fighter select + lockstep fight) inside the frame.
import { Navigate, useSearchParams } from 'react-router-dom'
import { GameFrame } from '@/components/GameFrame'
import { findGame } from '@/lib/games'

export default function MultiplayerPlay() {
  const [q] = useSearchParams()
  const g = findGame('multi', 'battleblitz')!
  const match = q.get('match'), session = q.get('session')
  if (!match || !session) return <Navigate to="/multiplayer/battleblitz" replace />
  const src = new URL(g.src, location.origin)
  src.searchParams.set('match', match); src.searchParams.set('session', session)
  if (q.has('mute')) src.searchParams.set('mute', '1')
  return <GameFrame game={g} src={src.pathname + src.search} title="Battle Blitz 2P" aspect={3 / 2} />
}
