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

echo "UNSAFE: stopping live v1 container app-$slot before validating the replacement"
docker rm --force "app-$slot" >/dev/null
docker run --detach --name "app-$slot" \
  --env "SLOT=${slot^^}" \
  --publish "127.0.0.1:${port}:8000" \
  "$IMAGE_TAG" >/dev/null

echo "UNSAFE: checking the replacement after it took over the live port"
for attempt in {1..10}; do
  if http_status=$(curl --fail --silent --output /dev/null --write-out '%{http_code}' \
    --max-time 2 "http://127.0.0.1:${port}/health"); then
    echo "UNSAFE: health check $attempt/10 for $slot: HTTP $http_status (passed)"
    echo "UNSAFE: replacement is healthy"
    exit 0
  else
    curl_status=$?
    echo "UNSAFE: health check $attempt/10 for $slot: HTTP ${http_status:-000} (curl exit $curl_status)"
  fi
  sleep 1
done

echo "UNSAFE: health check failed; stopping the broken replacement. Nginx now has no working upstream." >&2
docker logs "app-$slot" >&2 || true
docker rm --force "app-$slot" >/dev/null 2>&1 || true
exit 1
