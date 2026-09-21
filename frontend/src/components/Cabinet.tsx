import { Link } from 'react-router-dom'
import { routeFor, type ArtKind, type Game } from '@/lib/games'

function Art({ kind }: { kind: ArtKind }) {
  switch (kind) {
    case 'blitz': return (
      <span className="art blitz"><span className="floor" /><img className="robin" src="/img/battleblitz/robin.png" alt="Robin" /><img className="jinx" src="/img/battleblitz/jinx.png" alt="Jinx" /></span>)
    case 'blitz2p': return (
      <span className="art blitz"><span className="floor" /><img className="robin" src="/img/battleblitz/robin.png" alt="Robin" /><span className="vs">VS</span><img className="jinx" src="/img/battleblitz/jinx.png" alt="Jinx" /></span>)
    case 'stack': return (
      <span className="art stack">
        <img className="ing cheese" src="/img/sandwichstacker/cheese.svg" alt="" /><img className="ing tomato" src="/img/sandwichstacker/tomato.svg" alt="" />
        <img className="ing lettuce" src="/img/sandwichstacker/lettuce.svg" alt="" /><img className="ing bread" src="/img/sandwichstacker/bread.svg" alt="" />
        <img className="reuben" src="/img/sandwichstacker/reuben.svg" alt="Reuben (experiment 625)" />
      </span>)
    case 'pizza': return (
      <span className="art pizza"><img className="order" src="/img/pizzatron/order.svg" alt="A pizza order" /><img className="sauce" src="/img/pizzatron/hotsauce.svg" alt="" /></span>)
    case 'boy': return (
      <span className="art boy"><span className="sunny" /><img className="theboy" src="/img/nobynobyboy/boy.svg" alt="BOY" /></span>)
  }
}

export function Cabinet({ game }: { game: Game }) {
  const twoSticks = game.mode === 'multi'
  return (
    <Link className="cab" to={routeFor(game)}>
      <div className="body">
        <div className="marquee">{game.title}{game.subtitle && <><br />{game.mode === 'multi' ? <small>{game.subtitle}</small> : game.subtitle}</>}</div>
        <div className="screen"><Art kind={game.art} /></div>
        <span className="tag">{game.tag}</span>
        <div className="panel"><span className="stick" />{twoSticks && <span className="stick" />}<span className="btns"><i /><i /><i /></span></div>
        <div className="coinslot" />
      </div>
    </Link>
  )
}

export function ComingSoon({ label = 'more machines later' }: { label?: string }) {
  return (
    <span className="cab soon">
      <div className="body">
        <div className="marquee">Coming soon</div>
        <div className="screen"><span className="art soon"><span className="zz">z z z</span>insert coin</span></div>
        <span className="tag">{label}</span>
        <div className="panel"><span className="stick" /><span className="btns"><i /><i /><i /></span></div>
        <div className="coinslot" />
      </div>
    </span>
  )
}

export function CabinetGrid({ children }: { children: React.ReactNode }) {
  return <div className="relative z-10 grid w-full max-w-5xl grid-cols-[repeat(auto-fill,minmax(250px,1fr))] items-end gap-x-7 gap-y-8">{children}</div>
}
