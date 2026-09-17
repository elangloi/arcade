// A small Flash-style timeline player rendering to SVG.
// Loads <assets>/movie.json (timelines, texts, buttons, fonts, exports) and <assets>/defs.svg
// (vector art). MovieClip mirrors the bits of the AS2 MovieClip API the ported games use.
// Several movies can be loaded into one player (loadMovie/loadClip): each gets its own id
// prefix in the shared <defs>.

const NS = 'http://www.w3.org/2000/svg';
const XLINK = 'http://www.w3.org/1999/xlink';

// One loaded SWF: its extracted json plus the id prefix its art carries in the page's <defs>.
class Movie {
  constructor(json, base, prefix) { this.json = json; this.base = base; this.prefix = prefix; }
  ref(id) { return `#${this.prefix}c${id}`; }
}

export class Player {
  constructor(svgEl, movie, defsDoc, base = '../assets/') {
    this.svg = svgEl;
    this.rate = movie.rate;
    this.svg.setAttribute('viewBox', `0 0 ${movie.width} ${movie.height}`);
    this.defs = document.createElementNS(NS, 'defs');
    this.svg.appendChild(this.defs);
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
    this.mouseDown = false;
    this.frameCount = 0;
    this.movies = [];
    this.main = this.addMovie(movie, base, defsDoc);
    this.movie = movie;       // (the main movie's json, for the games' convenience)
    this.root = new MovieClip(this, null, 'main', movie.main, '_root', 0, this.main);
    this.stage.appendChild(this.root.el);
    this.root.applyFrame(true);
    // a key tapped between two ticks still reads as down for the next tick
    this.tapped = new Set();
    window.addEventListener('keydown', e => { this.keys.add(e.keyCode); this.tapped.add(e.keyCode); if ([32, 37, 38, 39, 40].includes(e.keyCode)) e.preventDefault(); });
    window.addEventListener('keyup', e => this.keys.delete(e.keyCode));
    window.addEventListener('blur', () => { this.keys.clear(); this.tapped.clear(); this.mouseDown = false; });
    this.svg.addEventListener('mousemove', e => { this.mouse = this.toStage(e); });
    this.svg.addEventListener('mousedown', e => { this.mouse = this.toStage(e); this.mouseDown = true; if (this.onMouseDown) this.onMouseDown(); e.preventDefault(); });
    window.addEventListener('mouseup', () => { if (this.mouseDown) { this.mouseDown = false; if (this.onMouseUp) this.onMouseUp(); } });
    this.svg.addEventListener('contextmenu', e => e.preventDefault());
  }

  // Import a movie's art into the shared <defs> under a unique id prefix and remember it.
  addMovie(json, base, defsDoc) {
    const prefix = this.movies.length ? `m${this.movies.length}_` : '';
    const mv = new Movie(json, base, prefix);
    const defs = document.importNode(defsDoc.documentElement.querySelector('defs'), true);
    if (prefix) {
      for (const el of defs.querySelectorAll('[id]')) el.setAttribute('id', prefix + el.getAttribute('id'));
      for (const el of defs.querySelectorAll('*')) {
        const h = el.getAttributeNS(XLINK, 'href') || el.getAttribute('href');
        if (h && h.startsWith('#')) { el.setAttributeNS(XLINK, 'xlink:href', '#' + prefix + h.slice(1)); el.removeAttribute('href'); }
        for (const a of ['fill', 'stroke', 'filter', 'clip-path', 'mask']) {
          const v = el.getAttribute(a);
          if (v && v.startsWith('url(#')) el.setAttribute(a, `url(#${prefix}${v.slice(5)}`);
        }
      }
    }
    while (defs.firstChild) this.defs.appendChild(defs.firstChild);
    this.movies.push(mv);
    return mv;
  }

  // Fetch another SWF's extraction (a folder with movie.json + defs.svg) and register it.
  async loadMovie(base) {
    const { json, defsDoc } = await fetchMovie(base);
    return this.addMovie(json, base, defsDoc);
  }

  toStage(e) {
    const pt = this.svg.createSVGPoint(); pt.x = e.clientX; pt.y = e.clientY;
    const r = pt.matrixTransform(this.svg.getScreenCTM().inverse());
    return { x: r.x, y: r.y };
  }
  // a stage-coordinate point expressed in an element's own user space (via screen space, so the
  // viewBox scaling cancels out)
  stageToLocal(el, x, y) {
    const pt = this.svg.createSVGPoint(); pt.x = x; pt.y = y;
    const screen = pt.matrixTransform(this.svg.getScreenCTM());
    return screen.matrixTransform(el.getScreenCTM().inverse());
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
  // timeline StartSound tags
  playSound(id, info = {}, movie = this.main) {
    const url = movie.json.sounds[String(id)];
    if (!url || this.muted) return;
    const key = movie.prefix + id;
    if (!this.sounds[key]) { const a = new Audio(movie.base + url); a.preload = 'auto'; this.sounds[key] = a; }
    const a = this.sounds[key];
    if (info.stop) { a.pause(); a.currentTime = 0; return; }
    if (info.noMultiple && !a.paused) return;
    a.loop = (info.loops || 0) > 1;
    a.currentTime = 0;
    a.play().catch(() => { });
  }
  stopAllSounds() { for (const a of Object.values(this.sounds)) { a.pause(); a.currentTime = 0; } }
  // AS2 `new Sound(); attachSound(linkage)`: an object with start/stop/setVolume
  sound(linkage, movie = this.main) {
    const id = movie.json.exports[linkage];
    const url = id !== undefined ? movie.json.sounds[String(id)] : undefined;
    return new SoundObj(this, url ? movie.base + url : null);
  }
}

class SoundObj {
  constructor(player, url) { this.player = player; this.url = url; this.volume = 100; this.playing = []; }
  setVolume(v) { this.volume = v; for (const a of this.playing) a.volume = v / 100; }
  start(offset = 0, loops = 1) {
    if (!this.url || this.player.muted) return;
    const a = new Audio(this.url);
    a.volume = this.volume / 100;
    if (loops > 1) { let n = loops; a.addEventListener('ended', () => { if (--n > 0) { a.currentTime = 0; a.play().catch(() => { }); } }); }
    a.addEventListener('ended', () => { this.playing = this.playing.filter(x => x !== a); });
    this.playing.push(a);
    a.play().catch(() => { });
  }
  stop() { for (const a of this.playing) { a.pause(); a.currentTime = 0; } this.playing = []; }
}

// ---------------------------------------------------------------- display objects

const EMPTY_TIMELINE = { frames: [{}], labels: {}, sounds: {} };
const SCRIPT_DEPTH = 16384;
const MOUSE_EVENTS = ['onPress', 'onRelease', 'onReleaseOutside', 'onRollOver', 'onRollOut'];

export class MovieClip {
  static count = 0;
  constructor(player, parent, charId, timeline, name, depth, movie) {
    this.player = player; this.parent = parent; this.charId = charId;
    this.movie = movie || (parent && parent.movie) || player.main;
    this.timeline = timeline;  // {frames, labels, sounds}
    this._name = name; this.depth = depth;
    this.el = document.createElementNS(NS, 'g');
    this.el.dataset.name = name || '';
    this.children = new Map();   // depth -> child (MovieClip | StaticObj | TextField | Button)
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
    this.handlers = {};
  }

  // ---- AS2-ish properties
  // (once a script sets a transform property the timeline stops driving that clip's matrix, as in Flash)
  // (Flash ignores NaN assignments to these)
  get _x() { return this.x; } set _x(v) { if (!isFinite(v)) return; this.x = v; this.m[4] = v; this.scriptMoved = true; this.writeTransform(); }
  get _y() { return this.y; } set _y(v) { if (!isFinite(v)) return; this.y = v; this.m[5] = v; this.scriptMoved = true; this.writeTransform(); }
  get _xscale() { return this.xscale; } set _xscale(v) { if (!isFinite(v)) return; this.xscale = v; this.scriptMoved = true; this.updateTransform(); }
  get _yscale() { return this.yscale; } set _yscale(v) { if (!isFinite(v)) return; this.yscale = v; this.scriptMoved = true; this.updateTransform(); }
  get _rotation() { return this.rotation; } set _rotation(v) { if (!isFinite(v)) return; this.rotation = v; this.scriptMoved = true; this.updateTransform(); }
  get _visible() { return this.visible; } set _visible(v) { this.visible = !!v; this.el.style.display = this.visible ? '' : 'none'; }
  get _alpha() { return this.alpha; } set _alpha(v) { this.alpha = v; this.el.style.opacity = String(v / 100); }
  get _currentframe() { return this.currentFrame; }
  get _totalframes() { return this.timeline.frames.length; }
  get _parent() { return this.parent; }
  get _width() { return this.bbox().width; }
  get _height() { return this.bbox().height; }
  // mouse position in this clip's own coordinate space
  get _xmouse() { return this.localMouse().x; }
  get _ymouse() { return this.localMouse().y; }
  localMouse() {
    const m = this.player.mouse;
    try { return this.player.stageToLocal(this.el, m.x, m.y); } catch (e) { return m; }
  }
  bbox() { try { return this.el.getBBox(); } catch (e) { return { x: 0, y: 0, width: 0, height: 0 }; } }

  // button-style mouse handlers (onPress/onRelease/onRollOver/...) as in AS2
  setHandler(kind, fn) {
    this.handlers[kind] = fn;
    if (!this.mouseWired) {
      this.mouseWired = true;
      this.el.style.cursor = 'pointer';
      this.el.addEventListener('mousedown', e => { this.pressed = true; this.call('onPress'); e.stopPropagation(); this.player.mouse = this.player.toStage(e); this.player.mouseDown = true; if (this.player.onMouseDown) this.player.onMouseDown(); e.preventDefault(); });
      this.el.addEventListener('mouseup', () => { if (this.pressed) this.call('onRelease'); this.pressed = false; });
      window.addEventListener('mouseup', () => { if (this.pressed) this.call('onReleaseOutside'); this.pressed = false; });
      this.el.addEventListener('mouseenter', () => this.call('onRollOver'));
      this.el.addEventListener('mouseleave', () => this.call('onRollOut'));
    }
  }
  call(kind) { const fn = this.handlers[kind]; if (fn) this.guard(() => fn.call(this)); }

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
    // script changed x/y/scale/rotation: recompose (scripted clips in these games never skew)
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
    const fn = this.player.hooks[this.movie.prefix + key] || (this.movie.prefix ? null : this.player.hooks[key]);
    if (fn) this.guard(() => fn(this));
    const snd = this.timeline.sounds[String(this.currentFrame)];
    if (snd) for (const s of snd) this.player.playSound(s.id, s, this.movie);
  }

  // Reconcile children with the display list of the current frame.
  applyFrame(force) {
    const list = this.timeline.frames[this.currentFrame - 1] || {};
    const seen = new Set();
    for (const [dStr, rec] of Object.entries(list)) {
      const d = Number(dStr);
      seen.add(d);
      let child = this.children.get(d);
      if (child && (child.charId !== rec.id || !!child.isMask !== !!rec.clip)) { this.removeChild(d); child = null; }
      if (!child) {
        child = rec.clip ? new MaskGroup(this, rec, d) : this.createChild(rec.id, rec.name || '', d);
        if (!child) continue;
        child.setMatrix(rec.m);
        if (rec.cx) child.applyCxform(rec.cx);
        if (rec.filters) applyFilters(child.el, rec.filters);
        if (rec.visible === 0) child.el.style.display = 'none';
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
    const mv = this.movie.json;
    const sid = String(id);
    if (mv.sprites[sid]) {
      const c = new MovieClip(this.player, this, id, mv.sprites[sid], name, depth, this.movie);
      c.applyFrame(true);
      return c;
    }
    if (mv.texts[sid]) return new TextField(this.player, this, id, mv.texts[sid], name, depth, this.movie);
    if (mv.buttons[sid]) return new Button(this.player, this, id, mv.buttons[sid], name, depth, this.movie);
    return new StaticObj(this.player, this, id, name, depth, this.movie);
  }

  insertChild(child) {
    this.children.set(child.depth, child);
    if (child._name) this[child._name] = child;
    this.reorder();
  }
  // a mask layer (PlaceObject clipDepth) clips every child between its depth and clipDepth
  containerFor(depth) {
    for (const c of this.children.values()) if (c.isMask && depth > c.depth && depth <= c.clipDepth) return c.el;
    return this.el;
  }
  // keep SVG order by depth, routing masked children into their mask group
  reorder() {
    const list = [...this.children.values()].sort((a, b) => a.depth - b.depth);
    for (const c of list) {
      const container = c.isMask ? this.el : this.containerFor(c.depth);
      if (c.el.parentNode !== container || c.el.nextSibling !== null) container.appendChild(c.el);
    }
  }

  removeChild(d) {
    const c = this.children.get(d);
    if (!c) return;
    this.children.delete(d);
    if (c.isMask) { this.reorder(); }   // its content moves back to the clip itself before the group goes
    c.destroy();
    if (c._name && this[c._name] === c) delete this[c._name];
  }

  destroy() {
    this.dead = true;
    for (const d of [...this.children.keys()]) this.removeChild(d);
    if (this.el.parentNode) this.el.parentNode.removeChild(this.el);
  }

  applyCxform(cx) { applyCxform(this.player, this.el, cx); }
  // AS2 Color.setRGB: tint every pixel to one colour
  setRGB(hex) { this.applyCxform({ mul: [0, 0, 0, 1], add: [(hex >> 16) & 255, (hex >> 8) & 255, hex & 255, 0] }); }

  // ---- AS2 extras used by the games
  // (script-created clips live above the timeline's depths, as in Flash: AS depth d -> internal 16384 + d)
  duplicateMovieClip(newName, depth) {
    depth += SCRIPT_DEPTH;
    if (this.parent.children.has(depth)) this.parent.removeChild(depth);
    const c = new MovieClip(this.player, this.parent, this.charId, this.timeline, newName, depth, this.movie);
    c.scriptCreated = true;
    c.setMatrix(this.m);
    c.applyFrame(true);
    this.parent.insertChild(c);
    c.fireLoad();
    return c;
  }
  // attachMovie(linkageName, instanceName, depth): a library symbol placed by script
  attachMovie(linkage, name, depth) {
    const id = this.movie.json.exports[linkage];
    if (id === undefined) { console.warn('attachMovie: no export', linkage); return undefined; }
    depth += SCRIPT_DEPTH;
    if (this.children.has(depth)) this.removeChild(depth);
    const c = this.createChild(id, name, depth);
    c.scriptCreated = true;
    this.insertChild(c);
    if (c instanceof MovieClip) c.fireLoad();
    return c;
  }
  createEmptyMovieClip(name, depth) {
    depth += SCRIPT_DEPTH;
    if (this.children.has(depth)) this.removeChild(depth);
    const c = new MovieClip(this.player, this, 'empty', EMPTY_TIMELINE, name, depth, this.movie);
    c.scriptCreated = true;
    this.insertChild(c);
    return c;
  }
  getNextHighestDepth() { let d = 0; for (const k of this.children.keys()) if (k >= SCRIPT_DEPTH && k - SCRIPT_DEPTH >= d) d = k - SCRIPT_DEPTH + 1; return d; }
  fireLoad() {
    if (!(this instanceof MovieClip)) return;
    const fn = this.player.loadHooks[this.movie.prefix + this.charId] || (this.movie.prefix ? null : this.player.loadHooks[this.charId]);
    if (fn) fn(this);
  }
  removeMovieClip() { if (this.parent) this.parent.removeChild(this.depth); }
  child(name) { return this[name]; }
  setText(varName, value) { for (const c of this.children.values()) if (c instanceof TextField && c.def.var.endsWith(varName)) c.setText(value); }

  // MovieClipLoader.loadClip: replace this clip's content with another extracted SWF (keeps this clip's transform)
  async loadClip(base) {
    const mv = await this.player.loadMovie(base);
    if (this.dead) return;
    for (const d of [...this.children.keys()]) this.removeChild(d);
    this.movie = mv; this.timeline = mv.json.main; this.currentFrame = 1; this.playing = true;
    this.scriptDone = false; this.justCreated = true;
    this.applyFrame(true);
    if (this.onLoadInit) this.guard(() => this.onLoadInit(this));
    return mv;
  }

  // hitTest(x, y, shapeFlag) with x/y in the parent movie's (stage-level) coordinates, as the games use it
  hitTest(x, y, shape = false) {
    if (!shape) {
      const b = this.bbox(); let p; try { p = this.player.stageToLocal(this.el, x, y); } catch (e) { return false; }
      return p.x >= b.x && p.x <= b.x + b.width && p.y >= b.y && p.y <= b.y + b.height;
    }
    return hitShapes(this.player, this.el, x, y);
  }
}

// Shape-accurate point test: walk every <use> under `el` and test the referenced geometry with
// the point mapped into that geometry's own coordinate space.
function hitShapes(player, el, x, y) {
  for (const use of el.querySelectorAll('use')) {
    if (use.closest('[style*="display: none"]')) continue;
    const href = use.getAttributeNS(XLINK, 'href') || use.getAttribute('href');
    if (!href) continue;
    const def = player.defs.querySelector(href.replace(/[^#\w-]/g, ''));
    if (!def) continue;
    let local; try { local = player.stageToLocal(use, x, y); } catch (e) { continue; }
    if (hitGeometry(player, def, local)) return true;
  }
  return false;
}
function hitGeometry(player, node, local) {
  const nodes = node.matches('path,rect,circle,ellipse,polygon,image') ? [node] : node.querySelectorAll('path,rect,circle,ellipse,polygon,image,use');
  for (const g of nodes) {
    // compose the transforms between `node` and the geometry
    let m = player.svg.createSVGMatrix(); let e = g;
    const chain = []; while (e && e !== node) { chain.unshift(e); e = e.parentNode; }
    for (const c of chain) { const t = c.transform && c.transform.baseVal.consolidate(); if (t) m = m.multiply(t.matrix); }
    const p = local.matrixTransform(m.inverse());
    if (g.tagName === 'use') {
      const href = g.getAttributeNS(XLINK, 'href') || g.getAttribute('href');
      const def = href && player.defs.querySelector(href.replace(/[^#\w-]/g, ''));
      if (def && hitGeometry(player, def, p)) return true;
      continue;
    }
    if (g.tagName === 'image') {
      const x = +g.getAttribute('x') || 0, y = +g.getAttribute('y') || 0, w = +g.getAttribute('width'), h = +g.getAttribute('height');
      if (p.x >= x && p.x <= x + w && p.y >= y && p.y <= y + h) return true;
      continue;
    }
    if (g.getAttribute('fill') === 'none') continue;
    try { if (g.isPointInFill(p)) return true; } catch (e) { /* not geometry */ }
  }
  return false;
}

// A mask layer: a <g clip-path> that the masked siblings are rendered inside.
class MaskGroup {
  static seq = 0;
  constructor(clip, rec, depth) {
    this.player = clip.player; this.parent = clip; this.charId = rec.id; this.depth = depth; this.clipDepth = rec.clip; this._name = '';
    this.isMask = true;
    this.id = 'mask' + (++MaskGroup.seq);
    this.cp = document.createElementNS(NS, 'clipPath');
    this.cp.setAttribute('id', this.id);
    // (a clipPath may only hold shapes, not <use>/<g>: copy the mask character's geometry in)
    const def = this.player.defs.querySelector(clip.movie.ref(rec.id).replace(/[^#\w-]/g, ''));
    this.shapes = [];
    if (def) {
      const geoms = def.matches('path,rect,circle,ellipse,polygon') ? [def] : def.querySelectorAll('path,rect,circle,ellipse,polygon');
      for (const g of geoms) {
        const c = g.cloneNode(false);
        c.removeAttribute('id'); c.removeAttribute('fill'); c.removeAttribute('stroke');
        let t = ''; let e = g;
        while (e && e !== def.parentNode) { const tr = e.getAttribute('transform'); if (tr) t = tr + ' ' + t; e = e.parentNode; }
        c.dataset.t = t.trim();
        this.cp.appendChild(c); this.shapes.push(c);
      }
    }
    this.player.defs.appendChild(this.cp);
    this.el = document.createElementNS(NS, 'g');
    this.el.setAttribute('clip-path', `url(#${this.id})`);
  }
  setMatrix(m) { const mt = `matrix(${m.map(fmt).join(' ')})`; for (const c of this.shapes) c.setAttribute('transform', (mt + ' ' + c.dataset.t).trim()); }
  applyCxform() { }
  destroy() { if (this.el.parentNode) this.el.parentNode.removeChild(this.el); if (this.cp.parentNode) this.cp.parentNode.removeChild(this.cp); }
}

class StaticObj {
  constructor(player, parent, id, name, depth, movie) {
    this.player = player; this.parent = parent; this.charId = id; this._name = name; this.depth = depth;
    this.el = document.createElementNS(NS, 'use');
    this.el.setAttributeNS(XLINK, 'xlink:href', movie.ref(id));
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
    player.defs.appendChild(f);
  }
  el.setAttribute('filter', `url(#${id})`);
}

// PlaceObject3 filters, approximated with CSS filters (a subtle drop shadow / glow is all the games use)
function applyFilters(el, names) {
  const parts = [];
  for (const n of names) {
    if (n === 'dropShadow') parts.push('drop-shadow(1.5px 1.5px 0 rgba(0,0,0,.6))');
    else if (n === 'glow') parts.push('drop-shadow(0 0 3px rgba(255,255,255,.9))');
  }
  if (parts.length) el.style.filter = parts.join(' ');
}

class TextField {
  constructor(player, parent, id, def, name, depth, movie) {
    this.player = player; this.parent = parent; this.charId = id; this.def = def; this._name = name; this.depth = depth; this.movie = movie;
    this.el = document.createElementNS(NS, 'g');
    this.el.style.pointerEvents = 'none';   // dynamic text never takes the mouse from what's beneath it
    this.varName = def.var ? def.var.split('.').pop() : '';
    const bound = this.varName && player.textVars[this.varName];
    this.setText(bound !== undefined && bound !== false ? bound : def.text !== undefined ? def.text : '');
  }
  get text() { return this.value; }
  set text(v) { this.setText(v); }
  setMatrix(m) { this.el.setAttribute('transform', `matrix(${m.map(fmt).join(' ')})`); }
  applyCxform() { }
  destroy() { if (this.el.parentNode) this.el.parentNode.removeChild(this.el); }
  setText(value) {
    const t = this.def;
    this.value = value;
    while (this.el.firstChild) this.el.removeChild(this.el.firstChild);
    let text = String(value === undefined || value === null ? '' : value).replace(/\r\n?/g, '\n');
    if (t.html) text = text.replace(/<br\s*\/?>/gi, '\n').replace(/<[^>]+>/g, '').replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>');
    const font = this.movie.json.fonts[String(t.font)];
    const size = t.size || 15;
    const [l, top, r, bottom] = t.bounds;
    const color = t.color || '#000';
    if (!font || !font.glyphs.length) {
      let y = top + size;
      for (const line of text.split('\n')) {
        const te = document.createElementNS(NS, 'text');
        te.setAttribute('x', fmt(t.align === 'center' ? (l + r) / 2 : t.align === 'right' ? r - 2 : l + 2)); te.setAttribute('y', fmt(y));
        te.setAttribute('text-anchor', t.align === 'center' ? 'middle' : t.align === 'right' ? 'end' : 'start');
        te.setAttribute('font-size', size); te.setAttribute('font-family', 'Arial, sans-serif'); te.setAttribute('fill', color);
        te.textContent = line;
        this.el.appendChild(te);
        y += size * 1.2;
      }
      return;
    }
    // embedded font: glyph uses laid out with the font's advance table; word-wrap when the field asks for it
    const adv = ch => (font.advances[String(ch.charCodeAt(0))] || (ch === ' ' ? 0.3 : 0.5)) * size;
    const width = s => [...s].reduce((w, ch) => w + adv(ch), 0);
    const maxW = r - l - 4;
    const lines = [];
    for (const para of text.split('\n')) {
      if (!t.wordWrap || width(para) <= maxW) { lines.push(para); continue; }
      let cur = '';
      for (const word of para.split(' ')) {
        const next = cur ? cur + ' ' + word : word;
        if (width(next) > maxW && cur) { lines.push(cur); cur = word; } else cur = next;
      }
      lines.push(cur);
    }
    const lineH = size * (font.ascent + font.descent || 1.15) + (t.leading || 0);
    let y = top + 2 + font.ascent * size;
    for (const line of lines) {
      let x = l + 2;
      const w = width(line);
      if (t.align === 'center') x = l + (r - l - w) / 2;
      else if (t.align === 'right') x = r - 2 - w;
      for (const ch of line) {
        const c = ch.charCodeAt(0);
        if (c > 32) {
          const u = document.createElementNS(NS, 'use');
          u.setAttributeNS(XLINK, 'xlink:href', `#${this.movie.prefix}font_${t.font}_${c}`);
          u.setAttribute('transform', `translate(${fmt(x)} ${fmt(y)}) scale(${fmt(size)})`);
          u.setAttribute('fill', color);
          this.el.appendChild(u);
        }
        x += adv(ch);
      }
      y += lineH;
    }
  }
}

class Button {
  constructor(player, parent, id, def, name, depth, movie) {
    this.player = player; this.parent = parent; this.charId = id; this.def = def; this._name = name; this.depth = depth; this.movie = movie;
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
      const mv = this.movie.json;
      let node;
      if (mv.sprites[String(r.id)]) {
        const c = new MovieClip(this.player, null, r.id, mv.sprites[String(r.id)], '', r.depth, this.movie); c.applyFrame(true); node = c.el; c.setMatrix(r.m);
        this._clips = this._clips || []; this._clips.push(c);
      } else {
        node = document.createElementNS(NS, 'use');
        node.setAttributeNS(XLINK, 'xlink:href', this.movie.ref(r.id));
        node.setAttribute('transform', `matrix(${r.m.map(fmt).join(' ')})`);
      }
      g.appendChild(node);
    }
    return g;
  }
  show(state) { for (const [k, g] of Object.entries(this.states)) g.style.display = k === state ? '' : 'none'; }
  fire(kind) { const h = this.player.buttonHandlers[this.movie.prefix + this.charId] || (this.movie.prefix ? null : this.player.buttonHandlers[this.charId]); if (h) h(this, kind); }
  setMatrix(m) { this.el.setAttribute('transform', `matrix(${m.map(fmt).join(' ')})`); }
  applyCxform(cx) { applyCxform(this.player, this.el, cx); }   // (an alpha-0 button is invisible but still clickable)
  destroy() { if (this.el.parentNode) this.el.parentNode.removeChild(this.el); }
}

function fmt(n) { return Number.isInteger(n) ? String(n) : n.toFixed(3); }

async function fetchMovie(base) {
  const [json, defsText] = await Promise.all([
    fetch(base + 'movie.json').then(r => r.json()),
    fetch(base + 'defs.svg').then(r => r.text()),
  ]);
  return { json, defsDoc: new DOMParser().parseFromString(defsText, 'image/svg+xml') };
}

export async function loadPlayer(svgEl, base = '../assets/') {
  const { json, defsDoc } = await fetchMovie(base);
  return new Player(svgEl, json, defsDoc, base);
}
