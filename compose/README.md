# compose — home arcade stack

```bash
cd compose
docker compose up -d --build      # first run / after changing a game
```

Then open `http://<host>/`. The proxy publishes port 80 (override with `ARCADE_HTTP_PORT=8080 docker compose up -d`).

| Path | Goes to |
|------|---------|
| `/` | landing page (`nginx/html/index.html`) |
| `/teen-titans-battle-blitz/` | the `battleblitz` container (built from `../battleblitz/Dockerfile`) |
| `/lilo-and-stitch-sandwich-stacker/` | the `sandwichstacker` container (built from `../sandwichstacker/Dockerfile`) |

## Adding a game

1. Give the game a `Dockerfile` that serves it on port 80 with **relative** URLs (so it works under a path prefix).
2. Add a service to `docker-compose.yml`.
3. Add an `upstream` + `location /<slug>/ { proxy_pass http://<service>/; ... }` block to `nginx/conf.d/arcade.conf`.
4. Add a card to `nginx/html/index.html`.
