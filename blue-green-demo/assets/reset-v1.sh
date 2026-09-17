#!/usr/bin/env bash
set -Eeuo pipefail

DEPLOY_ROOT=/opt/cd-demo
ACTIVE_FILE="$DEPLOY_ROOT/active-slot"
MODE_FILE="$DEPLOY_ROOT/deployment-mode"
LOG_FILE="$DEPLOY_ROOT/deploy.log"

exec > >(tee -a "$LOG_FILE") 2>&1

slot=$(cat "$ACTIVE_FILE")
case "$slot" in
  blue) port=8001 ;;
  green) port=8002 ;;
  *) echo "Unknown active slot: $slot" >&2; exit 1 ;;
esac

echo "Resetting the live $slot slot to bundled v1"
docker rm --force "app-$slot" >/dev/null 2>&1 || true
docker run --detach --name "app-$slot" \
  --env "SLOT=${slot^^}" \
  --publish "127.0.0.1:${port}:8000" \
  cd-demo:bundled-v1 >/dev/null

for attempt in {1..10}; do
  if http_status=$(curl --fail --silent --output /dev/null --write-out '%{http_code}' \
    --max-time 2 "http://127.0.0.1:${port}/health"); then
    echo "Reset health check $attempt/10 for $slot: HTTP $http_status (passed)"
    printf '%s\n' blue-green > "$MODE_FILE"
    echo "v1 restored; blue/green mode is enabled for the next release push"
    exit 0
  else
    curl_status=$?
    echo "Reset health check $attempt/10 for $slot: HTTP ${http_status:-000} (curl exit $curl_status)"
  fi
  sleep 1
done

echo "Could not restore v1" >&2
docker logs "app-$slot" >&2 || true
exit 1
