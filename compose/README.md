# compose — home arcade stack

```bash
cd compose
docker compose up -d --build      # first run / after changing a game
```

Then open `http://<host>/`. The proxy publishes port 80 (override with `ARCADE_HTTP_PORT=8080 docker compose up -d`).

## Deploying to the home server

```bash
compose/deploy.sh                          # -> http://192.168.1.179/
ARCADE_HOST=user@other-host compose/deploy.sh
```

The server (`elizabeth@192.168.1.179`, Ubuntu 24.04, x86_64) only has Docker + Compose; nothing is built there. `deploy.sh` builds the images locally for `linux/amd64`, rsyncs this folder to `~/arcade/compose/` on the server, streams the images in with `docker save | ssh docker load` (there is no registry), and runs `docker compose up -d --no-build`. Rerun it after changing a game, the nginx config, or the landing page.

First-time server setup: `curl -fsSL https://get.docker.com | sudo sh && sudo usermod -aG docker $USER`, then log back in.

| Path | Goes to |
|------|---------|
| `/` | landing page (`nginx/html/index.html`) |
| `/teen-titans-battle-blitz/` | the `battleblitz` container (built from `../battleblitz/Dockerfile`) |
| `/lilo-and-stitch-sandwich-stacker/` | the `sandwichstacker` container (built from `../sandwichstacker/Dockerfile`) |
| `/club-penguin-pizzatron/` | the `pizzatron` container (built from `../pizzatron/Dockerfile`) |
| `/noby-noby-boy/` | the `nobynobyboy` container (built from `../nobynobyboy/Dockerfile`) |
| `/arcade/multiplayer/` | the `multiplayer` Node container (built from the repo root with `../multiplayer/Dockerfile`; `/arcade/multiplayer/ws` is upgraded to a WebSocket) |

## Adding a game

1. Give the game a `Dockerfile` that serves it on port 80 with **relative** URLs (so it works under a path prefix). Flash ports build from the repo root (`context: ..`) so they can copy the shared `flash/web/player.js`.
2. Add a service to `docker-compose.yml`.
3. Add a `location /<slug>/` block to `nginx/conf.d/arcade.conf` (copy an existing one: `set $up_<service> http://<service>:80; rewrite ^/<slug>/(.*)$ /$1 break; proxy_pass $up_<service>;` — the variable + resolver means a rebuilt container is re-resolved without restarting the proxy).
4. Add a card to `nginx/html/index.html`.

Tunables: `MP_DIFFICULTY=1..3` (Battle Blitz 2P health tier; default 1) via the environment or a `.env` next to the compose file.
