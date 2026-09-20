# arcade

Self-hosted browser arcade for the home server.

| Folder | What |
|--------|------|
| [`battleblitz/`](battleblitz/) | Teen Titans: Battle Blitz (2003) recreated in JS. Has its own `Dockerfile`. |
| [`sandwichstacker/`](sandwichstacker/) | Lilo & Stitch: 625 Sandwich Stacker (2003) recreated in JS. Has its own `Dockerfile`. |
| [`pizzatron/`](pizzatron/) | Club Penguin: Pizzatron 3000 (2007) recreated in JS. Has its own `Dockerfile`. |
| [`nobynobyboy/`](nobynobyboy/) | An original WebGL homage to Noby Noby Boy (PS3, 2009). Has its own `Dockerfile`. |
| [`multiplayer/`](multiplayer/) | The online arcade at `/arcade/multiplayer/`: Node service (lobby, matchmaking, SQLite event log, lockstep WebSocket relay) plus a fork of the Battle Blitz client wired for two players. Has its own `Dockerfile` (built from the repo root). |
| [`flash/`](flash/) | Shared by the Flash ports: the SVG player (`web/player.js`) and the SWF extraction/decompilation toolkit (`tools/`). |
| [`compose/`](compose/) | The deployable stack: nginx front proxy + landing page + one service per game. `cd compose && docker compose up -d --build` locally; `compose/deploy.sh` ships it to the home server. |

Games are reached by path through the proxy (`/teen-titans-battle-blitz/`, `/lilo-and-stitch-sandwich-stacker/`, `/club-penguin-pizzatron/`, `/noby-noby-boy/`); the multiplayer arcade is at `/arcade/multiplayer/`. See `compose/README.md` for adding more.

For local development, `python3 serve.py 8765` serves the whole repo (no caching): <http://localhost:8765/battleblitz/web/>, <http://localhost:8765/sandwichstacker/web/>, <http://localhost:8765/pizzatron/web/>, <http://localhost:8765/nobynobyboy/web/>. The multiplayer service is a separate process: `npm --prefix multiplayer run dev` → <http://localhost:8766/arcade/multiplayer/> (`serve.py` redirects `/arcade/multiplayer/` there).
