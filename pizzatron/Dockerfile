# Pizzatron 3000 — static game server.
# Build from the repo root (the game shares flash/web/player.js with the other Flash ports):
#   docker build -f pizzatron/Dockerfile -t arcade/pizzatron .
FROM nginx:1.27-alpine

COPY pizzatron/docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY flash/web/         /usr/share/nginx/html/flash/web/
COPY pizzatron/web/     /usr/share/nginx/html/pizzatron/web/
COPY pizzatron/assets/  /usr/share/nginx/html/pizzatron/assets/

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/healthz >/dev/null || exit 1
