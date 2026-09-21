# arcade

Self-hosted browser arcade for the home server.

| Folder | What |
|--------|------|
| [`battleblitz/`](battleblitz/) | Teen Titans: Battle Blitz (2003) recreated in JS. Has its own `Dockerfile`. |
| [`sandwichstacker/`](sandwichstacker/) | Lilo & Stitch: 625 Sandwich Stacker (2003) recreated in JS. Has its own `Dockerfile`. |
| [`pizzatron/`](pizzatron/) | Club Penguin: Pizzatron 3000 (2007) recreated in JS. Has its own `Dockerfile`. |
| [`cardjitsu/`](cardjitsu/) | Club Penguin: Card-Jitsu (2008) recreated in JS, played against the Sensei. Has its own `Dockerfile`. |
| [`nobynobyboy/`](nobynobyboy/) | An original WebGL homage to Noby Noby Boy (PS3, 2009). Has its own `Dockerfile`. |
| [`frontend/`](frontend/) | The arcade shell: React + Tailwind + shadcn. Front of house, the single/multiplayer floors, the 2P lobby, and the frame each cabinet plays in. Built into the nginx proxy image. |
| [`multiplayer/`](multiplayer/) | The multiplayer service at `/arcade/multiplayer/`: Node (sessions, matchmaking, SQLite event log, lockstep WebSocket relay) plus a fork of the Battle Blitz client wired for two players. Has its own `Dockerfile` (built from the repo root). |
| [`flash/`](flash/) | Shared by the Flash ports: the SVG player (`web/player.js`) and the SWF extraction/decompilation toolkit (`tools/`). |
| [`compose/`](compose/) | The deployable stack: nginx front proxy + landing page + one service per game. `cd compose && docker compose up -d --build` locally; `compose/deploy.sh` ships it to the home server. |

Players only ever see the shell (`/`, `/single/...`, `/multiplayer/...`); it frames the games, which the proxy serves by path (`/teen-titans-battle-blitz/`, `/lilo-and-stitch-sandwich-stacker/`, `/club-penguin-pizzatron/`, `/club-penguin-card-jitsu/`, `/noby-noby-boy/`, and the multiplayer service at `/arcade/multiplayer/`). See `compose/README.md` for adding more.

Local development is three processes — `python3 serve.py 8765` (the cabinets, no caching), `npm --prefix multiplayer run dev` (:8766) and `npm --prefix frontend run dev` (:5173, proxies the other two) — then <http://localhost:5173/>. The cabinets can still be opened bare, e.g. <http://localhost:8765/pizzatron/web/>.
