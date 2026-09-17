# arcade

Self-hosted browser arcade for the home server.

| Folder | What |
|--------|------|
| [`battleblitz/`](battleblitz/) | Teen Titans: Battle Blitz (2003) recreated in JS. Has its own `Dockerfile`. |
| [`sandwichstacker/`](sandwichstacker/) | Lilo & Stitch: 625 Sandwich Stacker (2003) recreated in JS. Has its own `Dockerfile`. |
| [`pizzatron/`](pizzatron/) | Club Penguin: Pizzatron 3000 (2007) recreated in JS. Has its own `Dockerfile`. |
| [`flash/`](flash/) | Shared by the Flash ports: the SVG player (`web/player.js`) and the SWF extraction/decompilation toolkit (`tools/`). |
| [`compose/`](compose/) | The deployable stack: nginx front proxy + landing page + one service per game. `cd compose && docker compose up -d --build`. |

Games are reached by path through the proxy (`/teen-titans-battle-blitz/`, `/lilo-and-stitch-sandwich-stacker/`, `/club-penguin-pizzatron/`); see `compose/README.md` for adding more.

For local development, `python3 serve.py 8765` serves the whole repo (no caching): <http://localhost:8765/battleblitz/web/>, <http://localhost:8765/sandwichstacker/web/>, <http://localhost:8765/pizzatron/web/>.
