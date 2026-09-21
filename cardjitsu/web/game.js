// Card-Jitsu — the Club Penguin dojo card game (2008), ported from card.swf's ActionScript 2
// (see decompiled/code/main.txt: GameEngine, CardPlayer, Card, BattleController, Clock, Layout).
// The original client was driven by the Club Penguin server (deals, picks, judging, belts); that
// side is re-implemented here so you can fight the Sensei on your own. Sprite ids, instance names
// and frame labels are the original ones; the layout constants are copied verbatim.
import { loadPlayer } from '../../flash/web/player.js';
import { CARDS } from './cards.js';

const DEBUG = new URLSearchParams(location.search).has('debug');
const dbg = (...a) => { if (DEBUG) console.log('[cj]', ...a); };
const random = n => Math.floor(Math.random() * n);

// com.clubpenguin.games.card.Layout
const Layout = {
  POS_CENTER: { x: 380, y: 240 },
  POS_CARD_OFFSCREEN: { x: 375, y: 500 },
  POS_DEALTS: [{ x: 50, y: 385 }, { x: 710, y: 385 }],
  POS_PICKS: [{ x: 225, y: 150 }, { x: 425, y: 150 }],
  POS_WINS: [{ s: { x: 150, y: 25 }, w: { x: 100, y: 25 }, f: { x: 50, y: 25 } }, { s: { x: 650, y: 25 }, w: { x: 600, y: 25 }, f: { x: 550, y: 25 } }],
  POS_WINS_OVER: [[{ x: 45, y: 170 }, { x: 95, y: 170 }, { x: 145, y: 170 }], [{ x: 570, y: 170 }, { x: 620, y: 170 }, { x: 670, y: 170 }]],
  DEALT_FRONT_SPACER: 75, DEALT_BACK_SPACER: 35, WIN_SPACER: 15,
  SCALE_CARD_NORMAL: 28, SCALE_CARD_FLIP: 40, SCALE_CARD_BACK: 15,
  DEPTH_WINS: [1000, 1100],
};
// card colour -> tint + glow (Card constructor)
const COLOURS = {
  r: { col: 14826534, glow: { ab: 0, aa: 80, bb: 5, ba: 45, gb: 30, ga: 45, rb: 153, ra: 45 } },
  g: { col: 6404422, glow: { ab: 0, aa: 80, bb: 35, ba: 50, gb: 93, ga: 50, rb: 49, ra: 50 } },
  b: { col: 1132705, glow: { ab: 0, aa: 80, bb: 158, ba: 55, gb: 41, ga: 55, rb: 12, ra: 55 } },
  p: { col: 10721738, glow: { ab: 0, aa: 80, bb: 101, ba: 45, gb: 77, ga: 45, rb: 102, ra: 45 } },
  o: { col: 16225579, glow: { ab: 0, aa: 80, bb: 15, ba: 45, gb: 86, ga: 45, rb: 153, ra: 45 } },
  y: { col: 16509741, glow: { ab: 0, aa: 80, bb: 15, ba: 35, gb: 153, ga: 35, rb: 150, ra: 35 } },
};

// BattleController.BASIC_ANIM / BELT_COLOR
const BASIC_ANIM = { w: { frames: 91, dual: true }, s: { frames: 100, dual: true }, f: { frames: 118, dual: true }, tie: { frames: 45 }, walk: { frames: 106 }, ambient: { frames: undefined } };
const BELT_COLOR = [null, 16777215, 16776960, 16737792, 3394560, 13260, 13369344, 6684927, 6697728, 4473924, 4473924];
const BELT_NAMES = ['no belt', 'white belt', 'yellow belt', 'orange belt', 'green belt', 'blue belt', 'red belt', 'purple belt', 'brown belt', 'black belt', 'ninja'];
// belt progress per game, as the Club Penguin server did it (win / loss), compressed so a cabinet
// session gets somewhere: the original needed well over a hundred games to reach black
const WIN_PCT = [100, 60, 45, 40, 36, 30, 25, 22, 18, 100];
const LOSS_PCT = [100, 30, 25, 22, 20, 17, 15, 13, 10, 0];
const PENGUIN_COLOURS = [0x0000ff, 0x00cc00, 0xff0000, 0xffcc00, 0x8b0000, 0xff8000, 0x00cccc, 0xcc00cc, 0x663300, 0xff66cc, 0x99ccff, 0xa0a0a0];
const CLOCK_SECONDS = 20;

// ---- the local "server": rules from the Club Penguin card game ----------------------------
const beats = (a, b) => (a === 'f' && b === 's') || (a === 's' && b === 'w') || (a === 'w' && b === 'f');
// winner seat, or -1 for a tie: element first, then the number
function judge(c0, c1) {
  if (c0.atr !== c1.atr) return beats(c0.atr, c1.atr) ? 0 : 1;
  if (c0.pt !== c1.pt) return c0.pt > c1.pt ? 0 : 1;
  return -1;
}
// three of one element in three colours, or one of each element in three different colours
function winningSet(wins) {
  const byAtr = { f: {}, w: {}, s: {} };
  for (const c of wins) if (!byAtr[c.atr][c.col]) byAtr[c.atr][c.col] = c;
  for (const atr of ['f', 'w', 's']) { const cs = Object.values(byAtr[atr]); if (cs.length >= 3) return cs.slice(0, 3); }
  for (const a of Object.values(byAtr.f)) for (const b of Object.values(byAtr.w)) for (const c of Object.values(byAtr.s)) {
    if (a.col !== b.col && b.col !== c.col && a.col !== c.col) return [a, b, c];
  }
  return null;
}

export async function boot(svgEl) {
  const P = await loadPlayer(svgEl, '../assets/');
  const main = P.root;
  const locale = (await P.loadMovie('../assets/lang/en/')).json.locale;
  const T = k => (locale[k] !== undefined ? locale[k] : k);

  // frame scripts that are just stop()
  P.onFrame(100, 1, c => c.stop());
  for (const f of [2, 16, 52]) P.onFrame(112, f, c => c.stop());
  P.onFrame(59, 40, c => c.stop());
  P.onFrame(67, 10, c => { if (c.explosed) c.explosed(); });
  P.onFrame(67, 16, c => { if (c.explosed) c.explosed(); });

  // ---- tweens + waits on the player's clock (TweenLite's default ease is Quad.easeOut) --------
  const tweens = new Set();
  const timers = new Set();
  P.onTick = () => {
    for (const t of tweens) {
      const k = Math.min(1, (P.frameCount - t.t0) / t.frames), e = -k * (k - 2);
      for (const [prop, [a, b]] of Object.entries(t.props)) t.mc[prop] = a + (b - a) * e;
      if (k >= 1) { tweens.delete(t); t.done(); }
    }
    for (const w of timers) if (P.frameCount >= w.at) { timers.delete(w); w.done(); }
  };
  const tween = (mc, secs, to) => new Promise(done => {
    const props = {}; for (const [k, v] of Object.entries(to)) props[k] = [mc[k], v];
    tweens.add({ mc, t0: P.frameCount, frames: Math.max(1, Math.round(secs * P.rate)), props, done });
  });
  const wait = ms => new Promise(done => timers.add({ at: P.frameCount + Math.round(ms / 1000 * P.rate), done }));

  // ---- Card (com.clubpenguin.games.card.Card) ---------------------------------------------------
  let cardSerial = 0;
  class Card {
    constructor([type, atr, pt, col, name]) {
      this.id = ++cardSerial; this.type = type; this.atr = atr; this.pt = pt; this.colKey = col; this.name = name;
      this.col = COLOURS[col].col; this.glowT = COLOURS[col].glow;
      this.lock = true; this.loaded = false; this.mc = null; this.state = null;
    }
    createGraphic(parent, seat, show) {
      this.mc = parent.attachMovie('card', `card_${seat}_${this.id}`, parent.getNextHighestDepth());
      this.mc._x = Layout.POS_CARD_OFFSCREEN.x; this.mc._y = Layout.POS_CARD_OFFSCREEN.y;
      if (show) {
        this.setState('front', Layout.SCALE_CARD_NORMAL);
        this.mc.setHandler('onPress', () => this.onPick());
        this.mc.setHandler('onRollOver', () => this.onRollOver());
        this.mc.setHandler('onRollOut', () => this.onRollOut());
      } else {
        this.setState('back', Layout.SCALE_CARD_BACK);
      }
    }
    setState(state, scale) {
      this.state = state;
      this.mc.gotoAndStop(state);
      if (scale !== undefined) { this.mc._xscale = scale; this.mc._yscale = scale; }
      if (state === 'front' || state === 'thumbnail' || state === 'over' || state === 'disabled') {
        this.face = true;
        const m = this.mc;
        if (m.mc_atr) m.mc_atr.gotoAndStop(this.atr);
        if (m.mc_pt && m.mc_pt.tf_pt) m.mc_pt.tf_pt.text = String(this.pt);
        if (m.mc_col) m.mc_col.setRGB(this.col);
        if (m.mc_art) m.mc_art._visible = true;
        this.glow(state === 'over');
        if (!this.loaded) this.loadArt(true);
      } else if (state === 'back') {
        this.face = false; this.lock = true;
      }
    }
    disable() { this.lock = true; this.setState('disabled'); }
    glow(on) { const g = this.mc.mc_glow; if (!g) return; g._visible = on; if (on) g.setTransform(this.glowT); }
    tweenTo(x, y, secs) { return tween(this.mc, secs, { _x: x, _y: y }); }
    // the dealt row: front cards fan out to the right from seat 0's corner, and to the left from seat 1's
    tweenToDealtSlots(seat, slots, pos) {
      for (let i = 0; i < slots.length; i++) {
        if (slots[i] != null) continue;
        const sp = this.state === 'front' ? Layout.DEALT_FRONT_SPACER : Layout.DEALT_BACK_SPACER;
        slots[i] = this;
        return seat === 0 ? this.tweenTo(pos.x + sp * i, pos.y, 0.5) : this.tweenTo(pos.x - sp - sp * i, pos.y, 0.5);
      }
      console.warn('CANNOT FIND AVAILABLE SLOTS...');
      return Promise.resolve();
    }
    onRollOver() { if (this.lock) return; this.mc.swapDepths(this.mc.parent.getNextHighestDepth()); this.setState('over'); }
    onRollOut() { if (this.lock) return; this.setState('front'); }
    onPick() { if (this.lock) return; this.lock = true; if (this.onPicked) this.onPicked(this); }
    // TweenMax.sequence: squash to a line, swap to the face, expand
    async flip(secs) {
      this.loadArt(false);
      const x0 = this.mc._x, w = this.mc._width;
      await tween(this.mc, secs, { _x: x0 + w / 2, _xscale: 0 });
      this.setState('front', Layout.SCALE_CARD_FLIP);
      this.mc._xscale = 0;
      await tween(this.mc, secs, { _x: x0, _xscale: Layout.SCALE_CARD_FLIP });
    }
    async loadArt(show) {
      if (this.loading) return this.loading;
      const art = this.mc.mc_art;
      if (!art) return;
      art._visible = show;
      this.loading = art.loadClip(`../assets/icons/${this.type}/`).then(() => { this.loaded = true; if (this.mc && this.mc.mc_art) this.mc.mc_art._visible = show || this.face; });
      return this.loading;
    }
    // a puff of smoke, then the clip goes
    destroy() {
      if (!this.mc) return;
      const ex = this.mc.attachMovie('explosion', 'mc_explosion', this.mc.getNextHighestDepth());
      if (ex && this.state === 'thumbnail') { ex._xscale = 50; ex._yscale = 50; }
      if (ex) ex.explosed = () => this.terminate(); else this.terminate();
    }
    terminate() { if (this.mc) { this.mc.removeMovieClip(); this.mc = null; } }
    toString() { return `[${this.id}|${this.type}|${this.atr}|${this.pt}|${this.colKey}]`; }
  }

  // ---- CardPlayer -----------------------------------------------------------------------------
  class CardPlayer {
    constructor(seat, nickname, color, rank) {
      this.seat = seat; this.nickname = nickname; this.color = color; this.rank = rank;
      this.wins = []; this.losses = []; this.dealts = []; this.pick = null; this.dealtSlots = new Array(5).fill(null);
    }
    receiveCard(card) { this.dealts.push(card); return card; }
    pickCard(card) {
      const i = this.dealts.indexOf(card);
      this.pick = card; this.dealts.splice(i, 1);
      for (let s = 0; s < this.dealtSlots.length; s++) if (this.dealtSlots[s] === card) this.dealtSlots[s] = null;
      this.lockDealts(true);
      return card;
    }
    cardWin() { if (!this.pick) return; this.wins.push(this.pick); this.pick = null; }
    cardLose() { if (!this.pick) return; this.losses.push(this.pick); this.pick.destroy(); this.pick = null; }
    lockDealts(lock) { for (const c of this.dealts) c.lock = lock; }
    arrangeWinCards() {
      const n = { f: 0, w: 0, s: 0 };
      this.wins.forEach((c, i) => {
        n[c.atr]++;
        c.setState('thumbnail');
        const p = Layout.POS_WINS[this.seat][c.atr];
        c.tweenTo(p.x, p.y + Layout.WIN_SPACER * n[c.atr], 0.5);
        c.mc.swapDepths(Layout.DEPTH_WINS[this.seat] - i);
      });
    }
    showWinCards(cards) { cards.forEach((c, i) => c.tweenTo(Layout.POS_WINS_OVER[this.seat][i].x, Layout.POS_WINS_OVER[this.seat][i].y, 0.5)); }
  }

  // ---- BattleController: the two ninjas, each fight animation its own loaded movie --------------
  const battle = { mc: main.battle_mc, clips: {}, b0: null, b1: null, frame: 0, name: null };
  const BATTLE_FILES = ['walk', 'ambient', 'tie', 'f_attack', 'f_react', 'w_attack', 'w_react', 's_attack', 's_react'];
  await Promise.all(BATTLE_FILES.map(async (name, i) => {
    const c = battle.mc.createEmptyMovieClip(name, i + 1);
    battle.clips[name] = c;
    await c.loadClip(`../assets/battles/${name}/`);
  }));
  const stopAll = (mc) => { if (!mc) return; for (const ch of mc.children.values()) if (ch.stop) ch.stop(); };
  let battleDone = null;
  // animate(winseat, name): returns a promise that resolves when the animation has run its frames
  // (ambient loops until the next call)
  function animate(winseat, name, noTieSfx) {
    if (battle.b0) battle.b0.removeMovieClip();
    if (battle.b1) battle.b1.removeMovieClip();
    if (battleDone) { const d = battleDone; battleDone = null; d(); }
    const c = Layout.POS_CENTER;
    const place = (mc) => { mc._x = c.x; mc._y = c.y; return mc; };
    if (name === 'walk' || name === 'tie' || name === 'ambient') {
      battle.b0 = place(battle.clips[name].attachMovie(name, 'battle0_mc', 1));
      battle.b1 = place(battle.clips[name].attachMovie(name, 'battle1_mc', 2));
      if (name === 'tie' && !noTieSfx) { const s = P.sound('tie_sfx', battle.clips.tie.movie); s.start(); }
    } else {
      const att = battle.clips[name + '_attack'], rea = battle.clips[name + '_react'];
      if (winseat === 0) { battle.b0 = place(att.attachMovie('attack', 'battle0_mc', 1)); battle.b1 = place(rea.attachMovie('react', 'battle1_mc', 2)); }
      else { battle.b0 = place(rea.attachMovie('react', 'battle0_mc', 1)); battle.b1 = place(att.attachMovie('attack', 'battle1_mc', 2)); }
      att.swapDepths(battle.mc.getNextHighestDepth());   // attack_top
    }
    battle.b0._xscale = -100; battle.b1._xscale = 100;
    dress();
    const frames = BASIC_ANIM[name].frames;
    battle.name = name; battle.frame = 1;
    return new Promise(done => {
      if (frames === undefined) { battleDone = null; done(); return; }
      battleDone = done;
      battle.mc.onEnterFrame = function () {
        if (battle.name !== name) { this.onEnterFrame = null; return; }
        if (++battle.frame >= frames) { this.onEnterFrame = null; stopAll(battle.b0); stopAll(battle.b1); const d = battleDone; battleDone = null; if (d) d(); }
      };
    });
  }
  // colours, belts and the Sensei's beard on whichever clips are showing
  function dress() {
    for (const pl of [g.p0, g.p1]) {
      if (!pl) continue;
      const mc = pl.seat === 0 ? battle.b0 : battle.b1;
      if (!mc) continue;
      for (const part of ['body_mc', 'frontArm_mc', 'backArm_mc']) if (mc[part]) mc[part].setRGB(pl.color);
      if (pl.sensei) { if (mc.belt_mc) mc.belt_mc._visible = false; if (mc.beltline_mc) mc.beltline_mc._visible = false; }
      else {
        for (const part of ['sensay_mc', 'sensay2_mc', 'sensay_mc2']) if (mc[part]) mc[part]._visible = false;
        if (pl.rank === 0) { if (mc.belt_mc) mc.belt_mc._visible = false; if (mc.beltline_mc) mc.beltline_mc._visible = false; }
        else if (mc.belt_mc) mc.belt_mc.setRGB(BELT_COLOR[pl.rank]);
      }
    }
  }

  // ---- Clock (20 s to pick) -------------------------------------------------------------------
  const clock = {
    mc: main.mc_clock, n: 0, tick: null,
    start(onTimeUp) {
      this.n = CLOCK_SECONDS; this.mc._visible = true; this.mc.gotoAndStop(1); this.mc.timer_txt.text = String(this.n);
      this.tick = { at: P.frameCount + P.rate, done: () => {} };
      const step = () => {
        this.n--; this.mc.timer_txt.text = String(this.n); this.mc.nextFrame();
        if (this.n > 0) { this.tick = { at: P.frameCount + P.rate, done: step }; timers.add(this.tick); }
        else { this.end(); onTimeUp(); }
      };
      this.tick = { at: P.frameCount + P.rate, done: step }; timers.add(this.tick);
    },
    end() { if (this.tick) timers.delete(this.tick); this.tick = null; this.mc.timer_txt.text = ''; this.mc.gotoAndStop(1); this.mc._visible = false; },
  };
  clock.mc._visible = false;

  // ---- help hover + close button ------------------------------------------------------------
  let helpOn = false;
  main.mc_help.gotoAndStop('zero');
  main.mc_help.setHandler('onRollOver', () => { if (helpOn) return; helpOn = true; main.mc_help.gotoAndPlay('down'); if (main.mc_help.mc_menu && main.mc_help.mc_menu.tf_help) main.mc_help.mc_menu.tf_help.text = T('help'); });
  main.mc_help.setHandler('onRollOut', () => { if (!helpOn) return; helpOn = false; main.mc_help.gotoAndPlay('up'); });
  P.onButton(116, () => quit());
  if (main.loading_mc) main.loading_mc._visible = false;

  // ---- belts: kept in the browser between games -----------------------------------------------
  const progress = { belt: 0, pct: 0 };
  try { Object.assign(progress, JSON.parse(localStorage.getItem('cardjitsu.ninja') || '{}')); } catch (e) { /* fine */ }
  const saveProgress = () => { try { localStorage.setItem('cardjitsu.ninja', JSON.stringify(progress)); } catch (e) { /* fine */ } };

  // ---- the match ------------------------------------------------------------------------------
  const g = { p0: null, p1: null, round: 0, over: false, deck: [], quitting: false, playing: false };
  const msg = t => { main.tf_msg.text = t; };
  const nameFields = () => { main.tf_name0.text = g.p0.nickname.toUpperCase(); main.tf_name1.text = g.p1.nickname.toUpperCase(); };
  const draw = () => { if (!g.deck.length) g.deck = CARDS.slice().sort(() => Math.random() - 0.5); return new Card(g.deck.pop()); };

  // Sensei: sees your card and counters it more often the lower your belt (the real Sensei was
  // unbeatable until black belt); with nothing to counter he plays what's in his hand
  function senseiPick(myCard) {
    const p = Math.max(0.15, 0.9 - 0.08 * progress.belt);
    if (Math.random() < p) {
      const counter = g.p0.dealts.find(c => beats(c.atr, myCard.atr));
      if (counter) return counter;
      const tieUp = g.p0.dealts.filter(c => c.atr === myCard.atr && c.pt > myCard.pt);
      if (tieUp.length) return tieUp[random(tieUp.length)];
    }
    return g.p0.dealts[random(g.p0.dealts.length)];
  }

  async function dealTo(player, n, show) {
    const cards = [];
    for (let i = 0; i < n; i++) {
      const c = player.receiveCard(draw());
      c.createGraphic(main.cards_mc, player.seat, show);
      c.onPicked = card => g.onPick && g.onPick(card);
      cards.push(c);
    }
    if (show) await Promise.all(cards.map(c => c.loadArt(true)));
    // the original tweens them one after another
    for (const c of cards) await c.tweenToDealtSlots(player.seat, player.dealtSlots, Layout.POS_DEALTS[player.seat]);
  }

  async function playMatch(playerName) {
    g.playing = true; g.over = false; g.round = 0; g.quitting = false;
    for (const d of [...main.cards_mc.children.keys()]) main.cards_mc.removeChild(d);
    g.p0 = new CardPlayer(0, T('sensei_label'), 0x333333, 10); g.p0.sensei = true;
    g.p1 = new CardPlayer(1, playerName, PENGUIN_COLOURS[random(PENGUIN_COLOURS.length)], progress.belt);
    nameFields(); msg('');
    // stateServe: the ninjas walk in, then five cards each
    await animate(null, 'walk');
    if (g.quitting) return;
    animate(null, 'ambient');
    await dealTo(g.p0, 5, false);
    await dealTo(g.p1, 5, true);
    let winner = -1, winningCards = [];
    while (!g.quitting) {
      g.round++;
      if (g.round > 1) { await dealTo(g.p0, 1, false); await dealTo(g.p1, 1, true); }
      // stateInput: pick a card (or the clock picks the first one for you)
      g.p1.lockDealts(false);
      const myCard = await new Promise(resolve => {
        g.onPick = card => { g.onPick = null; clock.end(); resolve(card); };
        clock.start(() => { const c = g.p1.dealts.find(x => !x.lock) || g.p1.dealts[0]; if (g.onPick && c) g.onPick(c); });
      });
      if (g.quitting) return;
      g.p1.pickCard(myCard);
      myCard.setState('front', Layout.SCALE_CARD_FLIP);
      myCard.mc.swapDepths(main.cards_mc.getNextHighestDepth());
      const senseiCard = g.p0.pickCard(senseiPick(myCard));
      senseiCard.setState('back', Layout.SCALE_CARD_FLIP);
      senseiCard.mc.swapDepths(main.cards_mc.getNextHighestDepth());
      await Promise.all([
        myCard.tweenTo(Layout.POS_PICKS[1].x, Layout.POS_PICKS[1].y, 0.5),
        senseiCard.tweenTo(Layout.POS_PICKS[0].x, Layout.POS_PICKS[0].y, 0.5),
      ]);
      // stateJudge
      await wait(1000);
      await senseiCard.flip(0.25);
      await wait(500);
      const seat = judge(senseiCard, myCard);
      dbg('round', g.round, 'sensei', senseiCard.toString(), 'you', myCard.toString(), '->', seat);
      if (seat === -1) { g.p0.cardLose(); g.p1.cardLose(); await animate(null, 'tie'); }
      else {
        const w = seat === 0 ? g.p0 : g.p1, l = seat === 0 ? g.p1 : g.p0;
        const winCard = w.pick;
        w.cardWin(); l.cardLose(); w.arrangeWinCards();
        await animate(seat, winCard.atr);
        const set = winningSet(w.wins);
        if (set) { winner = seat; winningCards = set; break; }
      }
      animate(null, 'ambient');
    }
    if (g.quitting) return;
    // stateOver
    const endSfx = P.sound('end_sfx'); endSfx.start();
    const w = winner === 0 ? g.p0 : g.p1;
    w.showWinCards(winningCards);
    await wait(1000);
    animate(null, 'tie', true);
    await wait(2500);
    const won = winner === 1;
    msg(`${w.nickname} ${T('win')}`);
    // belts move on every game, faster for a win
    const before = progress.belt;
    if (progress.belt < 9) {
      progress.pct += won ? WIN_PCT[progress.belt] : LOSS_PCT[progress.belt];
      if (progress.pct >= 100) { progress.pct -= 100; progress.belt++; }
      saveProgress();
    }
    const beltLine = progress.belt > before ? T('help_award_belt_earned').replace('%0', 'a ' + BELT_NAMES[progress.belt]) : '';
    g.playing = false;
    if (onGameOver) onGameOver({ won, belt: progress.belt, pct: progress.pct, beltLine, belts: BELT_NAMES });
  }

  let onGameOver = null;
  function quit() {
    g.quitting = true; clock.end(); g.onPick = null;
    if (onQuit) onQuit();
  }
  let onQuit = null;

  P.start();
  return {
    P, progress, BELT_NAMES,
    play: name => playMatch(name || 'You'),
    quit,
    set onGameOver(fn) { onGameOver = fn; },
    set onQuit(fn) { onQuit = fn; },
    get playing() { return g.playing; },
  };
}
