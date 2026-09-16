// A small Flash-6-style timeline player rendering to SVG.
// Loads assets/movie.json (timelines, texts, buttons, fonts) and assets/defs.svg (vector art).
// MovieClip mirrors the bits of the AS2 MovieClip API the game uses.

const NS = 'http://www.w3.org/2000/svg';
const XLINK = 'http://www.w3.org/1999/xlink';

export class Player {
  constructor(svgEl, movie, defsDoc) {
    this.svg = svgEl;
    this.movie = movie;
    this.rate = movie.rate;
    this.svg.setAttribute('viewBox', `0 0 ${movie.width} ${movie.height}`);
    // vector art definitions
    const defs = document.importNode(defsDoc.documentElement.querySelector('defs'), true);
    this.svg.appendChild(defs);
    this.stage = document.createElementNS(NS, 'g');
    this.svg.appendChild(this.stage);
    this.hooks = {};        // `${spriteId}:${frame}` -> fn(clip)
    this.loadHooks = {};    // spriteId -> fn(clip), runs once when a clip of that sprite is placed (onClipEvent(load))
    this.textVars = {};     // last path segment of an edit text's variable -> current value
    this.seenErrors = new Set();
    this.buttonHandlers = {}; // buttonId -> fn(button, event)
    this.sounds = {};
    this.muted = new URLSearchParams(location.search).has('mute');
    this.keys = new Set();
    this.mouse = { x: 0, y: 0 };
    this.frameCount = 0;
    this.time0 = performance.now();
    this.root = new MovieClip(this, null, 'main', movie.main, '_root', 0);
    this.stage.appendChild(this.root.el);
    this.root.applyFrame(true);
    // a key tapped between two ticks still reads as down for the next tick
    this.tapped = new Set();
    window.addEventListener('keydown', e => { this.keys.add(e.keyCode); this.tapped.add(e.keyCode); if ([32, 37, 38, 39, 40].includes(e.keyCode)) e.preventDefault(); });
    window.addEventListener('keyup', e => this.keys.delete(e.keyCode));
    window.addEventListener('blur', () => { this.keys.clear(); this.tapped.clear(); });
    this.svg.addEventListener('mousemove', e => { const p = this.toStage(e); this.mouse = p; });
  }

  toStage(e) {
    const pt = this.svg.createSVGPoint(); pt.x = e.clientX; pt.y = e.clientY;
    const m = this.svg.getScreenCTM().inverse();
    const r = pt.matrixTransform(m);
    return { x: r.x, y: r.y };
  }

  // game time advances with ticks (not wall clock) so a throttled/lagging frame loop slows everything uniformly
  getTimer() { return Math.floor(this.frameCount * 1000 / this.rate); }
  isKeyDown(code) { return this.keys.has(code) || this.tapped.has(code); }

  onFrame(spriteId, frame, fn) { this.hooks[`${spriteId}:${frame}`] = fn; }
  onLoad(spriteId, fn) { this.loadHooks[spriteId] = fn; }
  // set a bound text variable (e.g. 'score' for `_root.score`): existing fields update, new ones pick it up on creation
  setVar(name, value) {
    this.textVars[name] = value;
    const walk = (clip) => { for (const c of clip.children.values()) { if (c instanceof TextField) { if (c.varName === name) c.setText(value); } else if (c instanceof MovieClip) walk(c); } };
    walk(this.root);
  }
  onButton(buttonId, fn) { this.buttonHandlers[buttonId] = fn; }

  start() {
    // frame clock: catch up at most a few frames per beat, resync after long stalls, and hold the
    // game while the tab is hidden unless ?bg is given (used for automated playtests)
    const interval = 1000 / this.rate;
    const runHidden = new URLSearchParams(location.search).has('bg');
    let last = performance.now();
    const beat = () => {
      const now = performance.now();
      if (document.hidden && !runHidden) { last = now; return; }
      if (now - last > 250) last = now - interval;
      let n = 0;
      while (now - last >= interval && n < 3) { last += interval; this.tick(); n++; }
    };
    // three clocks all call the same time-based beat, so whichever the browser lets run keeps the game going
    const raf = () => { beat(); requestAnimationFrame(raf); };
    requestAnimationFrame(raf);
    setInterval(beat, interval / 2);
    try {
      const src = `setInterval(() => postMessage(0), ${interval / 2});`;
      const w = new Worker(URL.createObjectURL(new Blob([src], { type: 'text/javascript' })));
      w.onmessage = beat;
    } catch (e) { /* no worker: the timers above carry it */ }
  }

  tick() {
    this.frameCount++;
    this.root.tick();
    if (this.onTick) this.onTick();
    this.tapped.clear();
  }

  // ---- sound
  playSound(id, info = {}) {
    const url = this.movie.sounds[String(id)];
    if (!url || this.muted) return;
    if (!this.sounds[id]) { const a = new Audio('../assets/' + url); a.preload = 'auto'; this.sounds[id] = a; }
    const a = this.sounds[id];
    if (info.stop) { a.pause(); a.currentTime = 0; return; }
    if (info.noMultiple && !a.paused) return;
    a.loop = (info.loops || 0) > 1;
    a.currentTime = 0;
    a.play().catch(() => { });
  }
  stopAllSounds() { for (const a of Object.values(this.sounds)) { a.pause(); a.currentTime = 0; } }
}

// ---------------------------------------------------------------- display objects

let depthSeq = 0;

export class MovieClip {
  static count = 0;
  constructor(player, parent, charId, timeline, name, depth) {
    this.player = player; this.parent = parent; this.charId = charId;
    this.timeline = timeline;  // {frames, labels, sounds}
    this._name = name; this.depth = depth;
    this.el = document.createElementNS(NS, 'g');
    this.el.dataset.name = name || '';
    this.children = new Map();   // depth -> child (MovieClip | StaticObj)
    this.currentFrame = 1;
    this.playing = true;
    this.pendingGoto = null;
    this.x = 0; this.y = 0; this.xscale = 100; this.yscale = 100; this.rotation = 0; this.visible = true; this.alpha = 100;
    this.m = [1, 0, 0, 1, 0, 0];
    this.onEnterFrame = null;
    this.vars = {};
    this.dead = false;
    this.justCreated = true;
    this.scriptDone = false;
    this.uid = ++MovieClip.count;
  }

  // ---- AS2-ish properties
  // (once a script sets a transform property the timeline stops driving that clip's matrix, as in Flash)
  get _x() { return this.x; } set _x(v) { this.x = v; this.m[4] = v; this.scriptMoved = true; this.writeTransform(); }
  get _y() { return this.y; } set _y(v) { this.y = v; this.m[5] = v; this.scriptMoved = true; this.writeTransform(); }
  get _xscale() { return this.xscale; } set _xscale(v) { this.xscale = v; this.scriptMoved = true; this.updateTransform(); }
  get _yscale() { return this.yscale; } set _yscale(v) { this.yscale = v; this.scriptMoved = true; this.updateTransform(); }
  get _rotation() { return this.rotation; } set _rotation(v) { this.rotation = v; this.scriptMoved = true; this.updateTransform(); }
  get _visible() { return this.visible; } set _visible(v) { this.visible = !!v; this.el.style.display = this.visible ? '' : 'none'; }
  get _alpha() { return this.alpha; } set _alpha(v) { this.alpha = v; this.el.style.opacity = String(v / 100); }
  get _currentframe() { return this.currentFrame; }
  get _totalframes() { return this.timeline.frames.length; }
  get _parent() { return this.parent; }

  setMatrix(m) {
    // keep the raw SWF matrix (it may carry skew); expose the AS2 view of it for reads
    this.m = m.slice();
    this.x = m[4]; this.y = m[5];
    const a = m[0], b = m[1], c = m[2], d = m[3];
    if (Math.abs(b) < 1e-6 && Math.abs(c) < 1e-6) { this.rotation = 0; this.xscale = a * 100; this.yscale = d * 100; }
    else { this.rotation = Math.atan2(b, a) * 180 / Math.PI; this.xscale = Math.hypot(a, b) * 100; this.yscale = Math.hypot(c, d) * 100 * (a * d - b * c < 0 ? -1 : 1); }
    this.writeTransform();
  }

  updateTransform() {
    // script changed x/y/scale/rotation: recompose (scripted clips in this game never skew)
    const r = this.rotation * Math.PI / 180, cos = Math.cos(r), sin = Math.sin(r);
    const sx = this.xscale / 100, sy = this.yscale / 100;
    this.m = [cos * sx, sin * sx, -sin * sy, cos * sy, this.x, this.y];
    this.writeTransform();
  }

  writeTransform() {
    this.el.setAttribute('transform', `matrix(${this.m.map(fmt).join(' ')})`);
  }

  // ---- timeline control
  frameOf(f) {
    if (typeof f === 'number') return Math.max(1, Math.min(this._totalframes, f));
    let n = this.timeline.labels[f];
    if (n === undefined) { const k = Object.keys(this.timeline.labels).find(l => l.toLowerCase() === String(f).toLowerCase()); if (k) n = this.timeline.labels[k]; }
    if (n === undefined) { console.warn('unknown label', f, 'in', this._name, this.charId); return this.currentFrame; }
    return n;
  }
  play() { this.playing = true; }
  stop() { this.playing = false; }
  gotoAndPlay(f) { this.pendingGoto = this.frameOf(f); this.playing = true; this.applyGoto(); }
  gotoAndStop(f) { this.pendingGoto = this.frameOf(f); this.playing = false; this.applyGoto(); }
  nextFrame() { this.gotoAndStop(this.currentFrame + 1); }
  prevFrame() { this.gotoAndStop(this.currentFrame - 1); }
  applyGoto() {
    if (this.pendingGoto === null) return;
    const f = this.pendingGoto; this.pendingGoto = null;
    if (f !== this.currentFrame) { this.currentFrame = f; this.scriptDone = false; this.applyFrame(false); this.runFrameScript(); }
  }

  tick() {
    if (this.dead) return;
    if (this.justCreated) {
      // a freshly placed clip shows its first frame for one tick before advancing; its frame script
      // runs now unless a goto already ran it
      this.justCreated = false;
      this.runEnterFrame();
      if (this.dead) return;
      if (!this.scriptDone) this.runFrameScript();
    } else {
      let advanced = false;
      if (this.playing && this._totalframes > 1) {
        this.currentFrame = this.currentFrame >= this._totalframes ? 1 : this.currentFrame + 1;
        this.scriptDone = false;
        this.applyFrame(false);
        advanced = true;
      }
      this.runEnterFrame();
      if (this.dead) return;
      // the script of the frame we just entered (a play() from onEnterFrame must not re-run the current one)
      if (advanced && !this.scriptDone) this.runFrameScript();
    }
    for (const c of [...this.children.values()]) if (c instanceof MovieClip) c.tick();
  }

  // script errors are logged (once per message) rather than aborting the whole tick
  guard(fn) {
    try { fn(); } catch (e) {
      const msg = String(e && e.stack || e);
      if (!this.player.seenErrors.has(msg)) { this.player.seenErrors.add(msg); console.error('script error in', this.charId, this._name, e); }
    }
  }
  runEnterFrame() { if (this.onEnterFrame) this.guard(() => this.onEnterFrame.call(this)); }
  runFrameScript() {
    this.scriptDone = true;
    const key = `${this.charId}:${this.currentFrame}`;
    const fn = this.player.hooks[key];
    if (fn) this.guard(() => fn(this));
    const snd = this.timeline.sounds[String(this.currentFrame)];
    if (snd) for (const s of snd) this.player.playSound(s.id, s);
  }

  // Reconcile children with the display list of the current frame.
  applyFrame(force) {
    const list = this.timeline.frames[this.currentFrame - 1] || {};
    const seen = new Set();
    for (const [dStr, rec] of Object.entries(list)) {
      const d = Number(dStr);
      seen.add(d);
      let child = this.children.get(d);
      if (child && child.charId !== rec.id) { this.removeChild(d); child = null; }
      if (!child) {
        child = this.createChild(rec.id, rec.name || '', d);
        if (!child) continue;
        child.setMatrix(rec.m);
        if (rec.cx) child.applyCxform(rec.cx);
        this.insertChild(child);
        if (child instanceof MovieClip) child.fireLoad();
      } else if (rec.k || force) {
        if (!(child instanceof MovieClip) || !child.scriptMoved) child.setMatrix(rec.m);
        if (rec.cx) child.applyCxform(rec.cx);
      }
    }
    for (const d of [...this.children.keys()]) if (!seen.has(d) && !this.children.get(d).scriptCreated) this.removeChild(d);
  }

  createChild(id, name, depth) {
    const mv = this.player.movie;
    const sid = String(id);
    if (mv.sprites[sid]) {
      const c = new MovieClip(this.player, this, id, mv.sprites[sid], name, depth);
      c.applyFrame(true);
      return c;
    }
    if (mv.texts[sid]) return new TextField(this.player, this, id, mv.texts[sid], name, depth);
    if (mv.buttons[sid]) return new Button(this.player, this, id, mv.buttons[sid], name, depth);
    return new StaticObj(this.player, this, id, name, depth);
  }

  insertChild(child) {
    this.children.set(child.depth, child);
    // keep SVG order by depth
    const after = [...this.children.values()].filter(c => c.depth > child.depth).sort((a, b) => a.depth - b.depth)[0];
    if (after) this.el.insertBefore(child.el, after.el); else this.el.appendChild(child.el);
    if (child._name) this[child._name] = child;
  }

  removeChild(d) {
    const c = this.children.get(d);
    if (!c) return;
    c.destroy();
    this.children.delete(d);
    if (c._name && this[c._name] === c) delete this[c._name];
  }

  destroy() {
    this.dead = true;
    for (const d of [...this.children.keys()]) this.removeChild(d);
    if (this.el.parentNode) this.el.parentNode.removeChild(this.el);
  }

  applyCxform(cx) { applyCxform(this.player, this.el, cx); }

  // ---- AS2 extras used by the game
  duplicateMovieClip(newName, depth) {
    const c = new MovieClip(this.player, this.parent, this.charId, this.timeline, newName, depth);
    c.scriptCreated = true;
    c.setMatrix(this.m);
    c.applyFrame(true);
    this.parent.insertChild(c);
    c.fireLoad();
    return c;
  }
  fireLoad() {
    if (!(this instanceof MovieClip)) return;
    const fn = this.player.loadHooks[this.charId];
    if (fn) fn(this);
  }
  removeMovieClip() { if (this.parent) this.parent.removeChild(this.depth); }
  child(name) { return this[name]; }
  setText(varName, value) { for (const c of this.children.values()) if (c instanceof TextField && c.def.var.endsWith(varName)) c.setText(value); }
}

class StaticObj {
  constructor(player, parent, id, name, depth) {
    this.player = player; this.parent = parent; this.charId = id; this._name = name; this.depth = depth;
    this.el = document.createElementNS(NS, 'use');
    this.el.setAttributeNS(XLINK, 'xlink:href', '#c' + id);
  }
  setMatrix(m) { this.el.setAttribute('transform', `matrix(${m.map(fmt).join(' ')})`); }
  applyCxform(cx) { applyCxform(this.player, this.el, cx); }
  destroy() { if (this.el.parentNode) this.el.parentNode.removeChild(this.el); }
}

// Flash colour transform: channel' = channel * mul + add. Alpha-only transforms map to opacity;
// anything else becomes an feColorMatrix filter (cached per distinct transform).
function applyCxform(player, el, cx) {
  const mul = cx.mul || [1, 1, 1, 1], add = cx.add || [0, 0, 0, 0];
  const identityRGB = mul[0] === 1 && mul[1] === 1 && mul[2] === 1 && add[0] === 0 && add[1] === 0 && add[2] === 0;
  if (identityRGB) {
    el.style.opacity = mul[3] === 1 && add[3] === 0 ? '' : String(Math.max(0, Math.min(1, mul[3] + add[3] / 255)));
    el.removeAttribute('filter');
    return;
  }
  const key = [...mul, ...add].map(v => Math.round(v * 1000)).join('_');
  const id = 'cx' + key.replace(/-/g, 'n');
  if (!document.getElementById(id)) {
    const f = document.createElementNS(NS, 'filter');
    f.setAttribute('id', id); f.setAttribute('color-interpolation-filters', 'sRGB');
    const cm = document.createElementNS(NS, 'feColorMatrix');
    cm.setAttribute('type', 'matrix');
    cm.setAttribute('values', [
      mul[0], 0, 0, 0, add[0] / 255,
      0, mul[1], 0, 0, add[1] / 255,
      0, 0, mul[2], 0, add[2] / 255,
      0, 0, 0, mul[3], add[3] / 255,
    ].map(v => Number(v.toFixed(4))).join(' '));
    f.appendChild(cm);
    player.svg.querySelector('defs').appendChild(f);
  }
  el.setAttribute('filter', `url(#${id})`);
}

class TextField {
  constructor(player, parent, id, def, name, depth) {
    this.player = player; this.parent = parent; this.charId = id; this.def = def; this._name = name; this.depth = depth;
    this.el = document.createElementNS(NS, 'g');
    this.varName = def.var ? def.var.split('.').pop() : '';
    const bound = this.varName && player.textVars[this.varName];
    this.setText(bound !== undefined && bound !== false ? bound : def.text !== undefined ? def.text.replace(/\r/g, '') : '');
  }
  setMatrix(m) { this.el.setAttribute('transform', `matrix(${m.map(fmt).join(' ')})`); }
  applyCxform() { }
  destroy() { if (this.el.parentNode) this.el.parentNode.removeChild(this.el); }
  setText(value) {
    const t = this.def;
    while (this.el.firstChild) this.el.removeChild(this.el.firstChild);
    const text = String(value);
    const font = this.player.movie.fonts[String(t.font)];
    const size = t.size || 15;
    const [l, top, r, bottom] = t.bounds;
    if (!font || !font.glyphs.length) {
      const te = document.createElementNS(NS, 'text');
      te.setAttribute('x', fmt(l + 2)); te.setAttribute('y', fmt(top + size));
      te.setAttribute('font-size', size); te.setAttribute('font-family', 'Arial, sans-serif'); te.setAttribute('fill', t.color || '#000');
      te.textContent = text;
      this.el.appendChild(te);
      return;
    }
    // embedded font: glyph uses, laid out with the font's advance table
    let width = 0;
    const codes = [...text].map(ch => ch.charCodeAt(0));
    for (const c of codes) width += (font.advances[String(c)] || 0.5) * size;
    let x = l + 2;
    if (t.align === 'center') x = l + (r - l - width) / 2;
    else if (t.align === 'right') x = r - 2 - width;
    const y = top + 2 + font.ascent * size;
    for (const c of codes) {
      const u = document.createElementNS(NS, 'use');
      u.setAttributeNS(XLINK, 'xlink:href', `#font_${t.font}_${c}`);
      u.setAttribute('transform', `translate(${fmt(x)} ${fmt(y)}) scale(${fmt(size)})`);
      u.setAttribute('fill', t.color || '#000');
      this.el.appendChild(u);
      x += (font.advances[String(c)] || 0.5) * size;
    }
  }
}

class Button {
  constructor(player, parent, id, def, name, depth) {
    this.player = player; this.parent = parent; this.charId = id; this.def = def; this._name = name; this.depth = depth;
    this.el = document.createElementNS(NS, 'g');
    this.el.style.cursor = 'pointer';
    this.states = { up: this.buildState('up'), over: this.buildState('over'), down: this.buildState('down') };
    this.hit = this.buildState('hit');
    this.hit.style.opacity = '0'; this.hit.style.pointerEvents = 'fill';
    this.el.appendChild(this.states.up); this.el.appendChild(this.states.over); this.el.appendChild(this.states.down); this.el.appendChild(this.hit);
    this.show('up');
    this.el.addEventListener('mouseenter', () => this.show('over'));
    this.el.addEventListener('mouseleave', () => this.show('up'));
    // the SWF says whether a button's script runs on press (overUpToOverDown) or release (overDownToOverUp);
    // a release only counts if the press started on this same button
    this.pressed = false;
    this.el.addEventListener('mousedown', e => { this.show('down'); this.pressed = true; if (def.press) this.fire('press'); e.preventDefault(); });
    this.el.addEventListener('mouseup', () => { this.show('over'); if (this.pressed && def.release) this.fire('release'); this.pressed = false; });
    window.addEventListener('mouseup', () => { this.pressed = false; });
  }
  buildState(state) {
    const g = document.createElementNS(NS, 'g');
    for (const r of this.def.records) {
      if (!r[state]) continue;
      const mv = this.player.movie;
      let node;
      if (mv.sprites[String(r.id)]) {
        const c = new MovieClip(this.player, null, r.id, mv.sprites[String(r.id)], '', r.depth); c.applyFrame(true); node = c.el; c.setMatrix(r.m);
        this._clips = this._clips || []; this._clips.push(c);
      } else {
        node = document.createElementNS(NS, 'use');
        node.setAttributeNS(XLINK, 'xlink:href', '#c' + r.id);
        node.setAttribute('transform', `matrix(${r.m.map(fmt).join(' ')})`);
      }
      g.appendChild(node);
    }
    return g;
  }
  show(state) { for (const [k, g] of Object.entries(this.states)) g.style.display = k === state ? '' : 'none'; }
  fire(kind) { const h = this.player.buttonHandlers[this.charId]; if (h) h(this, kind); }
  setMatrix(m) { this.el.setAttribute('transform', `matrix(${m.map(fmt).join(' ')})`); }
  applyCxform() { }
  destroy() { if (this.el.parentNode) this.el.parentNode.removeChild(this.el); }
}

function fmt(n) { return Number.isInteger(n) ? String(n) : n.toFixed(3); }

export async function loadPlayer(svgEl, base = '../assets/') {
  const [movie, defsText] = await Promise.all([
    fetch(base + 'movie.json').then(r => r.json()),
    fetch(base + 'defs.svg').then(r => r.text()),
  ]);
  const defsDoc = new DOMParser().parseFromString(defsText, 'image/svg+xml');
  return new Player(svgEl, movie, defsDoc);
}
