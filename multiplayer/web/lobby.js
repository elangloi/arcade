// Lobby: name -> queue -> matched -> hand off to the game page (fighter select is the game's own screen).
// Talks to the service over one WebSocket; the session id comes from POST api/session.

const $ = id => document.getElementById(id);
const params = new URLSearchParams(location.search);

const S = { session: null, name: null, ws: null, leaving: false };

// ---- panels ----
const MARQUEE = { 'p-name': 'Player name', 'p-queue': 'Now serving', 'p-go': 'Fight!', 'p-msg': 'Game over' };
function show(id) { for (const p of document.querySelectorAll('.panelbox')) p.hidden = p.id !== id; $('marquee').textContent = MARQUEE[id] || 'Battle Blitz'; }
function message(title, body) { $('msgTitle').textContent = title; $('msgBody').textContent = body; show('p-msg'); $('subline').textContent = title; }

// ---- session ----
async function getSession() {
  let id = params.get('session') || sessionStorage.getItem('mp.session');
  if (id) {
    const r = await fetch('api/session/' + encodeURIComponent(id), { cache: 'no-store' });
    if (r.ok) { const j = await r.json(); sessionStorage.setItem('mp.session', id); return { id, name: j.name, state: j.state }; }
  }
  const r = await fetch('api/session', { method: 'POST' });
  if (!r.ok) throw new Error('could not create a session');
  id = (await r.json()).sessionId;
  sessionStorage.setItem('mp.session', id);
  return { id, name: null, state: 'idle' };
}

// ---- socket ----
function connect() {
  return new Promise((resolve, reject) => {
    const url = new URL('ws', location.href);
    url.protocol = url.protocol === 'https:' ? 'wss:' : 'ws:';
    url.searchParams.set('session', S.session);
    const ws = new WebSocket(url);
    S.ws = ws;
    ws.onopen = () => send({ t: 'hello', name: S.name || undefined });
    ws.onmessage = ev => {
      const m = JSON.parse(ev.data);
      if (m.t === 'welcome') { resolve(m); }
      onMessage(m);
    };
    ws.onerror = () => reject(new Error('socket error'));
    ws.onclose = ev => {
      if (S.leaving) return;
      if (ev.code === 4000) { message('Opened elsewhere', 'This session was opened in another tab. Use that one, or reload here to take over.'); return; }
      $('subline').textContent = 'reconnecting…';
      setTimeout(() => connect().catch(() => {}), 1500);
    };
  });
}
const send = m => { if (S.ws && S.ws.readyState === 1) S.ws.send(JSON.stringify(m)); };

// ---- message handling ----
function onMessage(m) {
  switch (m.t) {
    case 'welcome':
      S.name = m.name || S.name;
      if (m.name) $('name').value = m.name;
      if (m.match && ['picking', 'loading', 'playing'].includes(m.match.state)) goToGame(m.match.id);
      else if (m.state === 'queued') show('p-queue');
      break;
    case 'queued': $('qpos').textContent = '#' + m.position; show('p-queue'); $('subline').textContent = 'waiting for a challenger'; break;
    case 'matched':               // fighter select happens in the game itself (the original screen)
      $('subline').textContent = `matched with ${m.opponent.name}`;
      goToGame(m.matchId);
      break;
    case 'opponent_left': message('Opponent left', 'They left before the fight. Back to the lobby to find someone else.'); break;
    case 'error': $('nameStatus').textContent = m.msg; break;
    case 'left': break;
    default: break;
  }
}

function goToGame(matchId) {
  S.leaving = true;
  const url = new URL('games/battleblitz/web/', location.href);
  url.searchParams.set('match', matchId);
  url.searchParams.set('session', S.session);
  if (params.has('mute')) url.searchParams.set('mute', '1');
  $('goLink').href = url.href;
  show('p-go');
  location.href = url.href;
}

// ---- wiring ----
$('nameForm').addEventListener('submit', ev => {
  ev.preventDefault();
  const n = $('name').value.trim().slice(0, 16);
  if (!n) { $('nameStatus').textContent = 'Type a name first.'; return; }
  S.name = n;
  sessionStorage.setItem('mp.name', n);
  send({ t: 'hello', name: n });
  send({ t: 'queue', game: 'battleblitz' });
  $('nameStatus').textContent = '';
});
$('cancelQueue').addEventListener('click', () => { send({ t: 'leave' }); show('p-name'); $('subline').textContent = 'two players · insert coin'; });
$('msgOk').addEventListener('click', () => { show('p-name'); $('subline').textContent = 'two players · insert coin'; });

(async function boot() {
  try {
    const s = await getSession();
    S.session = s.id;
    S.name = s.name || sessionStorage.getItem('mp.name') || null;
    if (S.name) $('name').value = S.name;
    show('p-name');
    await connect();
    if (params.get('auto') === '1' && S.name) { send({ t: 'queue', game: 'battleblitz' }); }   // playtest shortcut
  } catch (e) {
    message('Offline', 'Could not reach the multiplayer service: ' + e.message);
  }
})();
