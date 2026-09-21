// Battle Blitz 2P lobby: name -> queue -> matched -> the fight route. Fighter select happens in the
// game itself (the original screen), so this machine only has the name and "now serving" screens.
import { useEffect, useRef, useState, type FormEvent } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { PageTitle, Sprinkles } from '@/components/Deco'
import { connect, getSession, type ServerMessage } from '@/lib/mp'

type Step = 'boot' | 'name' | 'queue' | 'go' | 'msg'
const MARQUEE: Record<Step, string> = { boot: 'Battle Blitz', name: 'Player name', queue: 'Now serving', go: 'Fight!', msg: 'Game over' }

export default function Lobby() {
  const navigate = useNavigate()
  const [q] = useSearchParams()
  const [step, setStep] = useState<Step>('boot')
  const [name, setName] = useState(() => sessionStorage.getItem('mp.name') || '')
  const [status, setStatus] = useState('')
  const [position, setPosition] = useState(1)
  const [msg, setMsg] = useState<{ title: string; body: string } | null>(null)
  const [subline, setSubline] = useState('two players · insert coin')
  const ws = useRef<ReturnType<typeof connect> | null>(null)
  const session = useRef<string | null>(null)
  const leaving = useRef(false)

  const goToGame = (matchId: string) => {
    leaving.current = true
    setStep('go')
    const p = new URLSearchParams({ match: matchId, session: session.current! })
    if (q.has('mute')) p.set('mute', '1')
    navigate(`/multiplayer/battleblitz/play?${p}`)
  }

  const onMessage = (m: ServerMessage) => {
    switch (m.t) {
      case 'welcome': {
        const w = m as Extract<ServerMessage, { t: 'welcome' }>
        if (w.name) { setName(w.name); sessionStorage.setItem('mp.name', w.name) }
        if (w.match && ['picking', 'loading', 'playing'].includes(w.match.state)) goToGame(w.match.id)
        else if (w.state === 'queued') setStep('queue')
        else setStep('name')
        break
      }
      case 'queued': setPosition(m.position as number); setStep('queue'); setSubline('waiting for a challenger'); break
      case 'matched': setSubline(`matched with ${(m.opponent as { name: string }).name}`); goToGame(m.matchId as string); break
      case 'opponent_left': setMsg({ title: 'Opponent left', body: 'They left before the fight. Back to the lobby to find someone else.' }); setStep('msg'); break
      case 'error': setStatus(String(m.msg)); break
    }
  }

  useEffect(() => {
    let alive = true
    const open = async () => {
      try {
        const s = await getSession()
        if (!alive) return
        session.current = s.id
        const n = s.name || sessionStorage.getItem('mp.name') || null
        ws.current = connect(s.id, n, onMessage, code => {
          if (!alive || leaving.current) return
          if (code === 4000) { setMsg({ title: 'Opened elsewhere', body: 'This session was opened in another tab. Use that one, or reload here to take over.' }); setStep('msg'); return }
          setSubline('reconnecting…'); setTimeout(open, 1500)
        })
      } catch (e) {
        setMsg({ title: 'Offline', body: 'Could not reach the multiplayer service: ' + (e as Error).message }); setStep('msg')
      }
    }
    open()
    return () => { alive = false; leaving.current = true; ws.current?.close() }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const findOpponent = (ev: FormEvent) => {
    ev.preventDefault()
    const n = name.trim().slice(0, 16)
    if (!n) { setStatus('Type a name first.'); return }
    sessionStorage.setItem('mp.name', n)
    ws.current?.send({ t: 'hello', name: n })
    ws.current?.send({ t: 'queue', game: 'battleblitz' })
    setStatus('')
  }
  const cancel = () => { ws.current?.send({ t: 'leave' }); setStep('name'); setSubline('two players · insert coin') }

  return (
    <>
      <Sprinkles />
      <PageTitle title="Battle Blitz" sub={subline} />
      <div className="machine relative z-10 w-full max-w-4xl pt-6">
        <div className="body">
          <div className="marquee">{MARQUEE[step]}</div>
          <div className="screen text-left">
            {step === 'boot' && <p className="text-center text-arcade-yellow"><Spinner /> warming up…</p>}

            {step === 'name' && (
              <>
                <h2 className="mb-2 text-3xl font-bold text-arcade-yellow drop-shadow-[0_3px_0_var(--color-arcade-blue-dark)]">Who's fighting?</h2>
                <p className="opacity-80">Your name is just for this session — the other player sees it in the lobby and in the fight.</p>
                <form className="mt-4 flex flex-wrap items-center gap-3" onSubmit={findOpponent}>
                  <input className="arcade-input" value={name} onChange={e => setName(e.target.value)} maxLength={16} placeholder="type your name" autoComplete="off" autoFocus />
                  <button className="arcade-btn arcade-btn-go" type="submit">Find an opponent</button>
                </form>
                <p className="mt-2 min-h-6 font-bold text-arcade-yellow">{status}</p>
              </>
            )}

            {step === 'queue' && (
              <>
                <h2 className="mb-2 text-3xl font-bold text-arcade-yellow drop-shadow-[0_3px_0_var(--color-arcade-blue-dark)]"><Spinner /> Looking for a challenger…</h2>
                <p>You are <b>#{position}</b> in line. Keep this tab open — as soon as someone shows up you both go to the fighter select.</p>
                <div className="my-4 flex h-[150px] items-end justify-center gap-10">
                  <img className="bounce-fighter h-[130px] drop-shadow-[0_4px_0_rgba(0,0,0,.3)]" src="/img/battleblitz/robin.png" alt="" />
                  <span className="blink self-center text-5xl font-bold text-arcade-yellow drop-shadow-[0_4px_0_var(--color-arcade-red-dark)]">?</span>
                  <img className="bounce-fighter h-[130px] drop-shadow-[0_4px_0_rgba(0,0,0,.3)] [animation-delay:.55s]" src="/img/battleblitz/jinx.png" alt="" />
                </div>
                <button className="arcade-btn arcade-btn-ghost" onClick={cancel}>Cancel</button>
              </>
            )}

            {step === 'go' && <h2 className="py-6 text-center text-3xl font-bold text-arcade-yellow"><Spinner /> Fight!</h2>}

            {step === 'msg' && msg && (
              <div className="py-4 text-center">
                <h2 className="mb-2 text-3xl font-bold text-arcade-yellow">{msg.title}</h2>
                <p className="mb-4">{msg.body}</p>
                <button className="arcade-btn" onClick={() => { setMsg(null); setStep('name'); setSubline('two players · insert coin') }}>Back to the lobby</button>
              </div>
            )}
          </div>
          <div className="panel"><span className="stick" /><span className="stick" /><span className="btns"><i /><i /><i /></span></div>
          <div className="coinslot" />
        </div>
      </div>
      <p className="relative z-10 mt-14 text-xs font-bold uppercase tracking-[.1em] text-arcade-pink">arrows move · down blocks · Z punch · X kick · combos summon</p>
    </>
  )
}

const Spinner = () => <span className="mr-2 inline-block size-[1em] animate-spin rounded-full border-[3px] border-arcade-yellow border-r-transparent align-[-.15em]" />
