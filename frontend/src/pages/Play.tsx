import { Navigate, useParams } from 'react-router-dom'
import { GameFrame } from '@/components/GameFrame'
import { findGame } from '@/lib/games'

export default function Play() {
  const { slug } = useParams()
  const g = findGame('single', slug)
  if (!g) return <Navigate to="/single" replace />
  // no page title: the breadcrumbs already name the game, and the frame gets the height
  return <GameFrame game={g} title={`${g.title} ${g.subtitle ?? ''}`} watch={`single/${g.slug}`} />
}
