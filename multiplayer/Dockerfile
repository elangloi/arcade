# Multiplayer arcade service (Node). Build from the REPO ROOT so the Battle Blitz art can be
# copied in without duplicating it in git:
#   docker build -f multiplayer/Dockerfile -t arcade/multiplayer .
FROM node:24-alpine
WORKDIR /app
ENV NODE_ENV=production PORT=80 BASE_PATH=/arcade/multiplayer DB_PATH=/tmp/arcade.db \
    ASSETS_DIR=/app/games/battleblitz/assets

COPY multiplayer/package.json multiplayer/package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY multiplayer/server.js ./
COPY multiplayer/lib/ ./lib/
COPY multiplayer/games/battleblitz/web/ ./games/battleblitz/web/
# The forked client keeps the original's relative ../assets/ URLs; the art comes from the
# untouched single-player folder at build time.
COPY battleblitz/assets/ ./games/battleblitz/assets/

USER node
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/arcade/multiplayer/healthz >/dev/null || exit 1
CMD ["node", "server.js"]
