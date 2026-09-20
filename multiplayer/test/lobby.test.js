import { test } from 'node:test';
import assert from 'node:assert/strict';
import { Lobby } from '../lib/lobby.js';
import { openDb } from '../lib/db.js';
import { parseClientMessage } from '../lib/protocol.js';

// Deterministic timers + clock for the lobby's timeouts.
class Clock {
  constructor() { this.t = 1_000_000; this.q = []; this.n = 0; }
  now() { return this.t; }
  set(fn, ms) { const h = ++this.n; this.q.push({ h, at: this.t + ms, fn }); return h; }
  clear(h) { this.q = this.q.filter(e => e.h !== h); }
  advance(ms) {
    const until = this.t + ms;
    for (;;) {
      this.q.sort((a, b) => a.at - b.at);
      const e = this.q[0];
      if (!e || e.at > until) break;
      this.q.shift(); this.t = e.at; e.fn();
    }
    this.t = until;
  }
}

const CONFIG = {
  game: { inputDelay: 3, difficulty: 1 },
  logInputs: true,
  timers: { pickTimeoutMs: 120_000, reconnectGraceMs: 20_000, readyTimeoutMs: 90_000, stallForfeitMs: 45_000,
    matchIdleMs: 600_000, rematchTimeoutMs: 60_000, endTimeoutMs: 10_000 },
};

function setup() {
  const clock = new Clock();
  const out = new Map();
  const db = openDb(':memory:');
  const lobby = new Lobby({
    send: (id, msg) => { if (!out.has(id)) out.set(id, []); out.get(id).push(msg); },
    db, config: CONFIG, timers: { set: (fn, ms) => clock.set(fn, ms), clear: h => clock.clear(h) },
    now: () => clock.now(), random: () => 12345,
  });
  const drain = id => { const l = out.get(id) || []; out.set(id, []); return l; };
  const last = (id, t) => drain(id).filter(m => m.t === t).pop();
  const player = name => { const s = lobby.createSession(); lobby.connect(s.id, { name }); return s.id; };
  const send = (id, msg) => { const r = parseClientMessage(JSON.stringify(msg)); assert.equal(r.error, undefined, r.error); lobby.handle(id, r.msg); };
  return { clock, lobby, db, drain, last, player, send };
}

// Two players queue, the first click claims a side, both lock, both ready -> playing.
function toFight(x, { firstPick = 7, secondPick = 2 } = {}) {
  const a = x.player('Ann'), b = x.player('Bob');
  x.send(a, { t: 'queue', game: 'battleblitz' });
  assert.equal(x.last(a, 'queued').position, 1);
  x.send(b, { t: 'queue', game: 'battleblitz' });
  const ma = x.last(a, 'matched'), mb = x.last(b, 'matched');
  assert.ok(ma && mb && ma.matchId === mb.matchId);
  assert.equal(ma.opponent.name, 'Bob');
  x.send(a, { t: 'pick', fighter: firstPick });        // Ann clicks first
  x.send(b, { t: 'pick', fighter: secondPick });
  x.send(a, { t: 'lock' });
  x.send(b, { t: 'lock' });
  const fa = x.last(a, 'fight'), fb = x.last(b, 'fight');
  x.send(a, { t: 'ready' });
  x.send(b, { t: 'ready' });
  return { a, b, fa, fb, matchId: ma.matchId };
}

test('first click claims a side and locks the opponent into the other one', () => {
  const x = setup();
  const a = x.player('Ann'), b = x.player('Bob');
  x.send(a, { t: 'queue' }); x.send(b, { t: 'queue' });
  x.drain(a); x.drain(b);
  x.send(b, { t: 'pick', fighter: 3 });       // Bob clicks Cyborg first -> Bob is a Titan, Ann a villain
  const sides = x.last(a, 'sides');
  assert.equal(sides.titan, b); assert.equal(sides.villain, a); assert.equal(sides.claimedBy, b);
  x.send(a, { t: 'pick', fighter: 1 });       // Ann tries a Titan
  assert.equal(x.last(a, 'error').code, 'wrong_side');
  x.send(a, { t: 'pick', fighter: 9 });
  const picked = x.last(b, 'picked');
  assert.deepEqual([picked.session, picked.side, picked.fighter], [a, 'villain', 9]);
  x.send(b, { t: 'pick', fighter: 4 });       // change of mind within the side is fine
  assert.equal(x.last(a, 'picked').fighter, 4);
  x.send(a, { t: 'lock' }); x.send(b, { t: 'lock' });
  const f = x.last(a, 'fight');
  assert.equal(f.side, 'villain'); assert.equal(f.titan, 4); assert.equal(f.villain, 9); assert.equal(f.delay, 3);
  assert.equal(x.last(b, 'fight').side, 'titan');
});

test('FIFO pairing and a third player waits', () => {
  const x = setup();
  const ids = ['A', 'B', 'C'].map(n => x.player(n));
  for (const id of ids) x.send(id, { t: 'queue' });
  assert.ok(x.last(ids[0], 'matched')); assert.ok(x.last(ids[1], 'matched'));
  assert.equal(x.last(ids[2], 'queued').position, 1);
  assert.deepEqual(x.lobby.stats(), { online: 3, queued: 1, playing: 0 });
  x.send(ids[2], { t: 'leave' });
  assert.equal(x.lobby.stats().queued, 0);
});

test('queue needs a name', () => {
  const x = setup();
  const s = x.lobby.createSession(); x.lobby.connect(s.id, {});
  x.send(s.id, { t: 'queue' });
  assert.equal(x.last(s.id, 'error').code, 'no_name');
});

test('inputs relay to the opponent only, checksums are compared, ends agree', () => {
  const x = setup();
  const { a, b, fa } = toFight(x);
  assert.equal(fa.side, 'villain');            // Ann picked Gizmo (7) first
  assert.ok(x.last(a, 'start') && x.last(b, 'start'));
  x.send(a, { t: 'in', f: 3, e: [[124, 1, 1000]] });
  x.send(b, { t: 'in', f: 3, e: [] });
  assert.deepEqual(x.drain(b).filter(m => m.t === 'in'), [{ t: 'in', f: 3, e: [[124, 1, 1000]] }]);
  assert.deepEqual(x.drain(a).filter(m => m.t === 'in'), [{ t: 'in', f: 3, e: [] }]);
  x.send(a, { t: 'sum', f: 30, h: 42 }); x.send(b, { t: 'sum', f: 30, h: 42 });
  assert.equal(x.lobby.matches.size, 1);
  x.send(a, { t: 'end', winner: 'titan', titanWins: 2, villainWins: 1 });
  assert.equal(x.drain(a).filter(m => m.t === 'result').length, 0);
  x.send(b, { t: 'end', winner: 'titan', titanWins: 2, villainWins: 1 });
  const r = x.last(a, 'result');
  assert.equal(r.winner, 'titan'); assert.equal(r.reason, 'ko'); assert.equal(r.titanWins, 2);
  const row = x.db.getMatch(fa.matchId);
  assert.equal(row.state, 'finished'); assert.equal(row.winner, 'titan'); assert.equal(row.titan_wins, 2);
  const types = x.db.eventsFor(fa.matchId).map(e => e.type);
  for (const t of ['matched', 'side_claimed', 'pick', 'lock', 'fight', 'ready', 'start', 'end', 'result', 'inputs']) assert.ok(types.includes(t), t);
});

test('checksum mismatch voids the match', () => {
  const x = setup();
  const { a, b, matchId } = toFight(x);
  x.send(a, { t: 'sum', f: 60, h: 1 }); x.send(b, { t: 'sum', f: 60, h: 2 });
  assert.equal(x.last(a, 'result').reason, 'desync');
  assert.equal(x.last(b, 'result').frame, 60);
  assert.equal(x.db.getMatch(matchId).reason, 'desync');
  x.send(a, { t: 'rematch', yes: true });
  assert.equal(x.last(a, 'error').code, 'bad_state');
});

test('single end report settles after the end timeout', () => {
  const x = setup();
  const { a, b } = toFight(x);
  x.send(a, { t: 'end', winner: 'villain', titanWins: 0, villainWins: 2 });
  x.clock.advance(10_000);
  assert.equal(x.last(b, 'result').winner, 'villain');
});

test('leaving mid-fight forfeits', () => {
  const x = setup();
  const { a, b } = toFight(x);
  x.send(a, { t: 'leave' });                    // Ann (villain) walks
  const got = x.drain(b);
  const r = got.find(m => m.t === 'result');
  assert.equal(r.winner, 'titan'); assert.equal(r.reason, 'forfeit');
  assert.ok(got.find(m => m.t === 'opponent_left'));
  assert.equal(x.lobby.getSession(a).state, 'idle');
  assert.equal(x.lobby.getSession(b).state, 'idle');
  assert.equal(x.lobby.matches.size, 0);
});

test('disconnect: grace period, resume replay, then forfeit if they never come back', () => {
  const x = setup();
  const { a, b } = toFight(x);
  x.send(a, { t: 'in', f: 3, e: [] }); x.send(a, { t: 'in', f: 4, e: [[6, 1, 5]] });
  x.send(b, { t: 'in', f: 3, e: [] });
  x.lobby.disconnect(b);
  assert.deepEqual(x.last(a, 'opponent_away').hidden, true);
  x.send(a, { t: 'in', f: 5, e: [] });          // sent while Bob is away: buffered
  x.clock.advance(5_000);
  x.lobby.connect(b, {});
  assert.equal(x.last(a, 'opponent_away').hidden, false);
  x.drain(b);
  x.send(b, { t: 'resume', have: 3 });
  const got = x.drain(b);
  assert.deepEqual(got.filter(m => m.t === 'in').map(m => m.f), [4, 5]);
  assert.equal(got.find(m => m.t === 'resume_ack').have, 3);
  // and now Bob vanishes for good
  x.lobby.disconnect(b);
  x.clock.advance(20_000);
  const r = x.last(a, 'result');
  assert.equal(r.reason, 'forfeit'); assert.equal(r.winner, 'villain');
});

test('stalled side forfeits; both idle is just idle', () => {
  const x = setup();
  const { a, b } = toFight(x);
  for (let f = 3; f < 100; f++) x.send(a, { t: 'in', f, e: [] });
  x.send(b, { t: 'in', f: 3, e: [] });
  x.clock.advance(30_000);
  assert.equal(x.drain(a).filter(m => m.t === 'result').length, 0);
  x.clock.advance(20_000);
  const r = x.last(a, 'result');
  assert.equal(r.reason, 'forfeit'); assert.equal(r.winner, 'villain');
});

test('pick timeout locks what was picked, coin-flips if nobody clicked', () => {
  const x = setup();
  const a = x.player('Ann'), b = x.player('Bob');
  x.send(a, { t: 'queue' }); x.send(b, { t: 'queue' });
  x.clock.advance(120_000);
  const fa = x.last(a, 'fight'), fb = x.last(b, 'fight');
  assert.ok(fa && fb);
  assert.notEqual(fa.side, fb.side);
  assert.equal(fa.titan, 1); assert.equal(fa.villain, 6);
});

test('rematch keeps sides and fighters, new seed; declining closes', () => {
  const x = setup();
  let seed = 1;
  x.lobby.random = () => seed++;
  const { a, b, fa } = toFight(x);
  x.send(a, { t: 'end', winner: 'titan', titanWins: 2, villainWins: 0 });
  x.send(b, { t: 'end', winner: 'titan', titanWins: 2, villainWins: 0 });
  x.send(a, { t: 'rematch', yes: true });
  assert.ok(x.last(b, 'rematch_pending'));
  x.send(b, { t: 'rematch', yes: true });
  const f2a = x.last(a, 'fight'), f2b = x.last(b, 'fight');
  assert.notEqual(f2a.matchId, fa.matchId);
  assert.equal(f2a.rematchOf, fa.matchId);
  assert.equal(f2a.side, fa.side); assert.equal(f2a.titan, fa.titan); assert.equal(f2a.villain, fa.villain);
  assert.notEqual(f2a.seed, fa.seed);
  assert.equal(f2b.side, 'titan');
  x.send(a, { t: 'ready' }); x.send(b, { t: 'ready' });
  assert.ok(x.last(a, 'start'));
  x.send(a, { t: 'end', winner: 'villain', titanWins: 1, villainWins: 2 });
  x.send(b, { t: 'end', winner: 'villain', titanWins: 1, villainWins: 2 });
  x.send(b, { t: 'rematch', yes: false });
  assert.ok(x.last(a, 'rematch_declined'));
  assert.equal(x.lobby.getSession(a).state, 'idle');
  assert.equal(x.lobby.matches.size, 0);
});

test('rematch offer times out', () => {
  const x = setup();
  const { a, b } = toFight(x);
  x.send(a, { t: 'end', winner: 'titan', titanWins: 2, villainWins: 0 });
  x.send(b, { t: 'end', winner: 'titan', titanWins: 2, villainWins: 0 });
  x.send(a, { t: 'rematch', yes: true });
  x.clock.advance(60_000);
  assert.ok(x.last(a, 'opponent_left'));
  assert.equal(x.lobby.getSession(a).state, 'idle');
});

test('leaving while picking abandons and frees the opponent', () => {
  const x = setup();
  const a = x.player('Ann'), b = x.player('Bob');
  x.send(a, { t: 'queue' }); x.send(b, { t: 'queue' });
  x.send(a, { t: 'leave' });
  assert.equal(x.last(b, 'opponent_left').state, 'abandoned');
  assert.equal(x.lobby.getSession(b).state, 'idle');
  x.send(b, { t: 'queue' });
  assert.equal(x.last(b, 'queued').position, 1);
});

test('welcome carries the match for a reconnecting lobby tab', () => {
  const x = setup();
  const a = x.player('Ann'), b = x.player('Bob');
  x.send(a, { t: 'queue' }); x.send(b, { t: 'queue' });
  x.send(a, { t: 'pick', fighter: 2 });
  const w = x.lobby.connect(b, {});
  assert.equal(w.state, 'matched');
  assert.equal(w.match.side, 'villain');
  assert.equal(w.match.opponent.pick, 2);
  assert.equal(w.match.opponent.name, 'Ann');
});

test('protocol rejects junk', () => {
  for (const raw of ['nope', '{}', '{"t":"pick","fighter":11}', '{"t":"in","f":1,"e":[[1,2,3]]}', '{"t":"end","winner":"me","titanWins":0,"villainWins":0}', '{"t":"wat"}']) {
    assert.ok(parseClientMessage(raw).error, raw);
  }
  assert.ok(parseClientMessage('{"t":"in","f":1,"e":[[124,1,99]]}').msg);
});
