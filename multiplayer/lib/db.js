// SQLite store. Everything here is ephemeral (per container lifetime): sessions, matches and an
// append-only event log that stands in for a message queue. node:sqlite is built into Node.
import { DatabaseSync } from 'node:sqlite';

const SCHEMA = `
CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  name TEXT,
  created_at INTEGER NOT NULL,
  last_seen INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS matches (
  id TEXT PRIMARY KEY,
  game TEXT NOT NULL,
  titan_session TEXT,
  villain_session TEXT,
  side_claimed_by TEXT,
  titan_fighter INTEGER,
  villain_fighter INTEGER,
  seed INTEGER,
  input_delay INTEGER,
  state TEXT NOT NULL,
  winner TEXT,
  reason TEXT,
  titan_wins INTEGER DEFAULT 0,
  villain_wins INTEGER DEFAULT 0,
  rematch_of TEXT,
  created_at INTEGER NOT NULL,
  started_at INTEGER,
  ended_at INTEGER
);
CREATE TABLE IF NOT EXISTS events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  at INTEGER NOT NULL,
  session_id TEXT,
  match_id TEXT,
  type TEXT NOT NULL,
  data TEXT
);
CREATE INDEX IF NOT EXISTS events_match ON events(match_id, id);
`;

export function openDb(path = ':memory:') {
  const db = new DatabaseSync(path);
  db.exec('PRAGMA journal_mode=MEMORY; PRAGMA synchronous=OFF;');
  db.exec(SCHEMA);
  const st = {
    insSession: db.prepare('INSERT INTO sessions (id, name, created_at, last_seen) VALUES (?, ?, ?, ?)'),
    getSession: db.prepare('SELECT * FROM sessions WHERE id = ?'),
    touchSession: db.prepare('UPDATE sessions SET last_seen = ?, name = COALESCE(?, name) WHERE id = ?'),
    insMatch: db.prepare(`INSERT INTO matches (id, game, state, seed, input_delay, rematch_of, created_at)
                          VALUES (?, ?, ?, ?, ?, ?, ?)`),
    updMatch: db.prepare(`UPDATE matches SET titan_session=?, villain_session=?, side_claimed_by=?, titan_fighter=?,
                          villain_fighter=?, seed=?, input_delay=?, state=?, winner=?, reason=?, titan_wins=?,
                          villain_wins=?, started_at=?, ended_at=? WHERE id=?`),
    getMatch: db.prepare('SELECT * FROM matches WHERE id = ?'),
    insEvent: db.prepare('INSERT INTO events (at, session_id, match_id, type, data) VALUES (?, ?, ?, ?, ?)'),
    eventsFor: db.prepare('SELECT id, at, session_id, match_id, type, data FROM events WHERE match_id = ? ORDER BY id'),
  };
  return {
    raw: db,
    createSession(id, name, now) { st.insSession.run(id, name ?? null, now, now); },
    getSession(id) { return st.getSession.get(id) ?? null; },
    touchSession(id, now, name) { st.touchSession.run(now, name ?? null, id); },
    createMatch(m, now) { st.insMatch.run(m.id, m.game, m.state, m.seed, m.delay, m.rematchOf ?? null, now); },
    saveMatch(m) {
      st.updMatch.run(m.sides.titan, m.sides.villain, m.claimedBy, m.fighters.titan, m.fighters.villain, m.seed,
        m.delay, m.state, m.winner, m.reason, m.wins.titan, m.wins.villain, m.startedAt, m.endedAt, m.id);
    },
    getMatch(id) { return st.getMatch.get(id) ?? null; },
    event(type, { session = null, match = null, data = null } = {}, now = Date.now()) {
      st.insEvent.run(now, session, match, type, data === null ? null : JSON.stringify(data));
    },
    eventsFor(matchId) {
      return st.eventsFor.all(matchId).map(r => ({ ...r, data: r.data === null ? null : JSON.parse(r.data) }));
    },
    close() { db.close(); },
  };
}
