// Matchmaking + match state machine. Pure logic: sockets, timers and the clock are injected so
// the whole thing can be driven from tests. One instance per server.
//
//   session:  idle -> queued -> matched -> idle
//   match:    picking -> loading -> playing -> finished -> closed
//             (any) -> abandoned | desync
//
// Sides: nobody is a hero or a villain until someone clicks a fighter. The first `pick` claims
// that fighter's side for the picker and locks the opponent into the other side.

import { randomUUID, randomInt } from 'node:crypto';
import { sideOf, other, cleanName, TITANS, VILLAINS } from './protocol.js';

const SIDES = ['titan', 'villain'];
const GAME_URL = 'games/battleblitz/web/';

export class Lobby {
  constructor({ send, db, config, timers, now, random, log } = {}) {
    this.send = send || (() => {});
    this.db = db;
    this.config = config;
    this.timers = timers || { set: (fn, ms) => setTimeout(fn, ms), clear: h => clearTimeout(h) };
    this.now = now || Date.now;
    this.random = random || (() => randomInt(0, 2 ** 31));
    this.log = log || (() => {});
    this.sessions = new Map();
    this.matches = new Map();
    this.queue = [];
  }

  // ---- sessions ---------------------------------------------------------------------------

  createSession(name = null) {
    const id = randomUUID();
    const s = { id, name: cleanName(name), connected: false, state: 'idle', matchId: null, rtt: null, timers: {}, lastSeen: this.now() };
    this.sessions.set(id, s);
    this.db?.createSession(id, s.name, s.lastSeen);
    this.event('session_created', { session: id });
    return s;
  }

  getSession(id) { return this.sessions.get(id) || null; }

  // A socket for this session opened (or re-opened).
  connect(id, { name } = {}) {
    const s = this.sessions.get(id);
    if (!s) return null;
    s.connected = true;
    s.lastSeen = this.now();
    if (name !== undefined) { const n = cleanName(name); if (n) s.name = n; }
    this.db?.touchSession(id, s.lastSeen, s.name);
    const reconnected = !!s.timers.grace;
    this.clearTimer(s, 'grace');
    const m = s.matchId ? this.matches.get(s.matchId) : null;
    if (reconnected && m) {
      this.event('reconnect', { session: id, match: m.id });
      this.toOpponent(m, id, { t: 'opponent_away', hidden: false, reason: 'reconnected' });
    } else {
      this.event('hello', { session: id });
    }
    return this.welcome(s);
  }

  welcome(s) {
    const m = s.matchId ? this.matches.get(s.matchId) : null;
    return { t: 'welcome', session: s.id, name: s.name, state: s.state, match: m ? this.matchView(m, s.id) : null };
  }

  disconnect(id) {
    const s = this.sessions.get(id);
    if (!s || !s.connected) return;
    s.connected = false;
    s.lastSeen = this.now();
    this.event('disconnect', { session: id, match: s.matchId });
    if (s.state === 'queued') { this.dequeue(s); return; }
    const m = s.matchId ? this.matches.get(s.matchId) : null;
    if (!m) return;
    this.toOpponent(m, id, { t: 'opponent_away', hidden: true, reason: 'disconnected' });
    this.setTimer(s, 'grace', this.config.timers.reconnectGraceMs, () => this.leave(s, 'disconnect'));
  }

  // Drop sessions nobody has touched for a while (they're ephemeral; the DB rows stay).
  gc(maxIdleMs = 3_600_000) {
    const cutoff = this.now() - maxIdleMs;
    for (const s of this.sessions.values()) {
      if (!s.connected && s.state === 'idle' && s.lastSeen < cutoff) this.sessions.delete(s.id);
    }
  }

  // Cancel every pending timer (server shutdown).
  shutdown() {
    for (const s of this.sessions.values()) for (const k of Object.keys(s.timers)) this.clearTimer(s, k);
    for (const m of this.matches.values()) for (const k of Object.keys(m.timers)) this.clearTimer(m, k);
  }

  stats() {
    let online = 0;
    for (const s of this.sessions.values()) if (s.connected) online++;
    let playing = 0;
    for (const m of this.matches.values()) if (m.state === 'playing') playing++;
    return { online, queued: this.queue.length, playing };
  }

  // ---- messages ---------------------------------------------------------------------------

  handle(id, msg) {
    const s = this.sessions.get(id);
    if (!s) return;
    s.lastSeen = this.now();
    const m = s.matchId ? this.matches.get(s.matchId) : null;
    switch (msg.t) {
      case 'hello': return; // handled by connect()
      case 'ping': return this.send(id, { t: 'pong', ts: msg.ts, rtt: s.rtt });
      case 'queue': return this.onQueue(s);
      case 'leave': return this.leave(s, 'leave');
      case 'away': if (m) this.toOpponent(m, id, { t: 'opponent_away', hidden: msg.hidden, reason: 'hidden' }); return;
      case 'pick': return m ? this.onPick(s, m, msg.fighter) : this.error(s, 'no_match', 'not in a match');
      case 'lock': return m ? this.onLock(s, m, msg.fighter) : this.error(s, 'no_match', 'not in a match');
      case 'ready': return m ? this.onReady(s, m) : this.error(s, 'no_match', 'not in a match');
      case 'in': return m ? this.onInput(s, m, msg) : undefined;
      case 'sum': return m ? this.onSum(s, m, msg) : undefined;
      case 'resume': return m ? this.onResume(s, m, msg.have) : this.error(s, 'no_match', 'not in a match');
      case 'end': return m ? this.onEnd(s, m, msg) : this.error(s, 'no_match', 'not in a match');
      case 'rematch': return m ? this.onRematch(s, m, msg.yes) : this.error(s, 'no_match', 'not in a match');
      default: return this.error(s, 'bad_type', 'unknown message ' + msg.t);
    }
  }

  // The server reports measured round trips here so the input delay can be chosen from them.
  setRtt(id, rtt) { const s = this.sessions.get(id); if (s) s.rtt = rtt; }

  // ---- queue ------------------------------------------------------------------------------

  onQueue(s) {
    if (s.state === 'matched') return this.error(s, 'in_match', 'already in a match');
    if (!s.name) return this.error(s, 'no_name', 'pick a name first');
    if (s.state !== 'queued') {
      s.state = 'queued';
      this.queue.push(s.id);
      this.event('queue', { session: s.id });
    }
    this.send(s.id, { t: 'queued', position: this.queue.indexOf(s.id) + 1 });
    this.pairUp();
  }

  dequeue(s) {
    const i = this.queue.indexOf(s.id);
    if (i >= 0) this.queue.splice(i, 1);
    if (s.state === 'queued') { s.state = 'idle'; this.event('dequeue', { session: s.id }); }
    this.queue.forEach((id, n) => this.send(id, { t: 'queued', position: n + 1 }));
  }

  pairUp() {
    while (this.queue.length >= 2) {
      const a = this.sessions.get(this.queue.shift());
      const b = this.sessions.get(this.queue.shift());
      if (!a || !b) continue;
      this.createMatch([a, b]);
    }
  }

  // ---- match lifecycle --------------------------------------------------------------------

  createMatch(players, { rematchOf = null, sides = null, fighters = null } = {}) {
    const m = {
      id: randomUUID(), game: 'battleblitz', state: 'picking', rematchOf,
      players: players.map(p => p.id),
      sides: sides ? { ...sides } : { titan: null, villain: null }, claimedBy: sides ? 'rematch' : null,
      picks: {}, locked: {}, fighters: fighters ? { ...fighters } : { titan: null, villain: null },
      ready: {}, inputs: { titan: [], villain: [] }, topFrame: { titan: -1, villain: -1 },
      lastInputAt: { titan: 0, villain: 0 }, sums: new Map(), ends: {}, rematch: {},
      seed: this.random() >>> 0, delay: this.config.game.inputDelay, difficulty: this.config.game.difficulty,
      wins: { titan: 0, villain: 0 }, winner: null, reason: null,
      createdAt: this.now(), startedAt: null, endedAt: null, timers: {},
    };
    for (const p of players) { m.picks[p.id] = null; m.locked[p.id] = false; m.ready[p.id] = false; m.rematch[p.id] = null; }
    this.matches.set(m.id, m);
    this.db?.createMatch(m, m.createdAt);
    for (const p of players) { p.state = 'matched'; p.matchId = m.id; }
    if (fighters) {
      for (const p of players) { const side = this.sideFor(m, p.id); m.picks[p.id] = fighters[side]; m.locked[p.id] = true; }
      this.event('rematch_created', { match: m.id, data: { of: rematchOf } });
      this.save(m);
      this.startLoading(m);
    } else {
      this.event('matched', { match: m.id, data: { players: m.players } });
      this.save(m);
      for (const p of players) {
        this.send(p.id, { t: 'matched', matchId: m.id, opponent: this.opponentView(m, p.id), pickTimeoutMs: this.config.timers.pickTimeoutMs });
      }
      this.setTimer(m, 'pick', this.config.timers.pickTimeoutMs, () => this.pickTimeout(m));
    }
    return m;
  }

  onPick(s, m, fighter) {
    if (m.state !== 'picking') return this.error(s, 'bad_state', 'picks are closed');
    if (m.locked[s.id]) return this.error(s, 'already_locked', 'you already locked in');
    const side = sideOf(fighter);
    if (!m.claimedBy) {
      const opp = this.opponentId(m, s.id);
      m.sides[side] = s.id; m.sides[other(side)] = opp; m.claimedBy = s.id;
      this.event('side_claimed', { session: s.id, match: m.id, data: { side, fighter } });
      this.broadcast(m, { t: 'sides', titan: m.sides.titan, villain: m.sides.villain, claimedBy: s.id });
    } else if (this.sideFor(m, s.id) !== side) {
      return this.error(s, 'wrong_side', `you fight for the ${this.sideFor(m, s.id) === 'titan' ? 'Titans' : 'villains'}`);
    }
    m.picks[s.id] = fighter;
    this.event('pick', { session: s.id, match: m.id, data: { fighter } });
    this.broadcast(m, { t: 'picked', session: s.id, side, fighter });
    this.save(m);
  }

  onLock(s, m, fighter) {
    if (m.state !== 'picking') return this.error(s, 'bad_state', 'picks are closed');
    if (m.locked[s.id]) return;
    if (fighter !== undefined && fighter !== m.picks[s.id]) {
      this.onPick(s, m, fighter);
      if (m.picks[s.id] !== fighter) return;   // the pick was rejected
    }
    if (m.picks[s.id] === null) return this.error(s, 'no_pick', 'choose a fighter first');
    m.locked[s.id] = true;
    const side = this.sideFor(m, s.id);
    m.fighters[side] = m.picks[s.id];
    this.event('lock', { session: s.id, match: m.id, data: { side, fighter: m.picks[s.id] } });
    this.broadcast(m, { t: 'locked', session: s.id, side, fighter: m.picks[s.id] });
    this.save(m);
    if (m.players.every(id => m.locked[id])) this.startLoading(m);
  }

  pickTimeout(m) {
    if (m.state !== 'picking') return;
    if (!m.claimedBy) {   // nobody clicked anything: coin flip
      const [a, b] = m.players;
      const flip = (this.random() & 1) === 0;
      m.sides.titan = flip ? a : b; m.sides.villain = flip ? b : a; m.claimedBy = 'timeout';
      this.broadcast(m, { t: 'sides', titan: m.sides.titan, villain: m.sides.villain, claimedBy: null });
    }
    for (const id of m.players) {
      if (m.locked[id]) continue;
      const side = this.sideFor(m, id);
      if (m.picks[id] === null) m.picks[id] = side === 'titan' ? TITANS[0] : VILLAINS[0];
      m.locked[id] = true;
      m.fighters[side] = m.picks[id];
      this.broadcast(m, { t: 'locked', session: id, side, fighter: m.picks[id], auto: true });
    }
    this.event('pick_timeout', { match: m.id });
    this.startLoading(m);
  }

  startLoading(m) {
    this.clearTimer(m, 'pick');
    m.state = 'loading';
    m.delay = this.chooseDelay(m);
    this.event('fight', { match: m.id, data: { titan: m.fighters.titan, villain: m.fighters.villain, seed: m.seed, delay: m.delay } });
    this.save(m);
    for (const id of m.players) this.send(id, this.fightMessage(m, id));
    this.setTimer(m, 'ready', this.config.timers.readyTimeoutMs, () => this.abandon(m, 'ready_timeout'));
  }

  fightMessage(m, id) {
    return {
      t: 'fight', matchId: m.id, side: this.sideFor(m, id), titan: m.fighters.titan, villain: m.fighters.villain,
      seed: m.seed, delay: m.delay, difficulty: m.difficulty, gameUrl: GAME_URL, opponent: this.opponentView(m, id),
      rematchOf: m.rematchOf,
    };
  }

  chooseDelay(m) {
    // One-way latency in frames (33ms each) plus one for jitter, within 2..6.
    let worst = 0;
    for (const id of m.players) { const s = this.sessions.get(id); if (s?.rtt) worst = Math.max(worst, s.rtt); }
    if (!worst) return this.config.game.inputDelay;
    return Math.max(2, Math.min(6, Math.ceil(worst / 2 / 33) + 1));
  }

  onReady(s, m) {
    if (m.state !== 'loading') return;
    m.ready[s.id] = true;
    this.event('ready', { session: s.id, match: m.id });
    if (!m.players.every(id => m.ready[id])) return;
    this.clearTimer(m, 'ready');
    m.state = 'playing';
    m.startedAt = this.now();
    m.lastInputAt = { titan: m.startedAt, villain: m.startedAt };
    this.event('start', { match: m.id });
    this.save(m);
    this.broadcast(m, { t: 'start', delay: m.delay, seed: m.seed });
    this.setTimer(m, 'stall', 5_000, () => this.stallCheck(m));
  }

  onInput(s, m, msg) {
    if (m.state !== 'playing') return;
    const side = this.sideFor(m, s.id);
    if (msg.f <= m.topFrame[side]) return;   // duplicate (resend after a reconnect)
    m.topFrame[side] = msg.f;
    m.inputs[side].push({ f: msg.f, e: msg.e });
    m.lastInputAt[side] = this.now();
    this.toOpponent(m, s.id, { t: 'in', f: msg.f, e: msg.e });
  }

  onSum(s, m, msg) {
    if (m.state !== 'playing') return;
    const side = this.sideFor(m, s.id);
    let rec = m.sums.get(msg.f);
    if (!rec) { rec = {}; m.sums.set(msg.f, rec); }
    rec[side] = msg.h;
    if (rec.titan === undefined || rec.villain === undefined) return;
    m.sums.delete(msg.f);
    if (rec.titan !== rec.villain) {
      this.event('sum_mismatch', { match: m.id, data: { f: msg.f, titan: rec.titan, villain: rec.villain } });
      this.finish(m, null, 'desync', { f: msg.f });
    }
    // keep the map small
    for (const f of m.sums.keys()) if (f < msg.f - 300) m.sums.delete(f);
  }

  onResume(s, m, have) {
    if (m.state !== 'playing') return this.send(s.id, { t: 'resume_ack', state: m.state, have: -1 });
    const side = this.sideFor(m, s.id);
    for (const p of m.inputs[other(side)]) if (p.f > have) this.send(s.id, { t: 'in', f: p.f, e: p.e });
    this.send(s.id, { t: 'resume_ack', state: m.state, have: m.topFrame[side], delay: m.delay, seed: m.seed });
  }

  onEnd(s, m, msg) {
    if (m.state !== 'playing') return;
    m.ends[s.id] = { winner: msg.winner, titanWins: msg.titanWins, villainWins: msg.villainWins };
    this.event('end', { session: s.id, match: m.id, data: m.ends[s.id] });
    const reports = m.players.map(id => m.ends[id]).filter(Boolean);
    if (reports.length < 2) {
      this.setTimer(m, 'end', this.config.timers.endTimeoutMs, () => this.settle(m));
      return;
    }
    this.settle(m);
  }

  // Both ends are in (or one is and the other never came): decide the result.
  settle(m) {
    if (m.state !== 'playing') return;
    const reports = m.players.map(id => m.ends[id]).filter(Boolean);
    const [a, b] = reports;
    if (b && (a.winner !== b.winner || a.titanWins !== b.titanWins || a.villainWins !== b.villainWins)) {
      this.event('end_mismatch', { match: m.id, data: { reports } });
      return this.finish(m, null, 'desync', {});
    }
    this.finish(m, a.winner, 'ko', { titanWins: a.titanWins, villainWins: a.villainWins });
  }

  stallCheck(m) {
    if (m.state !== 'playing') return;
    const now = this.now();
    const idle = Math.min(now - m.lastInputAt.titan, now - m.lastInputAt.villain);
    if (idle > this.config.timers.matchIdleMs) return this.abandon(m, 'idle');
    for (const side of SIDES) {
      const o = other(side);
      if (m.topFrame[side] < m.topFrame[o] && now - m.lastInputAt[side] > this.config.timers.stallForfeitMs) {
        this.event('forfeit', { session: m.sides[side], match: m.id, data: { reason: 'stall' } });
        this.finish(m, o, 'forfeit', {});
        return;
      }
    }
    this.setTimer(m, 'stall', 5_000, () => this.stallCheck(m));
  }

  finish(m, winner, reason, extra = {}) {
    if (m.state !== 'playing') return;
    for (const k of ['stall', 'end', 'ready']) this.clearTimer(m, k);
    m.state = 'finished';
    m.winner = winner; m.reason = reason; m.endedAt = this.now();
    if (extra.titanWins !== undefined) m.wins = { titan: extra.titanWins, villain: extra.villainWins };
    this.event('result', { match: m.id, data: { winner, reason, ...extra } });
    if (this.config.logInputs) this.event('inputs', { match: m.id, data: m.inputs });
    this.save(m);
    this.broadcast(m, { t: 'result', winner, reason, titanWins: m.wins.titan, villainWins: m.wins.villain, frame: extra.f ?? null });
    this.setTimer(m, 'rematch', this.config.timers.rematchTimeoutMs, () => this.closeMatch(m, 'rematch_timeout'));
  }

  onRematch(s, m, yes) {
    if (m.state !== 'finished') return;
    if (m.reason !== 'ko') return this.error(s, 'bad_state', 'this match cannot be replayed');
    if (!yes) {
      this.event('rematch_declined', { session: s.id, match: m.id });
      this.toOpponent(m, s.id, { t: 'rematch_declined', reason: 'declined' });
      return this.closeMatch(m, 'declined', { notify: false });
    }
    m.rematch[s.id] = true;
    this.event('rematch', { session: s.id, match: m.id });
    this.toOpponent(m, s.id, { t: 'rematch_pending' });
    if (!m.players.every(id => m.rematch[id])) return;
    const players = m.players.map(id => this.sessions.get(id));
    if (players.some(p => !p)) return this.closeMatch(m, 'opponent_gone');
    this.closeMatch(m, 'rematch', { notify: false, release: false });
    this.createMatch(players, { rematchOf: m.id, sides: m.sides, fighters: m.fighters });
  }

  // A player walks away (Esc in the game, Cancel in the lobby, closed tab past the grace period).
  leave(s, why) {
    this.clearTimer(s, 'grace');
    if (s.state === 'queued') return this.dequeue(s);
    const m = s.matchId ? this.matches.get(s.matchId) : null;
    if (!m) { s.state = 'idle'; return; }
    this.event('leave', { session: s.id, match: m.id, data: { why, state: m.state } });
    if (m.state === 'playing') {
      const side = this.sideFor(m, s.id);
      this.event('forfeit', { session: s.id, match: m.id, data: { reason: why } });
      this.finish(m, other(side), 'forfeit', {});
      return this.closeMatch(m, why, { except: s.id });
    }
    if (m.state === 'finished') return this.closeMatch(m, why, { except: s.id });
    this.abandon(m, why, s.id);
  }

  // The match never got going (someone left while picking/loading, or a timeout).
  abandon(m, reason, leaver = null) {
    if (['closed', 'abandoned', 'finished'].includes(m.state)) return;
    for (const k of Object.keys(m.timers)) this.clearTimer(m, k);
    m.state = 'abandoned'; m.reason = reason; m.endedAt = this.now();
    this.event('abandon', { match: m.id, data: { reason, leaver } });
    this.save(m);
    for (const id of m.players) {
      const p = this.sessions.get(id);
      if (p) { p.state = 'idle'; p.matchId = null; }
      if (id !== leaver) this.send(id, { t: 'opponent_left', reason, state: 'abandoned' });
    }
    if (leaver) { const p = this.sessions.get(leaver); if (p) this.send(leaver, { t: 'left' }); }
  }

  closeMatch(m, reason, { notify = true, except = null, release = true } = {}) {
    for (const k of Object.keys(m.timers)) this.clearTimer(m, k);
    if (m.state !== 'finished') { m.state = 'closed'; m.reason = m.reason || reason; }
    this.event('closed', { match: m.id, data: { reason } });
    this.save(m);
    for (const id of m.players) {
      const p = this.sessions.get(id);
      if (p && release) { p.state = 'idle'; p.matchId = null; }
      if (notify && id !== except) this.send(id, { t: 'opponent_left', reason, state: 'closed' });
    }
    this.matches.delete(m.id);
  }

  // ---- helpers ----------------------------------------------------------------------------

  sideFor(m, id) { return m.sides.titan === id ? 'titan' : m.sides.villain === id ? 'villain' : null; }
  opponentId(m, id) { return m.players.find(p => p !== id) ?? null; }
  opponentView(m, id) {
    const oid = this.opponentId(m, id);
    const o = this.sessions.get(oid);
    return { session: oid, name: o?.name ?? '?', side: this.sideFor(m, oid), pick: m.picks[oid] ?? null, locked: !!m.locked[oid], connected: !!o?.connected };
  }
  matchView(m, id) {
    return {
      id: m.id, state: m.state, side: this.sideFor(m, id), sides: { ...m.sides }, claimedBy: m.claimedBy,
      pick: m.picks[id] ?? null, locked: !!m.locked[id], fighters: { ...m.fighters },
      seed: m.seed, delay: m.delay, difficulty: m.difficulty, wins: { ...m.wins }, winner: m.winner, reason: m.reason,
      opponent: this.opponentView(m, id), gameUrl: GAME_URL,
    };
  }
  broadcast(m, msg) { for (const id of m.players) this.send(id, msg); }
  toOpponent(m, id, msg) { const oid = this.opponentId(m, id); if (oid) this.send(oid, msg); }
  error(s, code, msg) { this.send(s.id, { t: 'error', code, msg }); }
  event(type, { session = null, match = null, data = null } = {}) {
    this.db?.event(type, { session, match, data }, this.now());
    this.log(type, session, match, data);
  }
  save(m) { this.db?.saveMatch(m); }
  setTimer(owner, key, ms, fn) { this.clearTimer(owner, key); owner.timers[key] = this.timers.set(fn, ms); }
  clearTimer(owner, key) { if (owner.timers[key]) { this.timers.clear(owner.timers[key]); delete owner.timers[key]; } }
}
