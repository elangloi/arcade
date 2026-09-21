import { Navigate, useParams } from 'react-router-dom'
import { GameFrame } from '@/components/GameFrame'
import { findGame } from '@/lib/games'

export default function Play() {
  const { slug } = useParams()
  const g = findGame('single', slug)
  if (!g) return <Navigate to="/single" replace />
  return (
    <>
      <h1 className="arcade-title relative z-10 mb-5 text-3xl">{g.title}{g.subtitle ? ` · ${g.subtitle}` : ''}</h1>
      <GameFrame src={g.src} title={`${g.title} ${g.subtitle ?? ''}`} help={g.help} aspect={g.aspect} />
    </>
  )
}
