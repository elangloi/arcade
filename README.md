# arcade

Self-hosted browser arcade for the home server.

| Folder | What |
|--------|------|
| [`battleblitz/`](battleblitz/) | Teen Titans: Battle Blitz (2003) recreated in JS. Has its own `Dockerfile`. |
| [`compose/`](compose/) | The deployable stack: nginx front proxy + landing page + one service per game. `cd compose && docker compose up -d --build`. |

Games are reached by path through the proxy (`/teen-titans-battle-blitz/`); see `compose/README.md` for adding more.
