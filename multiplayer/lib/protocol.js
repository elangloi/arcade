// Wire protocol: JSON messages `{ t: <type>, ...fields }` over one WebSocket per session.
// Client -> server types are validated here before the lobby sees them.

export const FIGHTERS = {
  1: 'robin', 2: 'raven', 3: 'cyborg', 4: 'starfire', 5: 'beastboy',
  6: 'jinx', 7: 'gizmo', 8: 'mammoth', 9: 'cinderblock', 10: 'plasmus',
};
export const TITANS = [1, 2, 3, 4, 5];
export const VILLAINS = [6, 7, 8, 9, 10];
export const sideOf = f => (f >= 1 && f <= 5 ? 'titan' : f >= 6 && f <= 10 ? 'villain' : null);
export const other = side => (side === 'titan' ? 'villain' : 'titan');

const isInt = (v, min = -Infinity, max = Infinity) => Number.isInteger(v) && v >= min && v <= max;
const isStr = (v, max = 200) => typeof v === 'string' && v.length <= max;

export function cleanName(v) {
  if (typeof v !== 'string') return null;
  // eslint-disable-next-line no-control-regex
  const s = v.replace(/[\x00-\x1f\x7f]/g, '').trim().slice(0, 16);
  return s.length ? s : null;
}

// Each validator returns an error string or null.
const V = {
  hello: m => (m.name !== undefined && !isStr(m.name, 64) ? 'bad name' : m.match !== undefined && !isStr(m.match, 64) ? 'bad match' : null),
  queue: m => (m.game !== undefined && m.game !== 'battleblitz' ? 'unknown game' : null),
  pick: m => (isInt(m.fighter, 1, 10) ? null : 'bad fighter'),
  lock: m => (m.fighter !== undefined && !isInt(m.fighter, 1, 10) ? 'bad fighter' : null),
  ready: () => null,
  in: m => {
    if (!isInt(m.f, 0, 1e9)) return 'bad frame';
    if (!Array.isArray(m.e) || m.e.length > 64) return 'bad events';
    for (const ev of m.e) {
      if (!Array.isArray(ev) || ev.length !== 3 || !isInt(ev[0], 0, 255) || !isInt(ev[1], 0, 1) || !isInt(ev[2], 0, 2 ** 45)) return 'bad event';
    }
    return null;
  },
  sum: m => (isInt(m.f, 0, 1e9) && isInt(m.h, 0, 2 ** 32) ? null : 'bad sum'),
  resume: m => (isInt(m.have, -1, 1e9) ? null : 'bad resume'),
  end: m => (
    (m.winner === 'titan' || m.winner === 'villain' || m.winner === null) && isInt(m.titanWins, 0, 3) && isInt(m.villainWins, 0, 3)
      ? null : 'bad end'),
  rematch: m => (typeof m.yes === 'boolean' ? null : 'bad rematch'),
  leave: () => null,
  away: m => (typeof m.hidden === 'boolean' ? null : 'bad away'),
  ping: m => (typeof m.ts === 'number' ? null : 'bad ping'),
};

export const CLIENT_TYPES = Object.keys(V);

export function parseClientMessage(raw) {
  let m;
  try { m = JSON.parse(raw); } catch { return { error: 'not json' }; }
  if (!m || typeof m !== 'object' || typeof m.t !== 'string') return { error: 'no type' };
  const v = V[m.t];
  if (!v) return { error: 'unknown type ' + m.t };
  const err = v(m);
  return err ? { error: err } : { msg: m };
}
