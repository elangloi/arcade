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

The server (`elizabeth@192.168.1.179`, Ubuntu 24.04, x86_64) only has Docker + Compose; nothing is built there. `deploy.sh` builds the images locally for `linux/amd64`, rsyncs this folder to `~/arcade/compose/` on the server, streams the images in with `docker save | ssh docker load` (there is no registry), and runs `docker compose up -d --no-build`. Rerun it after changing a game, the nginx config, or the front end.

### Letting friends in from outside (Tailscale Funnel)

The stack can join your Tailscale network as a node called `arcade` and publish itself at
`https://arcade.<your-tailnet>.ts.net/` — HTTPS, no port forwarding, nothing installed on the
server beyond Docker. It's the `tailscale` service behind the `public` profile:

1. Sign in at <https://login.tailscale.com> (creates your tailnet), then: Settings → Keys → generate
   an auth key; DNS → enable HTTPS certificates.
2. `cp compose/.env.example compose/.env` and put the key in `TS_AUTHKEY` (`COMPOSE_PROFILES=public`
   is already set there). `.env` is git-ignored; `deploy.sh` copies it to the server.
3. `compose/deploy.sh` (or locally `docker compose up -d`). On first start the container asks the
   admin console to allow Funnel — `docker compose logs tailscale` prints the link — approve it once.
4. Send the URL. Anyone with it can play; it's a public link, so treat it like one.

`tailscale/serve.json` is the serve/funnel config (port 443 → the nginx container). The node's state
lives in the `tailscale-state` volume so its identity survives redeploys. To stop publishing: remove
`COMPOSE_PROFILES` from `.env` and `docker compose --profile public down tailscale`.

For a private alternative (friend installs Tailscale, you share the machine with them from the admin
console) drop the `AllowFunnel` block from `serve.json`; the same URL then only works inside the tailnet.

First-time server setup: `curl -fsSL https://get.docker.com | sudo sh && sudo usermod -aG docker $USER`, then log back in.

| Path | Goes to |
|------|---------|
| `/`, `/single/…`, `/multiplayer/…` | the React shell (`frontend/`, baked into the `proxy` image) |
| `/teen-titans-battle-blitz/` | the `battleblitz` container (built from `../battleblitz/Dockerfile`) |
| `/lilo-and-stitch-sandwich-stacker/` | the `sandwichstacker` container (built from `../sandwichstacker/Dockerfile`) |
| `/club-penguin-pizzatron/` | the `pizzatron` container (built from `../pizzatron/Dockerfile`) |
| `/club-penguin-card-jitsu/` | the `cardjitsu` container (built from `../cardjitsu/Dockerfile`) |
| `/arcade/multiplayer/` | the `multiplayer` Node container (built from the repo root with `../multiplayer/Dockerfile`; `/arcade/multiplayer/ws` is upgraded to a WebSocket) |

## Adding a game

1. Give the game a `Dockerfile` that serves it on port 80 with **relative** URLs (so it works under a path prefix). Flash ports build from the repo root (`context: ..`) so they can copy the shared `flash/web/player.js`.
2. Add a service to `docker-compose.yml`.
3. Add a `location /<slug>/` block to `nginx/conf.d/arcade.conf` (copy an existing one: `set $up_<service> http://<service>:80; rewrite ^/<slug>/(.*)$ /$1 break; proxy_pass $up_<service>;` — the variable + resolver means a rebuilt container is re-resolved without restarting the proxy).
4. Register it in `frontend/src/lib/games.ts` (menu, floor, and frame route come from that one entry).

Tunables: `MP_DIFFICULTY=1..3` (Battle Blitz 2P health tier; default 1) via the environment or a `.env` next to the compose file.
