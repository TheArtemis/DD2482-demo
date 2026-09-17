#!/usr/bin/env bash
set -Eeuo pipefail

DEPLOY_ROOT=/opt/cd-demo
RELEASE_DIR="$DEPLOY_ROOT/release"
ACTIVE_FILE="$DEPLOY_ROOT/active-slot"
IMAGE_TAG="cd-demo:${1:?Expected a revision}"

slot=$(cat "$ACTIVE_FILE")
case "$slot" in
  blue) port=8001 ;;
  green) port=8002 ;;
  *) echo "Unknown active slot: $slot" >&2; exit 1 ;;
esac

echo "UNSAFE: building $IMAGE_TAG from $RELEASE_DIR"
docker build --tag "$IMAGE_TAG" "$RELEASE_DIR"

echo "UNSAFE: stopping live v1 container app-$slot"
docker rm --force "app-$slot" >/dev/null
docker run --detach --name "app-$slot" \
  --env "SLOT=${slot^^}" \
  --publish "127.0.0.1:${port}:8000" \
  "$IMAGE_TAG" >/dev/null
echo "UNSAFE: replacement is live on $slot without a health check"
