// Runtime configuration, all from the environment (compose sets the container values).
const env = (k, d) => (process.env[k] !== undefined && process.env[k] !== '' ? process.env[k] : d);
const int = (k, d) => Number.parseInt(env(k, d), 10);

export const config = {
  port: int('PORT', 8766),
  host: env('HOST', '0.0.0.0'),
  basePath: env('BASE_PATH', '/arcade/multiplayer').replace(/\/+$/, ''),   // prefix the proxy keeps in front of us
  dbPath: env('DB_PATH', '/tmp/arcade.db'),
  assetsDir: env('ASSETS_DIR', 'games/battleblitz/assets'),               // Battle Blitz art + sound (copied in at build time)
  navDir: env('NAV_DIR', 'nav'),                                           // the arcade-wide nav bar script (copied in at build time)
  dev: env('DEV', '') === '1',
  logInputs: env('LOG_INPUTS', '') === '1',
  allowedOrigins: env('ALLOWED_ORIGINS', '').split(',').map(s => s.trim()).filter(Boolean),
  game: {
    inputDelay: int('INPUT_DELAY', 3),              // frames of input latency when the RTT is unknown
    difficulty: int('MP_DIFFICULTY', 1),            // health table row: 1 = the original's beginner tier
  },
  timers: {
    pickTimeoutMs: int('PICK_TIMEOUT_MS', 120_000),
    reconnectGraceMs: int('RECONNECT_GRACE_MS', 20_000),
    readyTimeoutMs: int('READY_TIMEOUT_MS', 90_000),
    stallForfeitMs: int('STALL_FORFEIT_MS', 45_000),
    matchIdleMs: int('MATCH_IDLE_MS', 600_000),
    rematchTimeoutMs: int('REMATCH_TIMEOUT_MS', 60_000),
    endTimeoutMs: int('END_TIMEOUT_MS', 10_000),
  },
};
