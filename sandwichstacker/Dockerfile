# 625 Sandwich Stacker — static game server.
# Serves /web (the player + game logic) and /assets (vector art, sounds, timeline data).
# The page uses relative URLs (../assets/...), so it works standalone and behind a path-prefixed proxy.
FROM nginx:1.27-alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY web/    /usr/share/nginx/html/web/
COPY assets/ /usr/share/nginx/html/assets/

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/healthz >/dev/null || exit 1
