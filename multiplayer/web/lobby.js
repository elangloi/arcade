// Lobby: name -> queue -> pick (first click claims a side) -> hand off to the game page.
// Talks to the service over one WebSocket; the session id comes from POST api/session.

const ASSETS = 'games/battleblitz/assets/select_screen/';
const ROSTER = {
  1: { name: 'Robin', on: '394_selection_robin.active.png', off: '104_selection_robin.inactive.png', hl: '089_selection_highlight.robin.png', fig: '240_figure_still_robin.png', moves: '179_name_and_moves_robin.png' },
  2: { name: 'Raven', on: '294_selection_raven.active.png', off: '103_selection_raven.inactive.png', hl: '290_selection_highlight.raven.png', fig: '237_figure_still_raven.png', moves: '178_name_and_moves_raven.png' },
  3: { name: 'Cyborg', on: '292_selection_cyborg.active.png', off: '102_selection_cyborg.inactive.png', hl: '090_selection_highlight.cyborg.png', fig: '242_figure_still_cyborg.png', moves: '398_name_and_moves_cyborg.png' },
  4: { name: 'Starfire', on: '395_selection_starfire.active.png', off: '105_selection_starfire.inactive.png', hl: '091_selection_highlight.starfire.png', fig: '244_figure_still_starfire.png', moves: '180_name_and_moves_starfire.png' },
  5: { name: 'Beast Boy', on: '296_selection_beast.active.png', off: '101_selection_beast.inactive.png', hl: '092_selection_highlight.beastboy.png', fig: '235_figure_still_beast.png', moves: '174_name_and_moves_beast.png' },
  6: { name: 'Jinx', on: '311_selection_jinx.active.png', off: '098_selection_jinx.inactive.png', hl: '093_selection_highlight.jinx.png', fig: '233_figure_still_jinx.png', moves: '176_name_and_moves_jinx.png' },
  7: { name: 'Gizmo', on: '308_selection_gizmo.active.png', off: '088_selection_gizmo.inactive.png', hl: '094_selection_highlight.gizmo.png', fig: '391_figure_still_gizmo.png', moves: '399_name_and_moves_gizmo.png' },
  8: { name: 'Mammoth', on: '321_selection_mammoth.active.png', off: '099_selection_mammoth.inactive.png', hl: '095_selection_highlight.mammoth.png', fig: '392_figure_still_mammoth.png', moves: '400_name_and_moves_mammoth.png' },
  9: { name: 'Cinderblock', on: '298_selection_cinder.active.png', off: '087_selection_cinder.inactive.png', hl: '096_selection_highlight.cinder.png', fig: '390_figure_still_cinderblock.png', moves: '397_name_and_moves_cinder.png' },
  10: { name: 'Plasmus', on: '324_selection_plasmus.active.png', off: '100_selection_plasmus.inactive.png', hl: '097_selection_highlight.plasmus.png', fig: '393_figure_still_plasmus.png', moves: '177_name_and_moves_plasmus.png' },
};
const SIDE_OF = f => (f <= 5 ? 'titan' : 'villain');
const LABEL = { titan: 'the Titans', villain: 'the villains' };

const $ = id => document.getElementById(id);
const params = new URLSearchParams(location.search);

const S = {
  session: null, name: null, ws: null, match: null, me: { side: null, pick: null, locked: false },
  opp: { name: '?', side: null, pick: null, locked: false }, pickDeadline: 0, timer: null, leaving: false,
};

// ---- panels ----
function show(id) { for (const p of document.querySelectorAll('.panelbox')) p.hidden = p.id !== id; }
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
      if (m.match && (m.match.state === 'picking')) { applyMatchView(m.match); show('p-pick'); }
      else if (m.match && (m.match.state === 'loading' || m.match.state === 'playing')) { goToGame(m.match.id); }
      else if (m.state === 'queued') { show('p-queue'); }
      break;
    case 'queued': $('qpos').textContent = '#' + m.position; show('p-queue'); $('subline').textContent = 'waiting for a challenger'; break;
    case 'matched':
      S.match = { id: m.matchId, claimedBy: null };
      S.me = { side: null, pick: null, locked: false };
      S.opp = { name: m.opponent.name, side: null, pick: null, locked: false };
      S.pickDeadline = Date.now() + (m.pickTimeoutMs || 120000);
      renderPick(); show('p-pick'); $('subline').textContent = 'choose your fighter';
      break;
    case 'sides':
      S.match.claimedBy = m.claimedBy;
      S.me.side = m.titan === S.session ? 'titan' : 'villain';
      S.opp.side = S.me.side === 'titan' ? 'villain' : 'titan';
      renderPick();
      $('pickStatus').textContent = m.claimedBy === S.session ? `You claimed ${LABEL[S.me.side]}!` : `${S.opp.name} took ${LABEL[S.opp.side]} — you fight for ${LABEL[S.me.side]}.`;
      break;
    case 'picked':
      if (m.session === S.session) S.me.pick = m.fighter; else S.opp.pick = m.fighter;
      renderPick();
      break;
    case 'locked':
      if (m.session === S.session) { S.me.locked = true; S.me.pick = m.fighter; } else { S.opp.locked = true; S.opp.pick = m.fighter; }
      renderPick();
      if (m.auto) $('pickStatus').textContent = 'Time! Fighters were locked automatically.';
      break;
    case 'fight': goToGame(m.matchId); break;
    case 'opponent_left': stopTimer(); message('Opponent left', `${S.opp.name} left before the fight. Back to the lobby to find someone else.`); break;
    case 'error': $('pickStatus').textContent = m.msg; $('nameStatus').textContent = m.code === 'no_name' ? m.msg : ''; break;
    case 'left': break;
    default: break;
  }
}

function applyMatchView(v) {
  S.match = { id: v.id, claimedBy: v.claimedBy };
  S.me = { side: v.side, pick: v.pick, locked: v.locked };
  S.opp = { name: v.opponent.name, side: v.opponent.side, pick: v.opponent.pick, locked: v.opponent.locked };
  S.pickDeadline = Date.now() + 120000;
  renderPick();
}

function goToGame(matchId) {
  stopTimer();
  S.leaving = true;
  const url = new URL('games/battleblitz/web/', location.href);
  url.searchParams.set('match', matchId);
  url.searchParams.set('session', S.session);
  if (params.has('mute')) url.searchParams.set('mute', '1');
  $('goLink').href = url.href;
  show('p-go');
  location.href = url.href;
}

// ---- pick screen ----
function buildRosters() {
  for (const side of ['titan', 'villain']) {
    const box = $('roster-' + side);
    box.textContent = '';
    for (const [id, f] of Object.entries(ROSTER)) {
      if (SIDE_OF(+id) !== side) continue;
      const b = document.createElement('button');
      b.className = 'fighter'; b.dataset.id = id; b.title = f.name; b.type = 'button';
      b.innerHTML = `<img class="off" src="${ASSETS}${f.off}" alt=""><img class="on" src="${ASSETS}${f.on}" alt="${f.name}">`;
      b.addEventListener('click', () => pick(+id));
      box.appendChild(b);
    }
  }
}

function pick(id) {
  if (S.me.locked) return;
  if (S.me.side && SIDE_OF(id) !== S.me.side) { $('pickStatus').textContent = `You fight for ${LABEL[S.me.side]}.`; return; }
  send({ t: 'pick', fighter: id });
}

function renderPick() {
  $('oppName').textContent = S.opp.name;
  for (const side of ['titan', 'villain']) {
    const box = $('side-' + side);
    box.classList.toggle('mine', S.me.side === side);
    box.classList.toggle('theirs', S.opp.side === side);
    box.classList.toggle('dead', !!S.me.side && S.me.side !== side);
    $('who-' + side).textContent = S.me.side === side ? 'you' : S.opp.side === side ? S.opp.name : '';
    for (const b of box.querySelectorAll('.fighter')) {
      const id = +b.dataset.id;
      const mine = S.me.pick === id, theirs = S.opp.pick === id;
      b.classList.toggle('picked', mine || theirs);
      b.classList.toggle('mine', mine);
      b.classList.toggle('theirs', theirs);
      b.classList.toggle('locked', (mine && S.me.locked) || (theirs && S.opp.locked));
      b.disabled = S.me.locked || (!!S.me.side && S.me.side !== side);
    }
  }
  $('lockBtn').disabled = S.me.locked || S.me.pick === null;
  $('lockBtn').textContent = S.me.locked ? (S.opp.locked ? 'Fight!' : `Waiting for ${S.opp.name}…`) : 'Lock in';
  // preview: my fighter on the left, theirs on the right (titan/villain order like the versus screen)
  const pv = $('preview');
  pv.textContent = '';
  const order = S.me.side === 'villain' ? [S.opp, S.me] : [S.me, S.opp];
  for (const p of order) {
    if (p.pick) {
      const f = ROSTER[p.pick];
      const fig = document.createElement('figure');
      fig.innerHTML = `<img class="fig" src="${ASSETS}${f.fig}" alt="${f.name}"><img class="moves" src="${ASSETS}${f.moves}" alt=""><figcaption>${p === S.me ? 'you' : escapeHtml(p.name)}</figcaption>`;
      pv.appendChild(fig);
    } else {
      const e = document.createElement('div'); e.className = 'empty'; e.textContent = p === S.me ? 'you' : p.name; pv.appendChild(e);
    }
  }
  startTimer();
}
const escapeHtml = s => String(s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

function startTimer() {
  if (S.timer) return;
  const tick = () => {
    const left = Math.max(0, Math.ceil((S.pickDeadline - Date.now()) / 1000));
    $('pickTimer').textContent = S.me.locked && S.opp.locked ? '' : `auto-lock in ${left}s`;
  };
  tick(); S.timer = setInterval(tick, 1000);
}
function stopTimer() { clearInterval(S.timer); S.timer = null; }

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
$('cancelQueue').addEventListener('click', () => { send({ t: 'leave' }); show('p-name'); $('subline').textContent = "who's fighting?"; });
$('lockBtn').addEventListener('click', () => { if (S.me.pick !== null) send({ t: 'lock', fighter: S.me.pick }); });
$('leavePick').addEventListener('click', () => { send({ t: 'leave' }); stopTimer(); show('p-name'); $('subline').textContent = "who's fighting?"; });
$('msgOk').addEventListener('click', () => { show('p-name'); $('subline').textContent = "who's fighting?"; });

(async function boot() {
  buildRosters();
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
