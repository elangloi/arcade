import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { WebSocket } from 'ws';
import { createApp } from '../lib/app.js';
import { config as base } from '../lib/config.js';

let app, origin;
const clients = [];
before(async () => {
  app = createApp({ ...base, dbPath: ':memory:', dev: true, basePath: '/arcade/multiplayer', assetsDir: '../battleblitz/assets' });
  await new Promise(r => app.server.listen(0, '127.0.0.1', r));
  origin = `http://127.0.0.1:${app.server.address().port}`;
});
after(() => { for (const c of clients) c.ws.terminate(); app.close(); });

// A tiny client: queue of received messages + wait-for-type.
async function client(name) {
  const r = await fetch(`${origin}/arcade/multiplayer/api/session`, { method: 'POST' });
  assert.equal(r.status, 201);
  const { sessionId } = await r.json();
  const ws = new WebSocket(`${origin.replace('http', 'ws')}/arcade/multiplayer/ws?session=${sessionId}`);
  const inbox = []; const waiters = [];
  ws.on('message', d => { const m = JSON.parse(String(d)); inbox.push(m); for (const w of waiters.splice(0)) if (!w()) waiters.push(w); });
  await new Promise((res, rej) => { ws.once('open', res); ws.once('error', rej); });
  const send = m => ws.send(JSON.stringify(m));
  const next = (t, timeout = 3000) => new Promise((res, rej) => {
    const timer = setTimeout(() => rej(new Error(`timeout waiting for ${t}; inbox=${JSON.stringify(inbox)}`)), timeout);
    const check = () => { const i = inbox.findIndex(m => m.t === t); if (i >= 0) { clearTimeout(timer); res(inbox.splice(i, 1)[0]); return true; } return false; };
    if (!check()) waiters.push(check);
  });
  send({ t: 'hello', name });
  const welcome = await next('welcome');
  const c = { id: sessionId, ws, send, next, inbox, welcome };
  clients.push(c);
  return c;
}

test('http: healthz, stats, unknown session, static mounts', async () => {
  assert.equal((await fetch(`${origin}/arcade/multiplayer/healthz`)).status, 200);
  const stats = await (await fetch(`${origin}/arcade/multiplayer/api/stats`)).json();
  assert.deepEqual(Object.keys(stats).sort(), ['online', 'playing', 'queued']);
  assert.equal((await fetch(`${origin}/arcade/multiplayer/api/session/nope`)).status, 404);
  assert.equal((await fetch(`${origin}/arcade/multiplayer/`)).status, 200);
  assert.equal((await fetch(`${origin}/`)).status, 200);                       // base path is optional (dev)
  const game = await fetch(`${origin}/arcade/multiplayer/games/battleblitz/web/`);
  assert.equal(game.status, 200);
  assert.match(await game.text(), /mp\.js|main\.js/);
  const asset = await fetch(`${origin}/arcade/multiplayer/games/battleblitz/assets/members.json`, { method: 'HEAD' });
  assert.equal(asset.status, 200);
  assert.match(asset.headers.get('cache-control'), /immutable/);
  assert.equal((await fetch(`${origin}/arcade/multiplayer/games/battleblitz/web/../../../package.json`)).status, 404);
  assert.equal((await fetch(`${origin}/arcade/multiplayer/games/battleblitz/web/%2e%2e/%2e%2e/%2e%2e/package.json`)).status, 404);
});

test('ws: unknown session is refused', async () => {
  const ws = new WebSocket(`${origin.replace('http', 'ws')}/arcade/multiplayer/ws?session=nope`);
  const err = await new Promise(res => ws.once('error', res));
  assert.match(err.message, /400/);
});

test('two clients: queue, first pick claims a side, lock, fight, ready, start, relay, end, rows', async () => {
  const a = await client('Ann'), b = await client('Bob');
  assert.equal(a.welcome.name, 'Ann');
  a.send({ t: 'queue' }); await a.next('queued');
  b.send({ t: 'queue' });
  const [ma, mb] = await Promise.all([a.next('matched'), b.next('matched')]);
  assert.equal(ma.matchId, mb.matchId);
  b.send({ t: 'pick', fighter: 8 });                       // Bob goes villain (Mammoth)
  const sides = await a.next('sides');
  assert.equal(sides.villain, b.id); assert.equal(sides.titan, a.id);
  await b.next('picked');
  a.send({ t: 'pick', fighter: 6 });
  assert.equal((await a.next('error')).code, 'wrong_side');
  a.send({ t: 'lock', fighter: 5 });                       // lock with an inline pick
  await Promise.all([a.next('locked'), b.next('locked')]);
  b.send({ t: 'lock' });
  const [fa, fb] = await Promise.all([a.next('fight'), b.next('fight')]);
  assert.equal(fa.side, 'titan'); assert.equal(fb.side, 'villain');
  assert.equal(fa.titan, 5); assert.equal(fa.villain, 8); assert.equal(fa.seed, fb.seed);
  assert.equal(fa.gameUrl, 'games/battleblitz/web/');
  a.send({ t: 'ready' }); b.send({ t: 'ready' });
  const [sa, sb] = await Promise.all([a.next('start'), b.next('start')]);
  assert.equal(sa.delay, sb.delay);
  a.send({ t: 'in', f: 3, e: [[6, 1, 100]] });
  const inb = await b.next('in');
  assert.deepEqual(inb, { t: 'in', f: 3, e: [[6, 1, 100]] });
  a.send({ t: 'end', winner: 'titan', titanWins: 2, villainWins: 0 });
  b.send({ t: 'end', winner: 'titan', titanWins: 2, villainWins: 0 });
  const [ra, rb] = await Promise.all([a.next('result'), b.next('result')]);
  assert.equal(ra.winner, 'titan'); assert.equal(rb.reason, 'ko');
  const row = app.db.getMatch(ma.matchId);
  assert.equal(row.titan_session, a.id); assert.equal(row.villain_session, b.id); assert.equal(row.side_claimed_by, b.id);
  const ev = await (await fetch(`${origin}/arcade/multiplayer/api/events?match=${ma.matchId}`)).json();
  assert.ok(ev.some(e => e.type === 'side_claimed'));
  assert.equal(app.lobby.stats().playing, 0);
  a.send({ t: 'rematch', yes: false });
  await b.next('rematch_declined');
  a.ws.close(); b.ws.close();
});

test('a newer socket for the same session replaces the old one', async () => {
  const a = await client('Ann');
  const ws2 = new WebSocket(`${origin.replace('http', 'ws')}/arcade/multiplayer/ws?session=${a.id}`);
  const closed = new Promise(res => a.ws.once('close', code => res(code)));
  await new Promise(r => ws2.once('open', r));
  assert.equal(await closed, 4000);
  ws2.close();
});
