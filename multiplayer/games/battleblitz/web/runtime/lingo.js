// Lingo value semantics for the transpiled game code: 1-based lists, property lists,
// points/rects with operator helpers, and the built-in functions the game uses.

export const G = { g: undefined };   // Lingo globals live here (G.g, G.main, ...)

// ---------------------------------------------------------------- objects

export class LingoObject {
  handler(name) { return typeof this[name] === 'function' ? 1 : 0; }
  getaProp(name) { return this[name]; }
  setaProp(name, v) { this[name] = v; }
}

export class Behavior extends LingoObject {
  constructor() { super(); this.spriteNum = 0; }
}

// ---------------------------------------------------------------- lists

export class LList {
  constructor(items) { this.items = items || []; }
  get count() { return this.items.length; }
  at(i) { return this.items[i - 1]; }
  setAt(i, v) {
    if (i > this.items.length) { while (this.items.length < i - 1) this.items.push(undefined); this.items.push(v); }
    else this.items[i - 1] = v;
  }
  getAt(i) { return this.at(i); }
  append(v) { this.items.push(v); return this; }
  add(v) { this.items.push(v); return this; }
  addAt(i, v) { this.items.splice(i - 1, 0, v); }
  deleteAt(i) { this.items.splice(i - 1, 1); }
  deleteOne(v) { const i = this.getPos(v); if (i) this.deleteAt(i); }
  getPos(v) { for (let i = 0; i < this.items.length; i++) if (_eq(this.items[i], v)) return i + 1; return 0; }
  findPos(v) { return this.getPos(v); }
  getOne(v) { return this.getPos(v); }
  getLast() { return this.items[this.items.length - 1]; }
  duplicate() { return new LList(this.items.map(x => (x instanceof LList || x instanceof PropList || x instanceof Point || x instanceof Rect) ? x.duplicate() : x)); }
  sort() { this.items.sort((a, b) => (a < b ? -1 : a > b ? 1 : 0)); }
  [Symbol.iterator]() { return this.items[Symbol.iterator](); }
  toString() { return '[' + this.items.map(_str).join(', ') + ']'; }
}
export const L = (...items) => new LList(items);

export class PropList {
  constructor(pairs) {
    Object.defineProperty(this, '_keys', { value: [], enumerable: false, writable: true });
    Object.defineProperty(this, '_objmap', { value: new Map(), enumerable: false, writable: true });
    if (pairs) for (const [k, v] of pairs) this.addProp(k, v);
  }
  _isObjKey(k) { return typeof k === 'object' && k !== null; }
  addProp(k, v) {
    if (this._isObjKey(k)) { this._objmap.set(k, v); return; }
    if (!(k in this)) this._keys.push(k);
    this[k] = v;
  }
  setaProp(k, v) { this.addProp(k, v); }
  setProp(k, v) { this.addProp(k, v); }
  getaProp(k) { return this._isObjKey(k) ? this._objmap.get(k) : this[k]; }
  getProp(k) { return this.getaProp(k); }
  at(k) { return this.getaProp(k); }
  setAt(k, v) { this.addProp(k, v); }
  deleteProp(k) {
    if (this._isObjKey(k)) { this._objmap.delete(k); return; }
    const i = this._keys.indexOf(k); if (i >= 0) this._keys.splice(i, 1); delete this[k];
  }
  getPropAt(i) { return this._keys[i - 1]; }
  get count() { return this._keys.length + this._objmap.size; }
  findPos(k) { const i = this._keys.indexOf(k); return i < 0 ? 0 : i + 1; }
  duplicate() { const p = new PropList(); for (const k of this._keys) p.addProp(k, this[k]); return p; }
  [Symbol.iterator]() { return this._keys.map(k => this[k])[Symbol.iterator](); }
}
export const PL = (pairs) => new PropList(pairs);

// ---------------------------------------------------------------- point / rect

export class Point {
  constructor(h, v) { this.locH = h; this.locV = v; }
  duplicate() { return new Point(this.locH, this.locV); }
  inside(r) { return (this.locH >= r.left && this.locH < r.right && this.locV >= r.top && this.locV < r.bottom) ? 1 : 0; }
  toString() { return `point(${this.locH}, ${this.locV})`; }
}
export class Rect {
  constructor(l, t, r, b) { this.left = l; this.top = t; this.right = r; this.bottom = b; }
  get width() { return this.right - this.left; }
  get height() { return this.bottom - this.top; }
  duplicate() { return new Rect(this.left, this.top, this.right, this.bottom); }
  offset(x, y) { return new Rect(this.left + x, this.top + y, this.right + x, this.bottom + y); }
  inflate(x, y) { return new Rect(this.left - x, this.top - y, this.right + x, this.bottom + y); }
  map(fromRect, toRect) {
    const sx = fromRect.width ? toRect.width / fromRect.width : 1, sy = fromRect.height ? toRect.height / fromRect.height : 1;
    return new Rect(toRect.left + (this.left - fromRect.left) * sx, toRect.top + (this.top - fromRect.top) * sy,
      toRect.left + (this.right - fromRect.left) * sx, toRect.top + (this.bottom - fromRect.top) * sy);
  }
  intersect(o) {
    const l = Math.max(this.left, o.left), t = Math.max(this.top, o.top);
    const r = Math.min(this.right, o.right), b = Math.min(this.bottom, o.bottom);
    if (r <= l || b <= t) return new Rect(0, 0, 0, 0);
    return new Rect(l, t, r, b);
  }
  union(o) { return new Rect(Math.min(this.left, o.left), Math.min(this.top, o.top), Math.max(this.right, o.right), Math.max(this.bottom, o.bottom)); }
  inside(o) { return (this.left >= o.left && this.top >= o.top && this.right <= o.right && this.bottom <= o.bottom) ? 1 : 0; }
  toString() { return `rect(${this.left}, ${this.top}, ${this.right}, ${this.bottom})`; }
}
export function point(h, v) { return new Point(h, v); }
export function rect(a, b, c, d) {
  if (a instanceof Point) return new Rect(a.locH, a.locV, b.locH, b.locV);
  return new Rect(a, b, c, d);
}

// ---------------------------------------------------------------- operators

export function _truthy(v) {
  if (v === undefined || v === null || v === 0 || v === false) return false;
  if (typeof v === 'number') return v !== 0;
  return true;
}
export function _eq(a, b) {
  if (a === b) return true;
  if (a === undefined || a === null) return b === undefined || b === null;
  if (b === undefined || b === null) return false;
  if (a instanceof Point && b instanceof Point) return a.locH === b.locH && a.locV === b.locV;
  if (a instanceof Rect && b instanceof Rect) return a.left === b.left && a.top === b.top && a.right === b.right && a.bottom === b.bottom;
  if (a instanceof LList && b instanceof LList) {
    if (a.count !== b.count) return false;
    for (let i = 0; i < a.count; i++) if (!_eq(a.items[i], b.items[i])) return false;
    return true;
  }
  if (typeof a === 'string' && typeof b === 'string') return a.toLowerCase() === b.toLowerCase();
  if (a && b && a.isMember && b.isMember) return a.castLib === b.castLib && a.number === b.number;
  return false;
}
export function _add(a, b) {
  if (typeof a === 'number' && typeof b === 'number') return a + b;
  if (a instanceof Point) return b instanceof Point ? new Point(a.locH + b.locH, a.locV + b.locV) : new Point(a.locH + b, a.locV + b);
  if (a instanceof Rect) return b instanceof Rect ? new Rect(a.left + b.left, a.top + b.top, a.right + b.right, a.bottom + b.bottom) : new Rect(a.left + b, a.top + b, a.right + b, a.bottom + b);
  if (typeof a === 'string' || typeof b === 'string') return Number(a) + Number(b);
  return (a || 0) + (b || 0);
}
export function _sub(a, b) {
  if (typeof a === 'number' && typeof b === 'number') return a - b;
  if (a instanceof Point) return b instanceof Point ? new Point(a.locH - b.locH, a.locV - b.locV) : new Point(a.locH - b, a.locV - b);
  if (a instanceof Rect) return b instanceof Rect ? new Rect(a.left - b.left, a.top - b.top, a.right - b.right, a.bottom - b.bottom) : new Rect(a.left - b, a.top - b, a.right - b, a.bottom - b);
  return (a || 0) - (b || 0);
}
export function _mul(a, b) {
  if (typeof a === 'number' && typeof b === 'number') return a * b;
  if (a instanceof Point) return b instanceof Point ? new Point(a.locH * b.locH, a.locV * b.locV) : new Point(a.locH * b, a.locV * b);
  if (b instanceof Point) return new Point(b.locH * a, b.locV * a);
  if (a instanceof Rect) return new Rect(a.left * b, a.top * b, a.right * b, a.bottom * b);
  return (a || 0) * (b || 0);
}
// Lingo integer division truncates; float division when either operand is a float.
// We cannot see Lingo's static types, so integral JS numbers are treated as ints
// unless the transpiler proved a float operand (then _fdiv is emitted).
export function _idiv(a, b) { return b === 0 ? 0 : Math.trunc(a / b); }
export function _fdiv(a, b) {
  if (a instanceof Point) return b instanceof Point ? new Point(a.locH / b.locH, a.locV / b.locV) : new Point(a.locH / b, a.locV / b);
  if (a instanceof Rect) return new Rect(a.left / b, a.top / b, a.right / b, a.bottom / b);
  return b === 0 ? 0 : a / b;
}
export function _div(a, b) {
  if (typeof a === 'number' && typeof b === 'number') {
    if (Number.isInteger(a) && Number.isInteger(b)) return _idiv(a, b);
    return b === 0 ? 0 : a / b;
  }
  return _fdiv(a, b);
}
export function _mod(a, b) { return b === 0 ? 0 : (Number.isInteger(a) && Number.isInteger(b) ? a % b : a % b); }
export function _neg(a) {
  if (a instanceof Point) return new Point(-a.locH, -a.locV);
  return -a;
}
export function _str(v) {
  if (v === undefined || v === null) return '';
  if (typeof v === 'number') return Number.isInteger(v) ? String(v) : v.toFixed(4);
  return String(v);
}
export function _contains(a, b) { return String(a).toLowerCase().includes(String(b).toLowerCase()) ? 1 : 0; }
export function _starts(a, b) { return String(a).toLowerCase().startsWith(String(b).toLowerCase()) ? 1 : 0; }
export function _getAt(obj, i) {
  if (obj instanceof LList || obj instanceof PropList) return obj.at(i);
  if (typeof obj === 'string') return obj[i - 1];
  if (obj && typeof obj === 'object') return obj[i];
  return undefined;
}
export function _setAt(obj, i, v) {
  if (obj instanceof LList || obj instanceof PropList) obj.setAt(i, v);
  else obj[i] = v;
}
export function _new(cls, ...args) {
  if (typeof cls === 'string') return G.newMember(cls, ...args);   // new(#bitmap, castLib(...))
  if (typeof cls !== 'function') throw new Error('new() of non-class: ' + cls);
  return new cls(...args);
}
export function _iter(lst) {
  if (lst instanceof LList) return lst.items.slice();
  if (lst instanceof PropList) return [...lst];
  return lst || [];
}
export function _caseKey(v) {
  if (v && v.isMember) return 'member:' + v.castLib + ':' + v.number;
  if (typeof v === 'string') return v.toLowerCase();
  return v;
}

// ---------------------------------------------------------------- builtins

// random() can be seeded (multiplayer runs both machines from the same seed).
let rng = Math.random;
export function setRandomSource(fn) { rng = fn || Math.random; }
export function random(n) { return Math.floor(rng() * n) + 1; }
export function integer(x) {
  if (typeof x !== 'number') x = Number(x) || 0;
  // Lingo rounds half away from zero
  return x < 0 ? -Math.round(-x) : Math.round(x);
}
export function float(x) { return typeof x === 'number' ? x : Number(x) || 0; }
export function string(x) { return _str(x); }
export function symbol(x) { return String(x); }
export const abs = Math.abs, sqrt = Math.sqrt, cos = Math.cos, sin = Math.sin, atan = Math.atan;
export function power(a, b) { return Math.pow(a, b); }
export function min(...a) { return Math.min(...a); }
export function max(...a) { return Math.max(...a); }
export function bitOr(a, b) { return (a | b) >>> 0; }
export function bitAnd(a, b) { return (a & b) >>> 0; }
export function bitNot(a) { return (~a) >>> 0; }
export function bitXor(a, b) { return (a ^ b); }
export function voidp(x) { return (x === undefined || x === null) ? 1 : 0; }
export function objectp(x) { return (x !== undefined && x !== null && typeof x === 'object' && !(x instanceof Point) && !(x instanceof Rect)) ? 1 : 0; }
export function listp(x) { return (x instanceof LList || x instanceof PropList) ? 1 : 0; }
export function integerp(x) { return (typeof x === 'number' && Number.isInteger(x)) ? 1 : 0; }
export function floatp(x) { return (typeof x === 'number' && !Number.isInteger(x)) ? 1 : 0; }
export function stringp(x) { return typeof x === 'string' ? 1 : 0; }
export function symbolp(x) { return typeof x === 'string' ? 1 : 0; }
export function ilk(x) {
  if (x instanceof Point) return 'point';
  if (x instanceof Rect) return 'rect';
  if (x instanceof LList) return 'list';
  if (x instanceof PropList) return 'propList';
  if (typeof x === 'number') return Number.isInteger(x) ? 'integer' : 'float';
  if (typeof x === 'string') return 'string';
  if (x === undefined || x === null) return 'void';
  return 'object';
}
export function value(s) { const n = Number(s); return Number.isNaN(n) ? 0 : n; }
export function chars(s, a, b) { return String(s).substring(a - 1, b); }
export function offset(needle, hay) { const i = String(hay).toLowerCase().indexOf(String(needle).toLowerCase()); return i < 0 ? 0 : i + 1; }
export function length(s) { return String(s).length; }
export function charToNum(c) { return String(c).charCodeAt(0); }
export function numToChar(n) { return String.fromCharCode(n); }
export function duplicate(x) { return x && x.duplicate ? x.duplicate() : x; }
