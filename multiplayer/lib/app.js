// The HTTP + WebSocket application. server.js binds it to a port; tests bind it to port 0.
import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { WebSocketServer } from 'ws';
import { openDb } from './db.js';
import { Lobby } from './lobby.js';
import { makeStatic } from './static.js';
import { parseClientMessage } from './protocol.js';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

export function createApp(config) {
  const db = openDb(config.dbPath);
  const sockets = new Map();   // session id -> ws
  let closing = false;

  const lobby = new Lobby({
    db, config,
    send: (id, msg) => { const ws = sockets.get(id); if (ws && ws.readyState === ws.OPEN) ws.send(JSON.stringify(msg)); },
    log: (type, session, match) => { if (config.dev) console.log(`[${type}]`, session ? session.slice(0, 8) : '-', match ? match.slice(0, 8) : '-'); },
  });

  const serveStatic = makeStatic([
    { url: '/games/battleblitz/web/', dir: path.join(ROOT, 'games/battleblitz/web') },
    { url: '/games/battleblitz/assets/', dir: path.resolve(ROOT, config.assetsDir), immutable: true },
  ]);

  const json = (res, code, body) => { res.writeHead(code, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }); res.end(JSON.stringify(body)); };
  const stripBase = p => (config.basePath && p.startsWith(config.basePath) ? p.slice(config.basePath.length) || '/' : p);

  const server = http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://x');
    const p = stripBase(url.pathname);
    try {
      if (p === '/healthz') return json(res, 200, { ok: true, ...lobby.stats() });
      if (p === '/api/session' && req.method === 'POST') {
        const s = lobby.createSession();
        return json(res, 201, { sessionId: s.id });
      }
      if (p.startsWith('/api/session/') && req.method === 'GET') {
        const s = lobby.getSession(p.slice('/api/session/'.length));
        return s ? json(res, 200, { sessionId: s.id, name: s.name, state: s.state, matchId: s.matchId }) : json(res, 404, { error: 'unknown session' });
      }
      if (p === '/api/stats') return json(res, 200, lobby.stats());
      if (p === '/api/events' && config.dev) {
        const m = url.searchParams.get('match');
        return m ? json(res, 200, db.eventsFor(m)) : json(res, 400, { error: 'match=' });
      }
      if (p.startsWith('/api/')) return json(res, 404, { error: 'not found' });
      if (p === '/' || p === '') return json(res, 200, { service: 'arcade-multiplayer', lobby: 'the arcade front end at /multiplayer', api: config.basePath + '/api', ws: config.basePath + '/ws' });
      if (await serveStatic(req, res, p)) return;
      res.writeHead(404, { 'Content-Type': 'text/plain' }); res.end('not found');
    } catch (e) {
      console.error(e);
      if (!res.headersSent) json(res, 500, { error: 'server error' });
    }
  });

  // ---- WebSocket: one per session, /ws?session=<id>
  const wss = new WebSocketServer({ noServer: true });
  server.on('upgrade', (req, socket, head) => {
    const url = new URL(req.url, 'http://x');
    if (stripBase(url.pathname) !== '/ws') { socket.destroy(); return; }
    const origin = req.headers.origin;
    if (config.allowedOrigins.length && origin && !config.allowedOrigins.includes(origin)) { socket.write('HTTP/1.1 403 Forbidden\r\n\r\n'); socket.destroy(); return; }
    const sid = url.searchParams.get('session');
    if (!sid || !lobby.getSession(sid)) { socket.write('HTTP/1.1 400 Bad Request\r\n\r\nunknown session'); socket.destroy(); return; }
    wss.handleUpgrade(req, socket, head, ws => wss.emit('connection', ws, req, sid));
  });

  wss.on('connection', (ws, req, sid) => {
    const old = sockets.get(sid);
    if (old && old !== ws) { old.replaced = true; old.close(4000, 'replaced by a newer connection'); }
    sockets.set(sid, ws);
    ws.alive = true; ws.pingAt = 0;
    ws.on('pong', () => { ws.alive = true; if (ws.pingAt) lobby.setRtt(sid, Date.now() - ws.pingAt); });
    ws.on('message', data => {
      const r = parseClientMessage(String(data));
      if (r.error) { ws.send(JSON.stringify({ t: 'error', code: 'bad_message', msg: r.error })); return; }
      if (r.msg.t === 'hello') {
        const w = lobby.connect(sid, { name: r.msg.name });
        ws.send(JSON.stringify(w));
        ws.pingAt = Date.now(); ws.ping();
        return;
      }
      lobby.handle(sid, r.msg);
    });
    ws.on('close', () => { if (closing) return; if (sockets.get(sid) === ws) { sockets.delete(sid); lobby.disconnect(sid); } });
    ws.on('error', e => console.warn('ws error', sid.slice(0, 8), e.message));
  });

  // Liveness + RTT sampling.
  setInterval(() => {
    for (const ws of wss.clients) {
      if (!ws.alive) { ws.terminate(); continue; }
      ws.alive = false; ws.pingAt = Date.now(); ws.ping();
    }
  }, 15_000).unref();
  setInterval(() => lobby.gc(), 60_000).unref();

  const close = () => { closing = true; for (const ws of wss.clients) ws.terminate(); lobby.shutdown(); wss.close(); server.close(); db.close(); };
  return { server, lobby, db, wss, close, assetsDir: path.resolve(ROOT, config.assetsDir) };
}
