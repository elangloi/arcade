#!/usr/bin/env bash
# Deploy the arcade stack to the home server.
#
#   compose/deploy.sh                 # deploy to the default host
#   ARCADE_HOST=user@host compose/deploy.sh
#
# Builds the game images locally for linux/amd64 (the server is x86_64; a Mac
# builds arm64 by default), rsyncs compose/ to the server, streams the images
# into its Docker over SSH (there is no registry), and restarts the stack.
# The server only ever sees finished images -- no build deps are installed there.
set -euo pipefail

ARCADE_HOST="${ARCADE_HOST:-elizabeth@192.168.1.179}"
REMOTE_DIR="${ARCADE_REMOTE_DIR:-~/arcade}"
IMAGES=(arcade/battleblitz arcade/sandwichstacker arcade/pizzatron arcade/nobynobyboy arcade/multiplayer)

cd "$(dirname "$0")"

echo "==> Building images for linux/amd64"
DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose build

echo "==> Syncing compose/ to $ARCADE_HOST:$REMOTE_DIR/compose/"
ssh "$ARCADE_HOST" "mkdir -p $REMOTE_DIR/compose"
rsync -az --delete --exclude deploy.sh ./ "$ARCADE_HOST:$REMOTE_DIR/compose/"

echo "==> Streaming ${#IMAGES[@]} images to $ARCADE_HOST"
docker save "${IMAGES[@]/%/:latest}" | gzip | ssh "$ARCADE_HOST" 'gunzip | docker load'

echo "==> Starting stack"
ssh "$ARCADE_HOST" "cd $REMOTE_DIR/compose && docker compose up -d --no-build --remove-orphans && docker compose ps"

host="${ARCADE_HOST#*@}"
echo "==> Arcade is at http://$host/"
