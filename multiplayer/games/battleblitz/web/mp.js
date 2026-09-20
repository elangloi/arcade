// Online 2-player Battle Blitz: deterministic lockstep over the lobby's WebSocket.
//
// Both browsers run the full game (titan = `player`, villain = `enemy`, playMode "as titans" on
// BOTH machines so the simulation is identical); only key events cross the wire, each stamped with
// the frame it must be applied on (current frame + input delay). The local keyboard drives whichever
// fighter this session locked in; the opponent's adapter is fed from their packets.
import { G, PL, setRandomSource } from './runtime/lingo.js';
import { D } from './runtime/director.js';
import * as game from './game/classes.js';

const KEYS = new Set([126, 125, 124, 123, 6, 7]);            // up, down, right, left, Z, X
const KEY_ESC = 53;
const KEYADAPTER = { 1: 'Class_RobinKeyAdapter', 2: 'Class_RavenKeyAdapter', 3: 'Class_CyborgKeyAdapter', 4: 'Class_StarfireKeyAdapter',
  5: 'Class_BeastboyKeyAdapter', 6: 'Class_JinxKeyAdapter', 7: 'Class_GizmoKeyAdapter', 8: 'Class_MammothKeyAdapter',
  9: 'Class_CinderblockKeyAdapter', 10: 'Class_PlasmusKeyAdapter' };
const NAMES = { 1: 'Robin', 2: 'Raven', 3: 'Cyborg', 4: 'Starfire', 5: 'Beast Boy', 6: 'Jinx', 7: 'Gizmo', 8: 'Mammoth', 9: 'Cinderblock', 10: 'Plasmus' };
const SUM_EVERY = 30;
const STALL_OVERLAY_MS = 300;

export const mp = {
  phase: 'connecting',     // connecting | free | waitReady | lockstep | ended | dead
  session: null, matchId: null, side: null, match: null, opponent: null,
  ws: null, delay: 3, seed: 0,
  simFrame: 0, local: new Map(), remote: new Map(), pending: [],
  stalledSince: 0, rtt: null, sums: [],
  ui: null, lobbyUrl: null, offline: false,
};
window.mp = mp;

// ---------------------------------------------------------------- setup

export async function install({ session, match, mute } = {}) {
  mp.session = session; mp.matchId = match;
  mp.lobbyUrl = new URL('../../../lobby.html', location.href);
  if (session) mp.lobbyUrl.searchParams.set('session', session);
  if (mute) mp.lobbyUrl.searchParams.set('mute', '1');
  buildOverlay();
  patchGame();
  if (match === 'selftest') { mp.offline = true; mp.phase = 'free'; return; }
  if (!session || !match) { fatal('Open this from the lobby', 'This page needs a match. Head back to the lobby to find an opponent.'); return; }
  await connect({ first: true });
}

// Call once D.start() has run (G.g exists): jump straight to the versus screen.
export function begin() {
  if (mp.phase === 'dead') return;
  if (mp.offline) { setStatus('self test'); return; }
  applyMatchGlobals();
  mp.phase = 'free';
  G.g.goFrame = D.label('SCREEN_VERSUS');
  setStatus('loading the fight…');
}

function applyMatchGlobals() {
  const g = G.g, m = mp.match;
  g.difficulty = m.difficulty; g.playMode = g.PLAYMODE_AS_TITANS;
  g.titanID = m.titan; g.villainID = m.villain;
  g.playerID = g.titanID; g.enemyID = g.villainID;
  setRandomSource(mulberry32(m.seed));
}

// ---------------------------------------------------------------- socket

function connect({ first = false } = {}) {
  return new Promise(resolve => {
    const url = new URL('../../../ws', location.href);
    url.protocol = url.protocol === 'https:' ? 'wss:' : 'ws:';
    url.searchParams.set('session', mp.session);
    const ws = new WebSocket(url);
    mp.ws = ws;
    let settled = false;
    ws.onopen = () => send({ t: 'hello', match: mp.matchId });
    ws.onmessage = ev => { const m = JSON.parse(ev.data); if (m.t === 'welcome' && !settled) { settled = true; onWelcome(m, first); resolve(true); } onMessage(m); };
    ws.onclose = ev => {
      if (mp.phase === 'dead' || (mp.phase === 'ended' && mp.leaving)) return;
      if (ev.code === 4000) { fatal('Opened elsewhere', 'This match was opened in another tab.'); return; }
      if (!settled) { settled = true; resolve(false); }
      if (mp.phase === 'lockstep' || mp.phase === 'waitReady' || mp.phase === 'free') {
        modal('reconnect', 'Connection lost', 'Trying to reconnect…', []);
        setTimeout(() => connect(), 1000);
      }
    };
    ws.onerror = () => {};
  });
}
const send = m => { if (mp.ws && mp.ws.readyState === 1) mp.ws.send(JSON.stringify(m)); };

function onWelcome(w, first) {
  const v = w.match;
  if (!v || v.id !== mp.matchId) {
    // A rematch replaces the match id; otherwise the match is gone (or this page was reloaded mid-fight).
    if (v && v.rematchOf === mp.matchId) { mp.matchId = v.id; } else { fatal('No such match', 'This match is over. Back to the lobby to find a new one.'); return; }
  }
  mp.match = { titan: v.fighters.titan, villain: v.fighters.villain, seed: v.seed, delay: v.delay, difficulty: v.difficulty };
  mp.side = v.side; mp.opponent = v.opponent; mp.delay = v.delay; mp.seed = v.seed;
  mp.ui.opp.textContent = `${mp.opponent.name} · ${mp.opponent.side === 'titan' ? 'Titans' : 'villains'}`;
  mp.ui.me.textContent = `you · ${mp.side === 'titan' ? 'Titans' : 'villains'} · ${NAMES[mp.match[mp.side]]}`;
  if (first) {
    if (v.state !== 'loading' && v.state !== 'playing') { fatal('Match is over', `This match already ended (${v.state}).`); return; }
    if (v.state === 'playing') { fatal('Match in progress', 'This fight is already running (was the page reloaded?). It counts as a forfeit — back to the lobby.'); send({ t: 'leave' }); return; }
    return;
  }
  // reconnected mid-fight: catch up on the opponent's packets, resend ours
  hideModal('reconnect');
  if (mp.phase === 'lockstep') send({ t: 'resume', have: highestFrame(mp.remote) });
  else if (mp.phase === 'waitReady') send({ t: 'ready' });
}

function onMessage(m) {
  switch (m.t) {
    case 'start':
      mp.delay = m.delay; mp.seed = m.seed;
      startLockstep();
      break;
    case 'in':
      mp.remote.set(m.f, m.e);
      break;
    case 'resume_ack':
      if (m.state !== 'playing') return;
      for (const [f, e] of mp.local) if (f > m.have) send({ t: 'in', f, e });
      break;
    case 'result':
      onResult(m);
      break;
    case 'rematch_pending':
      setStatus(`${mp.opponent.name} wants a rematch`);
      break;
    case 'rematch_declined':
      modal('result', 'No rematch', `${mp.opponent.name} went back to the lobby.`, [['Back to lobby', leaveToLobby]]);
      break;
    case 'fight':                 // a rematch
      mp.matchId = m.matchId;
      mp.match = { titan: m.titan, villain: m.villain, seed: m.seed, delay: m.delay, difficulty: m.difficulty };
      mp.side = m.side; mp.delay = m.delay; mp.seed = m.seed;
      restartForRematch();
      break;
    case 'opponent_away':
      if (m.hidden) modal('away', `${mp.opponent.name} is away`, m.reason === 'disconnected' ? 'Their connection dropped — waiting for them to come back…' : 'They switched tabs. The fight waits.', []);
      else hideModal('away');
      break;
    case 'opponent_left':
      if (mp.phase !== 'ended') modal('result', `${mp.opponent.name} left`, mp.phase === 'lockstep' ? 'They gave up. You win by forfeit.' : 'They went back to the lobby before the fight started.', [['Back to lobby', leaveToLobby]]);
      else { hideModal('away'); setStatus(`${mp.opponent.name} left`); const b = mp.ui.modals.result?.querySelector('[data-rematch]'); if (b) b.disabled = true; }
      break;
    case 'pong': mp.rtt = performance.now() - m.ts; updateRtt(); break;
    case 'error': setStatus(m.msg); break;
    default: break;
  }
}

// ---------------------------------------------------------------- game hooks

function patchGame() {
  const GS = game.Class_GameScreen.prototype;
  const origLoad = GS.load;
  GS.load = function () {
    origLoad.call(this);
    const keyMgr = G.g.main.keyMgr;
    keyMgr.resetListeners();            // drops the local KeyAdapter and the screen's own P/cheat handling
    keyMgr.addListener(mpListener);
    this.playerAdapter = makeNetAdapter(G.g.playerID, this.player);
    this.enemyAdapter = makeNetAdapter(G.g.enemyID, this.enemy);
    if (mp.offline) return;
    mp.phase = 'waitReady';
    modal('wait', 'Get ready', `Waiting for ${mp.opponent?.name ?? 'your opponent'}…`, []);
    send({ t: 'ready' });
  };
  const origUnload = GS.unload;
  GS.unload = function () { G.g.main.keyMgr.removeListener(mpListener); origUnload.call(this); };

  const origBranch = game.Class_Main.prototype.branch;
  game.Class_Main.prototype.branch = function () {
    if (mp.phase === 'lockstep' && G.g.goFrame && (G.g.goFrame === D.label('SCREEN_SELECTFIGHTER') || G.g.goFrame === D.label('Win'))) {
      G.g.goFrame = 0;
      onMatchEnd();
      return;
    }
    origBranch.call(this);
  };

  D.runLoop = mpLoop;
}

function makeNetAdapter(id, target) {
  const a = new G.g.classes[KEYADAPTER[id]](target);
  a.updateKeys = () => {};             // never poll the local keyboard: state bits come only from key events
  a.prevTimestamp = 0;                 // no wall clock in the simulation
  return a;
}

// The only KeyManager listener during a match: Esc leaves, fight keys are queued for lockstep.
const mpListener = {
  keyDown(ev) {
    const code = ev.keyCode;
    if (code === KEY_ESC) { askLeave(); return; }
    if (mp.phase === 'lockstep' && KEYS.has(code)) mp.pending.push([code, 1, ev.timestamp]);
  },
  keyUp(ev) {
    if (mp.phase === 'lockstep' && KEYS.has(ev.keyCode)) mp.pending.push([ev.keyCode, 0, ev.timestamp]);
  },
};

// ---------------------------------------------------------------- lockstep

function startLockstep() {
  hideModal('wait');
  mp.simFrame = 0; mp.local = new Map(); mp.remote = new Map(); mp.pending = []; mp.sums = [];
  for (let f = 0; f < mp.delay; f++) { mp.local.set(f, []); mp.remote.set(f, []); }
  mp.phase = 'lockstep';
  setStatus('fight!');
  D.resume();
}

function applyInputs(f) {
  const gs = G.g.game;
  if (!gs || !gs.loaded) return;
  const mine = mp.local.get(f) || [], theirs = mp.remote.get(f) || [];
  const titanEvents = mp.side === 'titan' ? mine : theirs;
  const villainEvents = mp.side === 'titan' ? theirs : mine;
  feed(gs.playerAdapter, titanEvents);     // player == titan on both machines
  feed(gs.enemyAdapter, villainEvents);
}
function feed(adapter, events) {
  for (const [code, down, ts] of events) {
    const ev = PL([['keyCode', code], ['timestamp', ts]]);
    if (down) adapter.keyDown(ev); else adapter.keyUp(ev);
  }
}

function flushLocal() {
  const f = mp.simFrame + mp.delay;
  const e = mp.pending; mp.pending = [];
  mp.local.set(f, e);
  send({ t: 'in', f, e });
  if (mp.local.size > 600) for (const k of mp.local.keys()) { if (k < f - 400) mp.local.delete(k); else break; }
  if (mp.remote.size > 600) for (const k of mp.remote.keys()) { if (k < f - 400) mp.remote.delete(k); else break; }
}

// One tick of the lockstep loop; returns false when we must wait for the opponent.
function stepLockstep() {
  const f = mp.simFrame;
  if (!mp.remote.has(f)) {
    if (!mp.stalledSince) mp.stalledSince = performance.now();
    else if (performance.now() - mp.stalledSince > STALL_OVERLAY_MS) setStatus(`waiting for ${mp.opponent.name}…`);
    return false;
  }
  if (mp.stalledSince) { mp.stalledSince = 0; setStatus(''); }
  applyInputs(f);
  D.tick();
  if (mp.phase !== 'lockstep') return false;   // the match ended inside this tick
  flushLocal();
  if (f % SUM_EVERY === 0 && f > 0) { const h = checksum(); mp.sums.push([f, h]); send({ t: 'sum', f, h }); }
  mp.simFrame = f + 1;
  return true;
}

// Replaces D.runLoop: same shape as the original timer loop, but gated by the phase.
function mpLoop() {
  D.lastTick = performance.now();
  const loop = () => {
    if (!D.playing) return;
    const now = performance.now();
    let n = 0;
    while (now - D.lastTick >= D.tickInterval && n < 2) {
      D.lastTick += D.tickInterval;
      if (now - D.lastTick > 200) D.lastTick = now;
      try {
        if (mp.phase === 'lockstep') { if (!stepLockstep()) { D.lastTick = now; break; } }
        else if (mp.phase === 'free') D.tick();
        else { D.lastTick = now; break; }          // waitReady / ended / connecting: hold the frame
      } catch (e) { console.error('tick failed at frame', D.frame, e); D.errors.push(String(e && e.stack || e)); }
      n++;
    }
    setTimeout(loop, 4);
  };
  setTimeout(loop, 4);
}

// FNV-1a over the state that matters. Cosmetic effects and RNG-only things are left out.
export function checksum() {
  const gs = G.g.game;
  if (!gs || !gs.loaded) return 0;
  const parts = [mp.simFrame, gs.gameStage, gs.roundNum, gs.playerWins, gs.enemyWins, gs.clock.frames, gs.projectileGroup.getList().count];
  for (const fgt of [gs.player, gs.enemy]) {
    parts.push(fgt.pos.locH, fgt.pos.locV, fgt.vel.locH, fgt.vel.locV, fgt.dir, fgt.health, fgt.currMove, fgt.state,
      fgt.moveRef ? fgt.moveRef.age : -1);
  }
  let h = 0x811c9dc5;
  const s = parts.map(v => (typeof v === 'number' ? (Number.isInteger(v) ? v : v.toFixed(4)) : String(v))).join(',');
  for (let i = 0; i < s.length; i++) { h ^= s.charCodeAt(i); h = Math.imul(h, 0x01000193) >>> 0; }
  return h >>> 0;
}
mp.checksum = checksum;

function highestFrame(map) { let top = -1; for (const f of map.keys()) if (f > top) top = f; return top; }

// ---------------------------------------------------------------- match end / rematch / leave

function onMatchEnd() {
  const gs = G.g.game;
  mp.phase = 'ended';
  const titanWins = gs.playerWins, villainWins = gs.enemyWins;
  const winner = titanWins > villainWins ? 'titan' : villainWins > titanWins ? 'villain' : null;
  send({ t: 'end', winner, titanWins, villainWins });
  setStatus('match over');
}

function onResult(r) {
  mp.phase = 'ended';
  hideModal('wait'); hideModal('away');
  const won = r.winner && r.winner === mp.side;
  const title = r.reason === 'desync' ? 'Out of sync' : r.reason === 'forfeit' ? (won ? 'Win by forfeit' : 'Forfeit') : won ? 'You win!' : r.winner ? 'You lose' : 'Draw';
  const body = r.reason === 'desync'
    ? `The two games drifted apart at frame ${r.frame ?? '?'}, so this one doesn't count. (Both browsers should be the same engine for best results.)`
    : `${r.titanWins} – ${r.villainWins} · ${NAMES[mp.match.titan]} vs ${NAMES[mp.match.villain]}`;
  const buttons = [];
  if (r.reason === 'ko') buttons.push(['Rematch', () => { send({ t: 'rematch', yes: true }); setStatus(`asked ${mp.opponent.name} for a rematch…`); const b = mp.ui.modals.result?.querySelector('[data-rematch]'); if (b) b.disabled = true; }, 'rematch']);
  buttons.push(['Back to lobby', () => { if (r.reason === 'ko') send({ t: 'rematch', yes: false }); leaveToLobby(); }]);
  modal('result', title, body, buttons);
}

function restartForRematch() {
  hideModal('result'); hideModal('away');
  mp.local = new Map(); mp.remote = new Map(); mp.pending = []; mp.simFrame = 0;
  applyMatchGlobals();                          // SCORE mutates villainID/enemyID; put the picks back
  mp.phase = 'free';
  mp.ui.me.textContent = `you · ${mp.side === 'titan' ? 'Titans' : 'villains'} · ${NAMES[mp.match[mp.side]]}`;
  setStatus('rematch!');
  G.g.goFrame = D.label('SCREEN_VERSUS');
  D.resume();
}

function askLeave() {
  if (mp.phase === 'ended' || mp.phase === 'dead' || mp.offline) return;
  modal('leave', 'Leave the match?', mp.phase === 'lockstep' ? 'Leaving now counts as a forfeit.' : 'Your opponent goes back to the lobby too.',
    [['Keep fighting', () => hideModal('leave')], ['Leave', leaveToLobby]]);
}

function leaveToLobby() {
  mp.leaving = true;
  send({ t: 'leave' });
  mp.phase = 'dead';
  setTimeout(() => { location.href = mp.lobbyUrl.href; }, 50);
}

function fatal(title, body) {
  mp.phase = 'dead';
  D.pause();
  modal('fatal', title, body, [['Back to lobby', () => { location.href = mp.lobbyUrl.href; }]]);
}

// ---------------------------------------------------------------- overlay UI

function buildOverlay() {
  const css = document.createElement('style');
  css.textContent = `
    #mp { position: fixed; inset: 0; pointer-events: none; font: 14px/1.4 system-ui, sans-serif; color: #eee; }
    #mp .bar { position: fixed; top: 8px; left: 50%; transform: translateX(-50%); display: flex; gap: 18px; align-items: center;
               background: rgba(0,0,0,.55); border: 1px solid #444; border-radius: 999px; padding: 4px 14px; white-space: nowrap; }
    #mp .bar .me { color: #9f9; } #mp .bar .opp { color: #f99; } #mp .bar .st { color: #ffd; min-width: 8em; text-align: center; } #mp .bar .rtt { color: #888; font-size: 12px; }
    #mp .modal { position: fixed; inset: 0; display: grid; place-items: center; background: rgba(0,0,0,.55); pointer-events: auto; }
    #mp .modal .box { background: #1b1b22; border: 2px solid #ff8fcf; border-radius: 14px; padding: 18px 24px; min-width: 300px; max-width: 460px; text-align: center; box-shadow: 0 10px 40px rgba(0,0,0,.6); }
    #mp .modal h2 { margin: 0 0 8px; color: #fbf57a; font-size: 22px; }
    #mp .modal p { margin: 0 0 14px; color: #ddd; }
    #mp .modal button { font: inherit; font-weight: 700; margin: 4px; padding: 8px 18px; border-radius: 10px; border: 0; background: #fbf57a; color: #2b2450; cursor: pointer; }
    #mp .modal button.alt { background: #ff8fcf; }
    #mp .modal button:disabled { opacity: .45; cursor: default; }
    #mp .modal .spin { display: inline-block; width: 1em; height: 1em; border: 3px solid #ff8fcf; border-right-color: transparent; border-radius: 50%; animation: mpspin .8s linear infinite; vertical-align: -.15em; margin-right: .4em; }
    @keyframes mpspin { to { transform: rotate(360deg); } }
  `;
  document.head.appendChild(css);
  const root = document.createElement('div'); root.id = 'mp';
  root.innerHTML = `<div class="bar"><span class="me">you</span><span class="st"></span><span class="opp">…</span><span class="rtt"></span></div>`;
  document.body.appendChild(root);
  mp.ui = { root, me: root.querySelector('.me'), opp: root.querySelector('.opp'), status: root.querySelector('.st'), rtt: root.querySelector('.rtt'), modals: {} };
  document.addEventListener('visibilitychange', () => { if (mp.phase === 'lockstep' || mp.phase === 'waitReady') send({ t: 'away', hidden: document.hidden }); });
  setInterval(() => { if (mp.ws && mp.ws.readyState === 1) send({ t: 'ping', ts: performance.now() }); }, 5000);
}
function setStatus(s) { if (mp.ui) mp.ui.status.textContent = s; }
function updateRtt() { if (mp.ui && mp.rtt != null) mp.ui.rtt.textContent = `${Math.round(mp.rtt)} ms · delay ${mp.delay}f`; }
function modal(key, title, body, buttons) {
  hideModal(key);
  const el = document.createElement('div'); el.className = 'modal'; el.dataset.key = key;
  const spin = buttons.length ? '' : '<span class="spin"></span>';
  el.innerHTML = `<div class="box"><h2>${spin}${esc(title)}</h2><p>${esc(body)}</p><div class="btns"></div></div>`;
  const btns = el.querySelector('.btns');
  buttons.forEach(([label, fn, tag], i) => {
    const b = document.createElement('button'); b.textContent = label; if (i > 0) b.className = 'alt'; if (tag) b.dataset[tag] = '1';
    b.addEventListener('click', fn); btns.appendChild(b);
  });
  mp.ui.root.appendChild(el);
  mp.ui.modals[key] = el;
}
function hideModal(key) { const el = mp.ui?.modals[key]; if (el) { el.remove(); delete mp.ui.modals[key]; } }
const esc = s => String(s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// ---------------------------------------------------------------- determinism self test

// Run the same scripted fight twice from the same seed and compare checksums. Console:
//   await mpSelfTest()          (page opened with ?match=selftest)
export async function selfTest({ titan = 1, villain = 6, frames = 900, seed = 7 } = {}) {
  const script = [];
  // a fixed dance of key presses for both fighters
  for (let f = 3; f < frames; f += 7) {
    script.push([f, 'titan', [[f % 14 < 7 ? 124 : 123, 1, f * 33]]]); script.push([f + 3, 'titan', [[f % 14 < 7 ? 124 : 123, 0, f * 33 + 99], [6, 1, f * 33 + 100]]]);
    script.push([f + 4, 'titan', [[6, 0, f * 33 + 150]]]);
    script.push([f + 1, 'villain', [[f % 10 < 5 ? 123 : 7, 1, f * 33 + 10]]]); script.push([f + 5, 'villain', [[f % 10 < 5 ? 123 : 7, 0, f * 33 + 140]]]);
  }
  const run = async () => {
    const g = G.g;
    g.difficulty = 1; g.playMode = g.PLAYMODE_AS_TITANS; g.titanID = titan; g.villainID = villain; g.playerID = titan; g.enemyID = villain;
    setRandomSource(mulberry32(seed));
    mp.phase = 'free';
    g.goFrame = D.label('SCREEN_VERSUS');
    D.pause();
    const t0 = performance.now();
    while (!(g.game && g.game.loaded) && performance.now() - t0 < 60000) { D.tick(); await new Promise(r => setTimeout(r, 0)); }
    const sums = [];
    mp.side = 'titan'; mp.local = new Map(); mp.remote = new Map();
    for (const [f, side, e] of script) { const map = side === 'titan' ? mp.local : mp.remote; map.set(f, (map.get(f) || []).concat(e)); }
    for (let f = 0; f < frames; f++) {
      mp.simFrame = f; applyInputs(f); D.tick();
      if (f % 30 === 0) sums.push(checksum());
      if (f % 60 === 0) await new Promise(r => setTimeout(r, 0));
    }
    G.g.goFrame = D.label('SCREEN_SELECTFIGHTER'); D.tick(); D.tick();
    return sums;
  };
  const a = await run(), b = await run();
  const same = a.length === b.length && a.every((v, i) => v === b[i]);
  console.log(same ? 'selfTest OK' : 'selfTest MISMATCH', a, b);
  return { same, a, b };
}
window.mpSelfTest = selfTest;

// mulberry32: tiny seeded PRNG, identical output in every JS engine.
function mulberry32(seed) {
  let a = seed >>> 0;
  return function () {
    a = (a + 0x6D2B79F5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
