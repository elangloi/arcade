// Online 2-player Battle Blitz: deterministic lockstep over the lobby's WebSocket.
//
// Both browsers run the full game (titan = `player`, villain = `enemy`, playMode "as titans" on
// BOTH machines so the simulation is identical); only key events cross the wire, each stamped with
// the frame it must be applied on (current frame + input delay). The local keyboard drives whichever
// fighter this session locked in; the opponent's adapter is fed from their packets.
import { G, PL, setRandomSource, point, rect, _add, _sub, _mul, _fdiv } from './runtime/lingo.js';
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
  phase: 'connecting',     // connecting | select | free | waitReady | lockstep | ended | dead
  matchState: null, sel: { mySide: null, myPick: null, myLocked: false, oppPick: null, oppLocked: false },
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
  // Back to the lobby: inside the arcade shell that's a message to the parent frame (see the
  // front end's lib/bridge.ts); standalone it's the shell's lobby route.
  mp.lobbyUrl = new URL('/multiplayer/battleblitz', location.href);
  if (mute) mp.lobbyUrl.searchParams.set('mute', '1');
  mp.inShell = window.parent !== window;
  if (mp.inShell) window.parent.postMessage({ type: 'arcade:ready', game: 'battleblitz-2p' }, location.origin);
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
  if (mp.matchState === 'picking') startSelect(); else startFight();
}

// ---------------------------------------------------------------- fighter select (the original screen, online)

const SIDE_OF = id => (id <= 5 ? 'titan' : 'villain');
const STAGE_LABEL = { 1: 'SCREEN_SELECTFIGHTER_ROBIN', 2: 'SCREEN_SELECTFIGHTER_RAVEN', 3: 'SCREEN_SELECTFIGHTER_CYBORG', 4: 'SCREEN_SELECTFIGHTER_STARFIRE',
  5: 'SCREEN_SELECTFIGHTER_BEASTBOY', 6: 'SCREEN_SELECTFIGHTER_JINX', 7: 'SCREEN_SELECTFIGHTER_GIZMO', 8: 'SCREEN_SELECTFIGHTER_MAMMOTH',
  9: 'SCREEN_SELECTFIGHTER_CINDERBLOCK', 10: 'SCREEN_SELECTFIGHTER_PLASMUS' };
const SIDE_LABEL = { titan: 'the Titans', villain: 'the villains' };

// Show the game's own SCREEN_SELECTFIGHTER with every fighter unlocked. Clicking a portrait locks it in
// (and, for the first click of the match, claims that side). The opponent's pick is mirrored live.
function startSelect() {
  const g = G.g;
  for (let i = 1; i <= g.FIGHTER_COUNT; i++) {
    g.unlockedPlayers.setAt(i, 1); g.availablePlayers.setAt(i, 1); g.availableEnemies.setAt(i, 1);
    for (let p = 1; p <= g.FIGHTER_COUNT; p++) g.unlockedEnemies.getAt(p).setAt(i, 1);
  }
  g.playMode = g.PLAYMODE_AS_TITANS;
  g.playerID = g.titanID = 1; g.enemyID = g.villainID = 6;
  mp.phase = 'select';
  g.goFrame = D.label('SCREEN_SELECTFIGHTER');
  selectHelp();
}

// Where the picks stand -> the screen's globals + the help line under the frame.
function syncSelect() {
  const g = G.g, sel = mp.sel;
  const scr = g.main && g.main.screen;
  if (!scr || !(scr instanceof game.Class_SelectFighterScreen)) return;
  const mode = sel.mySide === 'villain' ? g.PLAYMODE_AS_VILLAINS : g.PLAYMODE_AS_TITANS;
  if (g.playMode !== mode) scr.setPlayMode(mode);     // the original's "PLAY AS VILLAINS" swap
  g.titanID = (sel.mySide === 'titan' ? sel.myPick : sel.oppPick) ?? 1;      // Robin / Jinx until someone picks
  g.villainID = (sel.mySide === 'villain' ? sel.myPick : sel.oppPick) ?? 6;
  g.playerID = mode === g.PLAYMODE_AS_TITANS ? g.titanID : g.villainID;
  g.enemyID = mode === g.PLAYMODE_AS_TITANS ? g.villainID : g.titanID;
  scr.jumpToCharacerStage();          // big figure on the left = playerID (via the frame label)
  scr.setOpponent(g.enemyID);         // right figure, head, name/moves bar, tags
  selectHelp();
}

function selectHelp() {
  const sel = mp.sel, opp = mp.opponent?.name ?? 'your opponent';
  let help, status;
  if (sel.myLocked && sel.oppLocked) { help = 'Both fighters locked'; status = 'get ready…'; }
  else if (sel.myLocked) { help = `You're ${NAMES[sel.myPick]} for ${SIDE_LABEL[sel.mySide]}`; status = `waiting for ${opp} to pick…`; }
  else if (sel.mySide) { help = `${opp} took ${SIDE_LABEL[sel.mySide === 'titan' ? 'villain' : 'titan']} — click one of ${SIDE_LABEL[sel.mySide]} to lock in`; status = 'pick your fighter'; }
  else { help = 'Click a fighter to lock in — the first click picks your side, the other player gets the opposite one'; status = 'pick your fighter'; }
  setHelp(help); setStatus(status);
}

function canPick(id) {
  return mp.phase === 'select' && !mp.sel.myLocked && (!mp.sel.mySide || SIDE_OF(id) === mp.sel.mySide);
}

function pickFighter(id) {
  const g = G.g;
  if (!canPick(id)) { g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MISCLICK, 60, g.SFX_EVENT_PRIORITY_LOW); return; }
  g.main.audioMgr.playSound(g.assets.AUDIO.SFX_INTERFACE_MOUSEDOWNCHARACTERSWITCH, 100, g.SFX_EVENT_PRIORITY_LOW);
  mp.sel.myLocked = true; mp.sel.myPick = id;   // optimistic; the server's `locked` confirms
  if (!mp.sel.mySide) mp.sel.mySide = SIDE_OF(id);
  send({ t: 'lock', fighter: id });
  syncSelect();
}

// Both locked -> the server said `fight`: canonical globals and off to the versus screen.
function startFight() {
  hideModal('result'); hideModal('away');
  mp.local = new Map(); mp.remote = new Map(); mp.pending = []; mp.simFrame = 0;
  applyMatchGlobals();
  mp.phase = 'free';
  updateBar();
  setHelp('Arrows: move / jump · Down: block · Z: punch · X: kick · Esc: leave the match');
  setStatus('loading the fight…');
  G.g.goFrame = D.label('SCREEN_VERSUS');
  D.resume();
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
  mp.side = v.side; mp.opponent = v.opponent; mp.delay = v.delay; mp.seed = v.seed; mp.matchState = v.state;
  mp.sel = { mySide: v.side, myPick: v.pick, myLocked: !!v.locked, oppPick: v.opponent.pick, oppLocked: !!v.opponent.locked };
  updateBar();
  if (first) {
    if (v.state !== 'picking' && v.state !== 'loading' && v.state !== 'playing') { fatal('Match is over', `This match already ended (${v.state}).`); return; }
    if (v.state === 'playing') { fatal('Match in progress', 'This fight is already running (was the page reloaded?). It counts as a forfeit — back to the lobby.'); send({ t: 'leave' }); return; }
    return;
  }
  // reconnected mid-fight: catch up on the opponent's packets, resend ours
  hideModal('reconnect');
  if (mp.phase === 'lockstep') send({ t: 'resume', have: highestFrame(mp.remote) });
  else if (mp.phase === 'waitReady') send({ t: 'ready' });
  else if (mp.phase === 'select') { if (v.state === 'loading') { mp.match = { ...mp.match }; startFight(); } else syncSelect(); }
}

function updateBar() {
  if (!mp.ui) return;
  const sideName = s => (s === 'titan' ? 'Titans' : s === 'villain' ? 'villains' : 'no side yet');
  const myF = mp.side && mp.match?.[mp.side];
  mp.ui.opp.textContent = `${mp.opponent?.name ?? '?'} · ${sideName(mp.opponent?.side)}`;
  mp.ui.me.textContent = `you · ${sideName(mp.side)}${myF ? ' · ' + NAMES[myF] : ''}`;
  postHud();
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
    case 'sides':
      mp.sel.mySide = m.titan === mp.session ? 'titan' : 'villain';
      mp.side = mp.sel.mySide;
      if (mp.opponent) mp.opponent.side = mp.side === 'titan' ? 'villain' : 'titan';
      updateBar(); syncSelect();
      break;
    case 'picked':
      if (m.session === mp.session) mp.sel.myPick = m.fighter; else mp.sel.oppPick = m.fighter;
      syncSelect();
      break;
    case 'locked':
      if (m.session === mp.session) { mp.sel.myLocked = true; mp.sel.myPick = m.fighter; }
      else { mp.sel.oppLocked = true; mp.sel.oppPick = m.fighter; }
      syncSelect();
      break;
    case 'fight':                 // both locked (first fight or a rematch)
      mp.matchId = m.matchId;
      mp.match = { titan: m.titan, villain: m.villain, seed: m.seed, delay: m.delay, difficulty: m.difficulty };
      mp.side = m.side; mp.delay = m.delay; mp.seed = m.seed; mp.matchState = 'loading';
      if (mp.opponent) mp.opponent.side = mp.side === 'titan' ? 'villain' : 'titan';
      startFight();
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

  // The fighter select screen, online: Esc works there too, portraits lock in on click, and the
  // single-player buttons (CONTROLS / FIGHT / PLAY AS VILLAINS) are hidden.
  const SS = game.Class_SelectFighterScreen.prototype;
  const origSelLoad = SS.load, origSelUnload = SS.unload, origSelUpdate = SS.update;
  SS.load = function () { origSelLoad.call(this); G.g.main.keyMgr.addListener(mpListener); };
  SS.unload = function () { G.g.main.keyMgr.removeListener(mpListener); D.sprite(41).visible = 1; origSelUnload.call(this); };
  SS.update = function () {
    origSelUpdate.call(this);
    if (mp.phase !== 'select') return;
    // The tag/portrait sprites only exist from the stage's label frame on; the original refreshes
    // them once at stage init, which can land before they begin. Refresh on the label frame too.
    if (this.screenStage >= 2 && D.frame === D.label(STAGE_LABEL[G.g.playerID])) this.updateSprites();
    D.sprite(41).visible = 0;   // the CONTROLS / FIGHT / PLAY AS VILLAINS button plate
  };
  for (const B of [game.Behavior_SelectScreenPlayerButton, game.Behavior_SelectScreenEnemyButton]) {
    B.prototype.mouseEnter = function () {
      if (!canPick(this.fighterID)) return;
      D.sprite(this.fighterID + 50).visible = 1;
      D.setCursor(280);
      G.g.main.audioMgr.playSound(G.g.assets.AUDIO.SFX_INTERFACE_MOUSEOVERCHARACTERS, 75, G.g.SFX_EVENT_PRIORITY_LOW);
    };
    B.prototype.mouseDown = function () {
      D.sprite(this.fighterID + 50).visible = 0;
      D.setCursor(-1);
      pickFighter(this.fighterID);
    };
  }
  for (const B of [game.Behavior_SelectScreenFightButton, game.Behavior_SelectScreenControlButton,
    game.Behavior_SelectScreenVillainsButton, game.Behavior_SelectScreenHeroesButton]) {
    B.prototype.beginSprite = function () { D.sprite(this.spriteNum).visible = 0; };
    B.prototype.endSprite = function () { D.sprite(this.spriteNum).visible = 1; };
    B.prototype.mouseEnter = B.prototype.mouseLeave = B.prototype.mouseUp = B.prototype.mouseDown = function () {};
  }

  // The camera. Both machines simulate the titan as `player`, and the view rectangle feeds the
  // simulation (projectiles die past its edges, summons aim at it), so that stays canonical.
  // What's drawn, though, follows whoever this player is: the same weighting with the roles
  // swapped for the villain side, used only by scenePosToStagePos (paint code).
  const SC = game.Class_Scene.prototype;
  const origSceneUpdate = SC.update;
  SC.update = function () {
    origSceneUpdate.call(this);
    if (mp.side !== 'villain') { this.drawUpperLeft = this.viewUpperLeft; return; }
    const mePos = _sub(this.game.enemy.getPos(), point(0, 100));
    const otherPos = _sub(this.game.player.getPos(), point(0, 100));
    let weight = 1.0 - (Math.abs(mePos.locH - otherPos.locH) - 300) / 600.0;
    weight = Math.max(0.0, Math.min(1.0, weight));
    const c = _fdiv(_add(mePos, _mul(otherPos, weight)), 1.0 + weight);
    c.locH = Math.max(this.viewCenterMinX, Math.min(this.viewCenterMaxX, c.locH));
    c.locV = Math.max(this.viewCenterMinY, Math.min(this.viewCenterMaxY, c.locV));
    const r = _add(this.viewOriginRect, rect(c, c));
    this.drawUpperLeft = point(r.left, r.top);
  };
  SC.scenePosToStagePos = function (p) { return _sub(p, this.drawUpperLeft || this.viewUpperLeft); };

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
        else if (mp.phase === 'free' || mp.phase === 'select') D.tick();
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
  // the arcade shell pays out tickets for the match (frontend/src/lib/tickets.ts)
  if (mp.inShell && mp.paidMatch !== mp.matchId) {
    mp.paidMatch = mp.matchId;
    window.parent.postMessage({ type: 'arcade:round', game: 'battleblitz-2p', won: !!won, reason: r.reason, draw: !r.winner }, location.origin);
  }
  const title = r.reason === 'desync' ? 'Out of sync' : r.reason === 'forfeit' ? (won ? 'Win by forfeit' : 'Forfeit') : won ? 'You win!' : r.winner ? 'You lose' : 'Draw';
  const body = r.reason === 'desync'
    ? `The two games drifted apart at frame ${r.frame ?? '?'}, so this one doesn't count. (Both browsers should be the same engine for best results.)`
    : `${r.titanWins} – ${r.villainWins} · ${NAMES[mp.match.titan]} vs ${NAMES[mp.match.villain]}`;
  const buttons = [];
  if (r.reason === 'ko') buttons.push(['Rematch', () => { send({ t: 'rematch', yes: true }); setStatus(`asked ${mp.opponent.name} for a rematch…`); const b = mp.ui.modals.result?.querySelector('[data-rematch]'); if (b) b.disabled = true; }, 'rematch']);
  buttons.push(['Back to lobby', () => { if (r.reason === 'ko') send({ t: 'rematch', yes: false }); leaveToLobby(); }]);
  modal('result', title, body, buttons);
}

function askLeave() {
  if (mp.phase === 'ended' || mp.phase === 'dead' || mp.offline) return;
  modal('leave', 'Leave the match?', mp.phase === 'lockstep' ? 'Leaving now counts as a forfeit.' : mp.phase === 'select' ? `${mp.opponent?.name ?? 'Your opponent'} goes back to the lobby too.` : 'Your opponent goes back to the lobby too.',
    [['Keep fighting', () => hideModal('leave')], ['Leave', leaveToLobby]]);
}

function leaveToLobby() {
  mp.leaving = true;
  send({ t: 'leave' });
  mp.phase = 'dead';
  setTimeout(goLobby, 50);
}
function goLobby() {
  if (mp.inShell) window.parent.postMessage({ type: 'arcade:navigate', to: 'lobby' }, location.origin);
  else location.href = mp.lobbyUrl.href;
}

function fatal(title, body) {
  mp.phase = 'dead';
  D.pause();
  modal('fatal', title, body, [['Back to lobby', goLobby]]);
}

// ---------------------------------------------------------------- overlay UI

function buildOverlay() {
  const css = document.createElement('style');
  css.textContent = `
    #mp { position: fixed; inset: 0; pointer-events: none; font: 15px/1.4 "Fredoka", ui-rounded, "SF Pro Rounded", system-ui, sans-serif; color: #fff6e8;
          --pink: #ff8fcf; --pink-dark: #e86fb3; --yellow: #fbf57a; --yellow-dark: #e5c94d; --navy-deep: #151747; --blue: #5566ff; --ink: #2b2450; --red: #ff5a72; --red-dark: #d93b57; --green: #7ed957; --green-dark: #52b32f; }
    #mp .bar { position: fixed; top: 10px; left: 50%; transform: translateX(-50%); display: flex; gap: 14px; align-items: center;
               background: var(--pink); color: var(--ink); border-radius: 999px; padding: 5px 16px; white-space: nowrap; font-weight: 700; font-size: .85rem; letter-spacing: .04em;
               box-shadow: 0 4px 0 var(--pink-dark), 0 8px 16px rgba(0,0,0,.4); }
    #mp .bar .me::before, #mp .bar .opp::before { content: ""; display: inline-block; width: .6em; height: .6em; border-radius: 50%; margin-right: .4em; vertical-align: .05em; }
    #mp .bar .me::before { background: var(--green); } #mp .bar .opp::before { background: var(--red); }
    #mp .bar .st { background: var(--yellow); border-radius: 999px; padding: 1px 12px; min-width: 7em; text-align: center; text-transform: uppercase; font-size: .75rem; letter-spacing: .08em; box-shadow: inset 0 -2px 0 var(--yellow-dark); }
    #mp .bar .st:empty { display: none; }
    #mp .bar .rtt { font-size: .7rem; opacity: .7; }
    #mp .modal { position: fixed; inset: 0; display: grid; place-items: center; background: rgba(21,23,71,.55); pointer-events: auto; }
    #mp .modal .box { background: var(--pink); border-radius: 26px 26px 20px 20px; padding: 14px 14px 18px; min-width: 320px; max-width: 480px; text-align: center;
                      box-shadow: 0 8px 0 var(--pink-dark), 0 24px 40px rgba(0,0,0,.5); animation: mppop .25s cubic-bezier(.34,1.56,.64,1); }
    @keyframes mppop { from { transform: scale(.8); opacity: 0; } }
    #mp .modal h2 { margin: 0; background: var(--yellow); color: var(--ink); border-radius: 14px; padding: 10px 14px 9px; font-size: 1.35rem; letter-spacing: .04em; box-shadow: inset 0 -4px 0 var(--yellow-dark); }
    #mp .modal p { margin: 12px 6px; background: var(--navy-deep); color: #fff6e8; border-radius: 14px; padding: 12px 16px; font-weight: 500; }
    #mp .modal p:empty { display: none; }
    #mp .modal button { font: inherit; font-weight: 800; letter-spacing: .06em; text-transform: uppercase; font-size: .85rem; margin: 4px; padding: 10px 20px; border-radius: 999px; border: 0;
                        background: var(--yellow); color: var(--ink); cursor: pointer; box-shadow: 0 4px 0 var(--yellow-dark), 0 8px 14px rgba(0,0,0,.3); transition: transform .1s; }
    #mp .modal button:hover { transform: translateY(-2px); }
    #mp .modal button:active { transform: translateY(2px); box-shadow: 0 1px 0 var(--yellow-dark); }
    #mp .modal button.alt { background: var(--navy-deep); color: var(--pink); box-shadow: 0 4px 0 #0d0f30, 0 8px 14px rgba(0,0,0,.3); }
    #mp .modal button:disabled { opacity: .5; cursor: default; transform: none; }
    #mp .modal .spin { display: inline-block; width: .9em; height: .9em; border: 3px solid var(--ink); border-right-color: transparent; border-radius: 50%; animation: mpspin .8s linear infinite; vertical-align: -.1em; margin-right: .4em; }
    @keyframes mpspin { to { transform: rotate(360deg); } }
  `;
  document.head.appendChild(css);
  const root = document.createElement('div'); root.id = 'mp';
  root.innerHTML = `<div class="bar"><span class="me">you</span><span class="st"></span><span class="opp">…</span><span class="rtt"></span></div>`;
  document.body.appendChild(root);
  mp.ui = { root, me: root.querySelector('.me'), opp: root.querySelector('.opp'), status: root.querySelector('.st'), rtt: root.querySelector('.rtt'), modals: {} };
  document.addEventListener('visibilitychange', () => { if (mp.phase === 'lockstep' || mp.phase === 'waitReady' || mp.phase === 'select') send({ t: 'away', hidden: document.hidden }); });
  setInterval(() => { if (mp.ws && mp.ws.readyState === 1) send({ t: 'ping', ts: performance.now() }); }, 5000);
}
function setStatus(s) { if (mp.ui) { mp.ui.status.textContent = s; postHud(); } }
function setHelp(s) { const el = document.getElementById('help'); if (el) el.textContent = s; postHud(); }
function updateRtt() { if (mp.ui && mp.rtt != null) { mp.ui.rtt.textContent = `${Math.round(mp.rtt)} ms · delay ${mp.delay}f`; postHud(); } }
// Inside the arcade shell the bar and the help line are drawn by the shell under the frame.
function postHud() {
  if (!mp.inShell || !mp.ui) return;
  window.parent.postMessage({ type: 'arcade:hud', me: mp.ui.me.textContent, opp: mp.ui.opp.textContent, status: mp.ui.status.textContent,
    rtt: mp.ui.rtt.textContent, help: document.getElementById('help')?.textContent ?? '' }, location.origin);
}
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
