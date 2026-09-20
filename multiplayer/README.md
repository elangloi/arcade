# multiplayer — the online arcade

One Node service behind `/arcade/multiplayer/`: the multiplayer landing page, the lobby, a JSON
API, a matchmaking + lockstep WebSocket, a SQLite event log, and the game itself — a **fork** of
[`battleblitz/web`](../battleblitz/web) wired for two players. The single-player cabinet in
`battleblitz/` is not touched by anything in here; its 39 MB of art and sound is copied into this
image at build time instead of being duplicated in git.

```
server.js                 binds lib/app.js to a port
lib/app.js                HTTP routes, static mounts, WebSocket upgrade, ping/RTT
lib/lobby.js              sessions, FIFO queue, match state machine, timers (pure logic, tested)
lib/protocol.js           message validation + fighter tables
lib/db.js                 node:sqlite: sessions, matches, events
lib/static.js             tiny static server
web/                      landing (index.html), lobby (lobby.html + lobby.js), style.css, fonts
games/battleblitz/web/    the forked game: main.js, mp.js (lockstep client), runtime/, game/
games/battleblitz/assets/ not in git — COPY'd from battleblitz/assets by the Dockerfile,
                          served from ASSETS_DIR (../battleblitz/assets) in dev
test/                     node --test: lobby state machine + a two-socket integration test
```

## Run it

```bash
npm --prefix multiplayer install          # once (only dependency: ws)
npm --prefix multiplayer run dev          # http://localhost:8766/arcade/multiplayer/
npm --prefix multiplayer test
```

Open the lobby in two tabs (or two machines on the LAN), enter names, and the first two players
in the queue are matched. In the compose stack it's built from the repo root:
`docker build -f multiplayer/Dockerfile .`

## How a match works

1. Tab opens → `POST api/session` → a UUID for this browser tab (kept in `sessionStorage`).
2. Name → `hello` + `queue`. Two queued sessions become a match in state `picking`.
3. **Both players see both rosters.** The first `pick` claims that fighter's side (Titans for 1–5,
   villains for 6–10) and locks the opponent into the other side; later picks outside your side are
   refused (`wrong_side`). Picks mirror live; `lock` from both → `fight`.
4. Both tabs navigate to `games/battleblitz/web/?match=&session=`. The game jumps straight to the
   versus screen, loads, and sends `ready`. When both are ready the server sends `start`.
5. **Deterministic lockstep.** Both browsers run the full game as "titan vs villain" (identical
   simulation); only key events cross the wire. Each frame's local key events are stamped with
   `frame + delay` (delay 2–6 frames, chosen from the lobby RTT) and relayed verbatim; a client only
   advances frame *f* once it holds the opponent's packet for *f*. Every 30 frames both send a state
   checksum; a mismatch voids the match (`desync`). `random()` is seeded from the match seed.
6. Best-of-3 ends → `end` from both (must agree) → `result`. **Rematch** (both say yes) keeps sides
   and fighters with a new seed; otherwise back to the lobby. Esc leaves (forfeit while playing).
7. Closing the tab gives a 20 s grace period to reconnect (`resume` replays missing packets); after
   that it's a forfeit. A tab that stops sending while behind the other for 45 s forfeits.

Everything is logged to the `events` table (`GET api/events?match=` in dev); `LOG_INPUTS=1` also
dumps each match's input streams at the end.

## Protocol (JSON over `/ws?session=`)

| C → S | S → C |
|-------|-------|
| `hello{name?}` | `welcome{session,name,state,match?}` |
| `queue` / `leave` | `queued{position}` / `matched{matchId,opponent}` / `opponent_left` |
| `pick{fighter}` / `lock{fighter?}` | `sides{titan,villain,claimedBy}` / `picked` / `locked` / `fight{matchId,side,titan,villain,seed,delay,…}` |
| `ready` | `start{delay,seed}` |
| `in{f,e:[[key,down,ts]…]}` / `sum{f,h}` / `resume{have}` | `in` (relayed) / `resume_ack{have}` / `result{winner,reason:ko\|forfeit\|desync}` |
| `end{winner,titanWins,villainWins}` / `rematch{yes}` | `rematch_pending` / `rematch_declined` / `fight` |
| `away{hidden}` / `ping{ts}` | `opponent_away{hidden}` / `pong` / `error{code,msg}` |

## Environment

`PORT` (8766 dev / 80 image) · `BASE_PATH` (`/arcade/multiplayer`) · `DB_PATH` (`/tmp/arcade.db`;
`:memory:` in dev) · `ASSETS_DIR` · `INPUT_DELAY` (3) · `MP_DIFFICULTY` (1) · `LOG_INPUTS` ·
`PICK_TIMEOUT_MS` (120 s) · `RECONNECT_GRACE_MS` (20 s) · `READY_TIMEOUT_MS` (90 s) ·
`STALL_FORFEIT_MS` (45 s) · `MATCH_IDLE_MS` (10 min) · `REMATCH_TIMEOUT_MS` (60 s) ·
`END_TIMEOUT_MS` (10 s) · `ALLOWED_ORIGINS`.

## Notes

- `games/battleblitz/web/` will drift from `battleblitz/web/` on purpose. A runtime fix that
  matters to both has to be applied to both by hand.
- The pause key, cheats and the controls pop-up are disabled in 2P (unsynced state).
- Determinism self test: open `games/battleblitz/web/?match=selftest` and run `await mpSelfTest()`
  in the console — it plays a scripted fight twice and compares checksums.
