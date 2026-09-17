# 625 Sandwich Stacker — static game server.
# Build from the repo root (the game shares flash/web/player.js with the other Flash ports):
#   docker build -f sandwichstacker/Dockerfile -t arcade/sandwichstacker .
# The image mirrors the repo layout, so the page's relative imports (../../flash/web/player.js,
# ../assets/) work standalone and behind a path-prefixed proxy.
FROM nginx:1.27-alpine

COPY sandwichstacker/docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY flash/web/               /usr/share/nginx/html/flash/web/
COPY sandwichstacker/web/     /usr/share/nginx/html/sandwichstacker/web/
COPY sandwichstacker/assets/  /usr/share/nginx/html/sandwichstacker/assets/

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/healthz >/dev/null || exit 1
