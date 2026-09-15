// A small Director 8 player: stage/sprites/inks, score playback with sprite spans and
// behaviors, film loops, cast members (bitmaps, sounds, text), sound channels, keyboard,
// mouse, and the handful of "the ..." properties the game reads.
import { G, LList, PropList, PL, Point, Rect, point, rect, _eq, _str } from './lingo.js';

const ASSET_BASE = '../assets/';

// ---------------------------------------------------------------- members

export class LImage {
  constructor(canvas) { this.canvas = canvas; }
  get width() { return this.canvas.width; }
  get height() { return this.canvas.height; }
  duplicate() {
    const c = document.createElement('canvas');
    c.width = this.canvas.width; c.height = this.canvas.height;
    c.getContext('2d').drawImage(this.canvas, 0, 0);
    return new LImage(c);
  }
  copyPixels(src, dstRect, srcRect) {
    const ctx = this.canvas.getContext('2d');
    ctx.clearRect(dstRect.left, dstRect.top, dstRect.width, dstRect.height);
    ctx.drawImage(src.canvas, srcRect.left, srcRect.top, srcRect.width, srcRect.height,
      dstRect.left, dstRect.top, dstRect.width, dstRect.height);
  }
}

export class Member {
  constructor(castLib, number, info) {
    this.isMember = true;
    this.castLib = castLib;
    this.number = number;
    this._name = info ? info.name : '';
    this.type = info ? info.type : 'empty';
    this.file = info && info.file ? ASSET_BASE + info.file : null;
    this.w = info && info.w || 0;
    this.h = info && info.h || 0;
    this.regX = info && info.regX !== undefined ? info.regX : Math.floor(this.w / 2);
    this.regY = info && info.regY !== undefined ? info.regY : Math.floor(this.h / 2);
    this.text = info && info.text || '';
    this.loop = null;          // film loop data
    this._img = null;          // HTMLImageElement or canvas
    this._variants = {};       // ink-keyed canvases
    this._audio = null;        // AudioBuffer
    this.loaded = !this.file;
    this.loading = null;
    if (info && info.filmloop) this.loop = D.filmloops[castLib + ':' + number];
  }
  get name() { return this._name; }
  set name(n) {
    const c = D.casts[this.castLib];
    if (c) { delete c.byName[this._name.toLowerCase()]; c.byName[String(n).toLowerCase()] = this; }
    this._name = String(n);
  }
  preload() { this.load(); }
  unload() { }
  erase() {
    const c = D.casts[this.castLib];
    if (c) { delete c.members[this.number]; delete c.byName[this._name.toLowerCase()]; }
    this._img = null; this._variants = {}; this.number = 0;
  }
  get width() { return this.w; }
  get height() { return this.h; }
  get rect() { return new Rect(0, 0, this.w, this.h); }
  get regPoint() { return new Point(this.regX, this.regY); }
  set regPoint(p) { this.regX = p.locH; this.regY = p.locV; }
  get image() {
    if (!this._img) return new LImage(document.createElement('canvas'));
    if (this._img instanceof HTMLCanvasElement) return new LImage(this._img);
    const c = document.createElement('canvas');
    c.width = this.w; c.height = this.h;
    c.getContext('2d').drawImage(this._img, 0, 0);
    this._img = c;
    return new LImage(c);
  }
  set image(img) {
    this._img = img.canvas;
    this.w = img.canvas.width; this.h = img.canvas.height;
    this._variants = {};
    this.loaded = true;
  }
  load() {
    if (this.loaded || this.loading) return this.loading || Promise.resolve();
    if (this.type === 'sound') {
      this.loading = fetch(this.file).then(r => r.arrayBuffer()).then(b => D.audio.decodeAudioData(b)).then(buf => {
        this._audio = buf; this.loaded = true;
      }).catch(e => { console.warn('sound load failed', this.file, e); this.loaded = true; });
    } else {
      this.loading = new Promise(res => {
        const im = new Image();
        im.onload = () => { this._img = im; this.loaded = true; res(); };
        im.onerror = () => { console.warn('image load failed', this.file); this.loaded = true; res(); };
        im.src = this.file;
      });
    }
    return this.loading;
  }
  drawable(ink) {
    if (!this._img) return null;
    if (ink === 36 || ink === 8) {
      const key = ink === 36 ? 'bg' : 'matte';
      if (!this._variants[key]) this._variants[key] = ink === 36 ? keyWhite(this._img) : matteWhite(this._img);
      return this._variants[key];
    }
    return this._img;
  }
}

function keyWhite(img) {
  const c = document.createElement('canvas');
  c.width = img.width; c.height = img.height;
  const ctx = c.getContext('2d');
  ctx.drawImage(img, 0, 0);
  const id = ctx.getImageData(0, 0, c.width, c.height);
  const d = id.data;
  for (let i = 0; i < d.length; i += 4) if (d[i] === 255 && d[i + 1] === 255 && d[i + 2] === 255) d[i + 3] = 0;
  ctx.putImageData(id, 0, 0);
  return c;
}

function matteWhite(img) {
  // white pixels connected to the border become transparent (Director's matte ink)
  const c = document.createElement('canvas');
  c.width = img.width; c.height = img.height;
  const ctx = c.getContext('2d');
  ctx.drawImage(img, 0, 0);
  const W = c.width, H = c.height;
  const id = ctx.getImageData(0, 0, W, H);
  const d = id.data;
  const white = (i) => d[i * 4] === 255 && d[i * 4 + 1] === 255 && d[i * 4 + 2] === 255;
  const seen = new Uint8Array(W * H);
  const stack = [];
  for (let x = 0; x < W; x++) { stack.push(x); stack.push((H - 1) * W + x); }
  for (let y = 0; y < H; y++) { stack.push(y * W); stack.push(y * W + W - 1); }
  while (stack.length) {
    const i = stack.pop();
    if (seen[i] || !white(i)) continue;
    seen[i] = 1;
    d[i * 4 + 3] = 0;
    const x = i % W, y = (i - x) / W;
    if (x > 0) stack.push(i - 1);
    if (x < W - 1) stack.push(i + 1);
    if (y > 0) stack.push(i - W);
    if (y < H - 1) stack.push(i + W);
  }
  ctx.putImageData(id, 0, 0);
  return c;
}

// ---------------------------------------------------------------- sprites

export class Sprite {
  constructor(num) {
    this.spriteNum = num;
    this._member = null;
    this.loc = new Point(0, 0);
    this.locZ = num;
    this.ink = 0;
    this.blend = 100;
    this.visible = 1;
    this.flipH = 0;
    this.flipV = 0;
    this._width = 0;
    this._height = 0;
    this.rotation = 0;
    this.puppet = 0;
    this.behaviors = [];
    this.loopFrame = 1;
    this.loopStarted = 0;
  }
  get member() { return this._member || D.member0; }
  set member(m) {
    const nm = (m && m.number > 0) ? m : null;
    if (nm !== this._member) { this.loopFrame = 1; this.loopStarted = D.frameCount; }
    this._member = nm;
  }
  get locH() { return this.loc.locH; }
  set locH(v) { this.loc = new Point(v, this.loc.locV); }
  get locV() { return this.loc.locV; }
  set locV(v) { this.loc = new Point(this.loc.locH, v); }
  natural() {
    const m = this._member;
    if (!m) return { w: 0, h: 0, regX: 0, regY: 0 };
    if (m.loop) { const b = D.loopBounds(m); return { w: b.w, h: b.h, regX: b.regX, regY: b.regY }; }
    return { w: m.w, h: m.h, regX: m.regX, regY: m.regY };
  }
  get width() { return this._width || this.natural().w; }
  set width(v) { this._width = v; }
  get height() { return this._height || this.natural().h; }
  set height(v) { this._height = v; }
  get rect() {
    const n = this.natural();
    const w = this._width || n.w, h = this._height || n.h;
    const sx = n.w ? w / n.w : 1, sy = n.h ? h / n.h : 1;
    const l = this.loc.locH - n.regX * sx, t = this.loc.locV - n.regY * sy;
    return new Rect(l, t, l + w, t + h);
  }
  set rect(r) {
    const n = this.natural();
    this._width = r.width; this._height = r.height;
    const sx = n.w ? r.width / n.w : 1, sy = n.h ? r.height / n.h : 1;
    this.loc = new Point(r.left + n.regX * sx, r.top + n.regY * sy);
  }
}

// ---------------------------------------------------------------- sound channels

class SoundChannel {
  constructor(num) { this.num = num; this.src = null; this.gain = null; this._volume = 255; this.member = null; }
  play(mem) {
    this.stop();
    if (!mem || !mem._audio) { if (mem && !mem.loaded) mem.load(); return; }
    const ctx = D.audio;
    const src = ctx.createBufferSource();
    src.buffer = mem._audio;
    src.loop = mem.loop === true || /loop|ambient/i.test(mem.name);
    const gain = ctx.createGain();
    gain.gain.value = this._volume / 255;
    src.connect(gain).connect(ctx.destination);
    src.onended = () => { if (this.src === src) { this.src = null; } };
    src.start();
    this.src = src; this.gain = gain; this.member = mem;
  }
  stop() { if (this.src) { try { this.src.stop(); } catch (e) { } this.src = null; } this.member = null; }
  isBusy() { return this.src ? 1 : 0; }
  get volume() { return this._volume; }
  set volume(v) { this._volume = Math.max(0, Math.min(255, v)); if (this.gain) this.gain.gain.value = this._volume / 255; }
}

// ---------------------------------------------------------------- key codes (Mac virtual keycodes)

const KEYMAP = {
  KeyA: 0, KeyS: 1, KeyD: 2, KeyF: 3, KeyH: 4, KeyG: 5, KeyZ: 6, KeyX: 7, KeyC: 8, KeyV: 9, KeyB: 11, KeyQ: 12,
  KeyW: 13, KeyE: 14, KeyR: 15, KeyY: 16, KeyT: 17, Digit1: 18, Digit2: 19, Digit3: 20, Digit4: 21, Digit6: 22,
  Digit5: 23, Equal: 24, Digit9: 25, Digit7: 26, Minus: 27, Digit8: 28, Digit0: 29, BracketRight: 30, KeyO: 31,
  KeyU: 32, BracketLeft: 33, KeyI: 34, KeyP: 35, Enter: 36, KeyL: 37, KeyJ: 38, Quote: 39, KeyK: 40, Semicolon: 41,
  Backslash: 42, Comma: 43, Slash: 44, KeyN: 45, KeyM: 46, Period: 47, Tab: 48, Space: 49, Escape: 53,
  ArrowLeft: 123, ArrowRight: 124, ArrowDown: 125, ArrowUp: 126,
};

function keyCodeOf(e) {
  if (e.code && KEYMAP[e.code] !== undefined) return KEYMAP[e.code];
  const k = e.key;
  if (!k) return undefined;
  if (k.length === 1) {
    const u = k.toUpperCase();
    if (u >= 'A' && u <= 'Z') return KEYMAP['Key' + u];
    if (u >= '0' && u <= '9') return KEYMAP['Digit' + u];
    return { ' ': 49, '=': 24, '+': 24, '-': 27, ']': 30, '[': 33, "'": 39, ';': 41, '\\': 42, ',': 43, '/': 44, '.': 47 }[u];
  }
  return { Enter: 36, Tab: 48, Escape: 53, ArrowLeft: 123, ArrowRight: 124, ArrowDown: 125, ArrowUp: 126 }[k];
}

// ---------------------------------------------------------------- the player

export const D = {
  W: 600, H: 400,
  canvas: null, ctx: null,
  casts: {}, castLibs: {}, castByName: {}, filmloops: {},
  member0: null,
  sprites: [],
  score: null, labels: {}, labelList: [],
  frame: 0, frameCount: 0, pendingGo: null, playing: false,
  activeIntervals: new Map(), newIntervals: [], frameScript: null, frameScriptFrame: 0,
  SCRIPTS: {}, SCRIPT_MEMBERS: {}, movie: {},
  keys: new Set(), tapped: new Set(), mouse: { x: 0, y: 0, down: false }, hover: null, clickSprite: null,
  audio: null, channels: [],
  tellTarget: null,
  netRequests: {}, netCounter: 0,
  the_: { exitLock: 0, moviePath: '', movieName: 'battleblitz.dcr', runMode: 'Plugin' },
  fpsMeter: { last: 0, frames: 0, fps: 0 },
  errors: [],
  lastTick: 0, tickInterval: 1000 / 30,

  // ---- setup
  async init({ canvas, SCRIPTS, SCRIPT_MEMBERS, movie }) {
    this.canvas = canvas; this.ctx = canvas.getContext('2d');
    this.ctx.imageSmoothingEnabled = false;
    this.SCRIPTS = SCRIPTS; this.SCRIPT_MEMBERS = SCRIPT_MEMBERS; this.movie = movie;
    const [members, score] = await Promise.all([
      fetch(ASSET_BASE + 'members.json').then(r => r.json()),
      fetch(ASSET_BASE + 'score.json').then(r => r.json()),
    ]);
    this.castLibs = members.castLibs;
    this.filmloops = members.filmloops;
    for (const [num, cast] of Object.entries(members.casts)) {
      const c = { number: Number(num), name: cast.name, members: {}, byName: {}, fileName: '' };
      for (const [mn, info] of Object.entries(cast.members)) {
        const m = new Member(c.number, Number(mn), info);
        c.members[m.number] = m;
        c.byName[m.name.toLowerCase()] = m;
      }
      this.casts[c.number] = c;
      this.castByName[c.name.toLowerCase()] = c;
    }
    this.member0 = new Member(0, 0, null);
    G.newMember = (type, cast) => this.newMember(type, cast);
    this.score = score;
    this.labels = score.labels;
    this.labelList = Object.entries(score.labels).map(([n, f]) => [f, n]).sort((a, b) => a[0] - b[0]);
    for (let i = 0; i <= 160; i++) this.sprites.push(new Sprite(i));
    for (let i = 0; i < 8; i++) this.channels.push(new SoundChannel(i + 1));
    this.audio = new (window.AudioContext || window.webkitAudioContext)();
    this.installInput();
  },

  sprite(n) {
    while (this.sprites.length <= n) this.sprites.push(new Sprite(this.sprites.length));
    return this.sprites[n];
  },

  castLib(x) {
    if (typeof x === 'number') return this.casts[x];
    if (x && x.number !== undefined && x.members) return x;
    return this.castByName[String(x).toLowerCase()];
  },

  member(a, b) {
    if (typeof a === 'number' && b === undefined) {
      if (a === 0) return this.member0;
      const m = this.casts[1] && this.casts[1].members[a];
      return m || this.member0;
    }
    if (typeof a === 'number' && b !== undefined) {
      const c = this.castLib(b);
      return (c && c.members[a]) || this.member0;
    }
    const name = String(a).toLowerCase();
    if (b !== undefined) {
      const c = this.castLib(b);
      return (c && c.byName[name]) || this.member0;
    }
    for (const c of Object.values(this.casts)) if (c.byName[name]) return c.byName[name];
    return this.member0;
  },

  newMember(type, castRef) {
    const c = this.castLib(castRef && castRef.number !== undefined ? castRef.number : castRef) || this.casts[1];
    const nums = Object.keys(c.members).map(Number);
    const n = (nums.length ? Math.max(...nums) : 0) + 1;
    const m = new Member(c.number, n, { name: '', type });
    c.members[n] = m;
    return m;
  },

  memberRef(castLib, num, localCast) {
    const lib = castLib === -1 || castLib === 0 ? localCast : castLib;
    const c = this.casts[lib];
    return (c && c.members[num]) || null;
  },

  // ---- cast loading (stands in for Shockwave's network cast loading)
  preloadCast(castName, onDone) {
    const c = this.castByName[String(castName).toLowerCase()];
    if (!c) return Promise.resolve();
    const ms = Object.values(c.members).filter(m => m.file);
    c.loadTotal = ms.length; c.loadDone = 0;
    return Promise.all(ms.map(m => m.load().then(() => { c.loadDone++; }))).then(onDone);
  },
  castLoadStatus(castName) {
    const c = this.castByName[String(castName).toLowerCase()];
    if (!c) return { total: 1, done: 1 };
    const ms = Object.values(c.members).filter(m => m.file);
    return { total: ms.length || 1, done: ms.filter(m => m.loaded).length || (ms.length ? 0 : 1) };
  },
  castNameFromUrl(url) {
    const m = String(url).match(/([A-Za-z_]+)\.(cct|cst)$/);
    return m ? m[1] : null;
  },

  // ---- "the" properties
  the(name) {
    switch (name) {
      case 'frame': return this.frame;
      case 'milliSeconds': return Math.floor(performance.now());
      case 'mouseLoc': return new Point(this.mouse.x, this.mouse.y);
      case 'mouseH': return this.mouse.x;
      case 'mouseV': return this.mouse.y;
      case 'mouseDown': return this.mouse.down ? 1 : 0;
      case 'stage': return { rect: new Rect(0, 0, this.W, this.H) };
      case 'lastFrame': return this.score.frames.length;
      default: return this.the_[name];
    }
  },
  setThe(name, v) { this.the_[name] = v; },
  tell(target, fn) { const prev = this.tellTarget; this.tellTarget = target; try { fn(); } finally { this.tellTarget = prev; } },

  go(where) {
    if (this.tellTarget) { // "tell sprite(n) go(1)" restarts its film loop
      this.tellTarget.loopFrame = typeof where === 'number' ? where : 1;
      this.tellTarget.loopStarted = this.frameCount;
      return;
    }
    const f = typeof where === 'number' ? where : this.labels[where];
    if (f === undefined) { console.warn('go: unknown label', where); return; }
    this.pendingGo = f;
  },
  label(name) { const f = this.labels[name]; if (f === undefined) console.warn('unknown label', name); return f || 0; },
  marker(n) {
    // marker(1) = next label after the current frame; marker(0) = current/previous; marker(-1) = one before
    const cur = this.frame;
    let idx = -1;
    for (let i = 0; i < this.labelList.length; i++) if (this.labelList[i][0] <= cur) idx = i;
    const target = idx + n;
    if (n > 0) { const e = this.labelList[target]; return e ? e[0] : this.score.frames.length + 1; }
    const e = this.labelList[Math.max(0, target)];
    return e ? e[0] : 1;
  },

  // ---- film loops
  loopBounds(m) {
    if (m._bounds) return m._bounds;
    if (m.loop.rect) {
      const [l, t, r, b] = m.loop.rect;
      m._bounds = { l, t, w: r - l, h: b - t, regX: Math.floor((r - l) / 2), regY: Math.floor((b - t) / 2) };
      return m._bounds;
    }
    let l = Infinity, t = Infinity, r = -Infinity, b = -Infinity;
    for (const fr of m.loop.frames) {
      for (const rec of Object.values(fr.sprites)) {
        const sm = this.memberRef(rec[2], rec[3], m.castLib);
        if (!sm || !sm.w) continue;
        const w = rec[6] || sm.w, h = rec[7] || sm.h;
        const sx = sm.w ? w / sm.w : 1, sy = sm.h ? h / sm.h : 1;
        const x0 = rec[4] - sm.regX * sx, y0 = rec[5] - sm.regY * sy;
        l = Math.min(l, x0); t = Math.min(t, y0); r = Math.max(r, x0 + w); b = Math.max(b, y0 + h);
      }
    }
    if (l === Infinity) l = t = r = b = 0;
    m._bounds = { l, t, w: r - l, h: b - t, regX: Math.floor((r - l) / 2), regY: Math.floor((b - t) / 2) };
    return m._bounds;
  },

  // ---- score playback
  async start() {
    this.movie.prepareMovie();
    this.frame = 1;
    this.applyScoreFrame(this.frame, true);
    this.newIntervals = this.intervalsAt(this.frame);
    this.playing = true;
    this.lastTick = performance.now();
    // A timer rather than requestAnimationFrame: the original ran frame-locked at 30fps,
    // and rAF gets throttled in embedded/background views.
    const loop = () => {
      if (!this.playing) return;
      const now = performance.now();
      let n = 0;
      while (now - this.lastTick >= this.tickInterval && n < 2) {
        this.lastTick += this.tickInterval;
        if (now - this.lastTick > 200) this.lastTick = now; // fell far behind: resync
        try { this.tick(); } catch (e) { console.error('tick failed at frame', this.frame, e); this.errors.push(String(e && e.stack || e)); }
        n++;
      }
      setTimeout(loop, 4);
    };
    setTimeout(loop, 4);
  },

  intervalsAt(f) {
    const out = [];
    const ivs = this.score.intervals;
    for (let i = 0; i < ivs.length; i++) if (ivs[i].start <= f && f <= ivs[i].end) out.push(i);
    return out;
  },

  // Director (6+) only pushes score data into a channel when that data changes between
  // frames (a new span or a tweened value); Lingo edits to a sprite otherwise persist
  // for the rest of its span. `force` re-applies everything (used when a span begins).
  applyScoreFrame(f, force) {
    const fr = this.score.frames[f - 1];
    if (!fr) return;
    const present = new Set();
    for (const [ch, rec] of Object.entries(fr.sprites)) {
      const n = Number(ch);
      present.add(n);
      const s = this.sprite(n);
      if (s.puppet) continue;
      const prev = force ? null : s.scoreRec;
      s.scoreRec = rec;
      const changed = (i) => !prev || prev[i] !== rec[i];
      if (changed(2) || changed(3)) s.member = this.memberRef(rec[2], rec[3], 1);
      if (changed(4) || changed(5)) s.loc = new Point(rec[4], rec[5]);
      if (changed(6) || changed(7) || changed(2) || changed(3)) {
        const nat = s.natural();
        s._width = (rec[6] && rec[6] !== nat.w) ? rec[6] : 0;
        s._height = (rec[7] && rec[7] !== nat.h) ? rec[7] : 0;
      }
      if (changed(1)) s.ink = rec[1];
      if (changed(8)) s.blend = rec[8];
      if (changed(10)) s.rotation = rec[10] || 0;
    }
    for (let n = 1; n < this.sprites.length; n++) {
      const s = this.sprites[n];
      if (!s.puppet && !present.has(n) && s._member) { s.member = null; s.scoreRec = null; }
    }
  },

  scriptClass(castLib, memberNum) {
    return this.SCRIPT_MEMBERS[castLib + ':' + memberNum];
  },

  instantiateBehavior(castLib, memberNum, paramsText, spriteNum) {
    const cls = this.scriptClass(castLib, memberNum);
    if (!cls) { console.warn('no script for member', castLib, memberNum); return null; }
    const b = new cls();
    b.spriteNum = spriteNum;
    for (const [k, v] of parseParams(paramsText)) b[k] = v;
    return b;
  },

  beginIntervals(list) {
    for (const idx of list) {
      if (this.activeIntervals.has(idx)) continue;
      const iv = this.score.intervals[idx];
      const s = this.sprite(iv.ch);
      const instances = [];
      for (const [lib, mem, params] of iv.behaviors) {
        const b = this.instantiateBehavior(lib, mem, params, iv.ch);
        if (b) instances.push(b);
      }
      s.behaviors = s.behaviors.concat(instances);
      s.loopFrame = 1; s.loopStarted = this.frameCount;
      this.activeIntervals.set(idx, instances);
      for (const b of instances) if (b.beginSprite) b.beginSprite();
    }
  },

  endIntervals(list) {
    for (const idx of list) {
      const instances = this.activeIntervals.get(idx);
      if (!instances) continue;
      const iv = this.score.intervals[idx];
      for (const b of instances) if (b.endSprite) { try { b.endSprite(); } catch (e) { console.error(e); } }
      const s = this.sprite(iv.ch);
      s.behaviors = s.behaviors.filter(b => !instances.includes(b));
      this.activeIntervals.delete(idx);
    }
  },

  frameScriptFor(f) {
    const fr = this.score.frames[f - 1];
    if (!fr || !fr.script) return null;
    if (this.frameScript && this.frameScriptFrame === f) return this.frameScript;
    const cls = this.scriptClass(fr.script[0], fr.script[1]);
    if (!cls) console.warn('no frame script for', fr.script, 'at frame', f);
    this.frameScript = cls ? new cls() : null;
    this.frameScriptFrame = f;
    return this.frameScript;
  },

  dispatch(name) {
    for (const [idx, instances] of this.activeIntervals) for (const b of instances) if (b[name]) b[name]();
    const fs = this.frameScriptFor(this.frame);
    if (fs && fs[name]) fs[name]();
  },

  tick() {
    this.frameCount++;
    // sprites beginning on this frame
    if (this.newIntervals.length) { const l = this.newIntervals; this.newIntervals = []; this.beginIntervals(l); }
    // prepareFrame: behaviors then movie script
    this.dispatch('prepareFrame');
    if (this.movie.prepareFrame) this.movie.prepareFrame();
    this.dispatch('enterFrame');
    this.updateHover();
    this.render();
    this.dispatch('exitFrame');
    if (this.movie.exitFrame) this.movie.exitFrame();
    this.tapped.clear();   // taps shorter than a frame still get polled once
    // advance playhead
    let next = this.pendingGo !== null ? this.pendingGo : this.frame + 1;
    this.pendingGo = null;
    if (next > this.score.frames.length) next = this.score.frames.length;
    const cur = this.intervalsAt(this.frame);
    const nxt = this.intervalsAt(next);
    const nxtSet = new Set(nxt);
    const ending = cur.filter(i => !nxtSet.has(i));
    this.endIntervals(ending);
    this.frame = next;
    this.newIntervals = nxt.filter(i => !this.activeIntervals.has(i));
    for (const i of this.newIntervals) this.sprite(this.score.intervals[i].ch).scoreRec = null;
    this.applyScoreFrame(this.frame);
    // film loops advance one frame per tick
    for (const s of this.sprites) {
      const lp = s._member && s._member.loop;
      if (!lp) continue;
      const n = lp.frames.length, el = this.frameCount - s.loopStarted;
      s.loopFrame = lp.loop === false ? Math.min(el, n - 1) + 1 : (el % n) + 1;
    }
  },

  // ---- rendering
  render() {
    const ctx = this.ctx;
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.globalAlpha = 1;
    ctx.globalCompositeOperation = 'source-over';
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, this.W, this.H);
    const order = [];
    for (let n = 1; n < this.sprites.length; n++) {
      const s = this.sprites[n];
      if (s._member && s.visible) order.push(s);
    }
    order.sort((a, b) => (a.locZ - b.locZ) || (a.spriteNum - b.spriteNum));
    for (const s of order) this.drawSprite(s);
  },

  drawSprite(s) {
    const m = s._member;
    if (m.loop) return this.drawFilmLoop(s, m);
    if (m.type === 'text') return this.drawText(s, m);
    if (!m.loaded && !m.loading) m.load();
    const img = m.drawable(s.ink);
    if (!img) return;
    const r = s.rect;
    this.blit(img, r, s.ink, s.blend, s.flipH, s.flipV, s.rotation, s.loc);
  },

  blit(img, r, ink, blend, flipH, flipV, rotation, pivot) {
    const ctx = this.ctx;
    ctx.save();
    ctx.globalAlpha = Math.max(0, Math.min(1, blend / 100));
    switch (ink) {
      case 39: case 41: ctx.globalCompositeOperation = 'darken'; break;   // darkest / darken
      case 37: case 40: ctx.globalCompositeOperation = 'lighten'; break;  // lightest / lighten
      case 33: case 34: ctx.globalCompositeOperation = 'lighter'; break;  // add
      case 38: case 35: ctx.globalCompositeOperation = 'difference'; break;
      default: ctx.globalCompositeOperation = 'source-over';
    }
    if (rotation) { ctx.translate(pivot.locH, pivot.locV); ctx.rotate(rotation * Math.PI / 180); ctx.translate(-pivot.locH, -pivot.locV); }
    if (flipH || flipV) {
      ctx.translate(flipH ? r.left + r.right : 0, flipV ? r.top + r.bottom : 0);
      ctx.scale(flipH ? -1 : 1, flipV ? -1 : 1);
    }
    ctx.drawImage(img, r.left, r.top, r.width, r.height);
    ctx.restore();
  },

  drawFilmLoop(s, m) {
    const b = this.loopBounds(m);
    const fr = m.loop.frames[(s.loopFrame - 1) % m.loop.frames.length];
    if (!fr) return;
    const sr = s.rect;
    const sx = b.w ? sr.width / b.w : 1, sy = b.h ? sr.height / b.h : 1;
    const recs = Object.entries(fr.sprites).map(([ch, rec]) => [Number(ch), rec]).sort((a, b2) => a[0] - b2[0]);
    for (const [ch, rec] of recs) {
      const sm = this.memberRef(rec[2], rec[3], m.castLib);
      if (!sm || (!sm.file && !sm._img)) continue;
      if (!sm.loaded && !sm.loading) sm.load();
      const img = sm.drawable(rec[1]);
      if (!img) continue;
      const w = rec[6] || sm.w, h = rec[7] || sm.h;
      const msx = sm.w ? w / sm.w : 1, msy = sm.h ? h / sm.h : 1;
      const x0 = rec[4] - sm.regX * msx - b.l, y0 = rec[5] - sm.regY * msy - b.t;
      const r = new Rect(sr.left + x0 * sx, sr.top + y0 * sy, sr.left + (x0 + w) * sx, sr.top + (y0 + h) * sy);
      this.blit(img, r, rec[1], Math.min(rec[8], s.blend), s.flipH, s.flipV, 0, s.loc);
    }
  },

  drawText(s, m) {
    const ctx = this.ctx;
    ctx.save();
    ctx.font = '12px monospace';
    ctx.fillStyle = '#fff';
    ctx.textBaseline = 'top';
    ctx.fillText(m.text, s.loc.locH, s.loc.locV);
    ctx.restore();
  },

  // ---- input
  installInput() {
    const c = this.canvas;
    const toStage = (e) => {
      const b = c.getBoundingClientRect();
      return { x: (e.clientX - b.left) * this.W / b.width, y: (e.clientY - b.top) * this.H / b.height };
    };
    c.addEventListener('mousemove', e => { const p = toStage(e); this.mouse.x = p.x; this.mouse.y = p.y; this.updateHover(); });
    c.addEventListener('mousedown', e => {
      const p = toStage(e); this.mouse.x = p.x; this.mouse.y = p.y; this.mouse.down = true;
      if (this.audio.state === 'suspended') this.audio.resume();
      this.updateHover();
      const s = this.spriteUnderMouse();
      this.clickSprite = s;
      if (s) for (const b of s.behaviors.slice()) if (b.mouseDown) b.mouseDown();
      e.preventDefault();
    });
    window.addEventListener('mouseup', e => {
      const p = toStage(e); this.mouse.x = p.x; this.mouse.y = p.y; this.mouse.down = false;
      const s = this.spriteUnderMouse();
      const target = (s && s === this.clickSprite) ? s : s;
      if (target) for (const b of target.behaviors.slice()) if (b.mouseUp) b.mouseUp();
      this.clickSprite = null;
    });
    c.addEventListener('contextmenu', e => e.preventDefault());
    window.addEventListener('keydown', e => {
      if (this.audio && this.audio.state === 'suspended') this.audio.resume();
      const code = keyCodeOf(e);
      if (code !== undefined) { this.keys.add(code); this.tapped.add(code); if ((e.key || '').startsWith('Arrow') || e.key === ' ') e.preventDefault(); }
    });
    window.addEventListener('keyup', e => { const code = keyCodeOf(e); if (code !== undefined) this.keys.delete(code); });
    window.addEventListener('blur', () => this.keys.clear());
  },

  spriteUnderMouse() {
    const p = new Point(this.mouse.x, this.mouse.y);
    let best = null;
    for (let n = 1; n < this.sprites.length; n++) {
      const s = this.sprites[n];
      if (!s._member || !s.visible || !s.behaviors.length) continue;
      if (!p.inside(s.rect)) continue;
      if (s.ink === 8) { // matte: only opaque pixels count
        const img = s._member.drawable(8);
        if (img) {
          const r = s.rect;
          const x = Math.floor((p.locH - r.left) * img.width / r.width), y = Math.floor((p.locV - r.top) * img.height / r.height);
          const d = img.getContext('2d').getImageData(x, y, 1, 1).data;
          if (d[3] === 0) continue;
        }
      }
      if (!best || s.locZ >= best.locZ) best = s;
    }
    return best;
  },

  updateHover() {
    const s = this.spriteUnderMouse();
    if (s !== this.hover) {
      if (this.hover) for (const b of this.hover.behaviors.slice()) if (b.mouseLeave) b.mouseLeave();
      this.hover = s;
      if (s) for (const b of s.behaviors.slice()) if (b.mouseEnter) b.mouseEnter();
    } else if (s) {
      for (const b of s.behaviors.slice()) if (b.mouseWithin) b.mouseWithin();
    }
  },

  setCursor(n) {
    this.canvas.style.cursor = n === 280 ? 'pointer' : n === 4 ? 'wait' : n === 200 ? 'none' : 'default';
  },
};

function parseParams(text) {
  // "[#locZLayer: #SPRITE_LOCZ_GAME_TEXT, #volumeLevel: 100, #stopAtEndSprite: 0]"
  const out = [];
  if (!text) return out;
  const body = text.trim().replace(/^\[/, '').replace(/\]$/, '');
  if (!body.trim() || body.trim() === ':') return out;
  for (const part of body.split(',')) {
    const m = part.match(/^\s*#(\w+)\s*:\s*(.*?)\s*$/);
    if (!m) continue;
    let v = m[2];
    if (v.startsWith('#')) v = v.slice(1);
    else if (v.startsWith('"')) v = v.replace(/^"|"$/g, '');
    else if (/^-?\d+(\.\d+)?$/.test(v)) v = Number(v);
    out.push([m[1], v]);
  }
  return out;
}

// ---------------------------------------------------------------- Lingo-facing functions

export function sprite(n) { return D.sprite(n); }
export function member(a, b) { return D.member(a, b); }
export function castLib(x) {
  const c = D.castLib(x);
  if (!c) return { number: 0, name: '', fileName: '' };
  if (!c._proxy) {
    c._proxy = {
      get number() { return c.number; },
      get name() { return c.name; },
      get fileName() { return c.fileName; },
      set fileName(url) { c.fileName = url; D.preloadCast(c.name); },
    };
  }
  return c._proxy;
}
export function sound(n) { return D.channels[n - 1]; }
export function label(name) { return D.label(name); }
export function marker(n) { return D.marker(n); }
export function script(name) { const c = D.SCRIPTS[name]; if (!c) throw new Error('no script ' + name); return c; }
export function preloadMember() { }
export function cursor(n) { D.setCursor(n); }
export function go(where) { D.go(where); }
export function nothing() { }
export function pass() { }
export function puppetTempo() { }
export function clearGlobals() { }
export function keyPressed(code) { return (D.keys.has(code) || D.tapped.has(code)) ? 1 : 0; }
export function preloadNetThing(url) {
  const id = ++D.netCounter;
  const cast = D.castNameFromUrl(url);
  D.netRequests[id] = { url, cast, done: !cast };
  if (cast) D.preloadCast(cast, () => { D.netRequests[id].done = true; });
  return id;
}
export function netDone(id) { const r = D.netRequests[id]; return (!r || r.done) ? 1 : 0; }
export function netAbort() { }
export function getStreamStatus(url) {
  const cast = D.castNameFromUrl(url);
  if (!cast) return PL([['URL', url], ['state', 'Complete'], ['bytesSoFar', 1], ['bytesTotal', 1], ['error', '']]);
  const st = D.castLoadStatus(cast);
  return PL([['URL', url], ['state', st.done >= st.total ? 'Complete' : 'InProgress'], ['bytesSoFar', st.done], ['bytesTotal', st.total], ['error', '']]);
}
export function image(w, h) { const c = document.createElement('canvas'); c.width = w; c.height = h; return new LImage(c); }
