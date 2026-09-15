# Teen Titans: Battle Blitz — static game server.
# Serves /web (the game) and /assets (art + sound). The page uses relative URLs
# (../assets/...), so it works both standalone and behind a path-prefixed proxy.
FROM nginx:1.27-alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY web/    /usr/share/nginx/html/web/
COPY assets/ /usr/share/nginx/html/assets/

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/healthz >/dev/null || exit 1
