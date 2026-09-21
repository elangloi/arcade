# Card-Jitsu — static game server.
# Build from the repo root (the game shares flash/web/player.js with the other Flash ports):
#   docker build -f cardjitsu/Dockerfile -t arcade/cardjitsu .
FROM nginx:1.27-alpine

COPY cardjitsu/docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY flash/web/         /usr/share/nginx/html/flash/web/
COPY cardjitsu/web/     /usr/share/nginx/html/cardjitsu/web/
COPY cardjitsu/assets/  /usr/share/nginx/html/cardjitsu/assets/

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/healthz >/dev/null || exit 1
