#!/usr/bin/env bash
set -Eeuo pipefail

DEPLOY_ROOT=/opt/cd-demo
RELEASE_DIR="$DEPLOY_ROOT/release"
ACTIVE_FILE="$DEPLOY_ROOT/active-slot"
IMAGE_TAG="cd-demo:${1:-latest}"

slot_port() {
  case "$1" in
    blue) printf '8001' ;;
    green) printf '8002' ;;
    *) echo "Unknown slot: $1" >&2; exit 1 ;;
  esac
}

active_slot=$(cat "$ACTIVE_FILE" 2>/dev/null || true)
if [[ "$active_slot" == "blue" ]]; then
  candidate=green
else
  candidate=blue
fi
candidate_port=$(slot_port "$candidate")
candidate_name="app-$candidate"

echo "Building $IMAGE_TAG from $RELEASE_DIR"
docker build --tag "$IMAGE_TAG" "$RELEASE_DIR"

docker rm --force "$candidate_name" >/dev/null 2>&1 || true
docker run --detach --name "$candidate_name" \
  --env "SLOT=${candidate^^}" \
  --publish "127.0.0.1:${candidate_port}:8000" \
  "$IMAGE_TAG" >/dev/null

echo "Waiting for $candidate on :$candidate_port"
healthy=false
for _ in {1..10}; do
  if curl --fail --silent --show-error "http://127.0.0.1:${candidate_port}/health" >/dev/null; then
    healthy=true
    break
  fi
  sleep 1
done

if [[ "$healthy" != true ]]; then
  echo "Health check failed; keeping ${active_slot:-the current} slot in production." >&2
  docker logs "$candidate_name" >&2 || true
  docker rm --force "$candidate_name" >/dev/null 2>&1 || true
  exit 1
fi

if ! curl --fail --silent --show-error "http://127.0.0.1:${candidate_port}/" | grep --quiet "Continuous Deployment Demo"; then
  echo "Smoke test failed; keeping ${active_slot:-the current} slot in production." >&2
  docker logs "$candidate_name" >&2 || true
  docker rm --force "$candidate_name" >/dev/null 2>&1 || true
  exit 1
fi

nginx_config=/etc/nginx/sites-enabled/cd-demo.conf
new_nginx_config=$(mktemp /etc/nginx/sites-enabled/cd-demo.conf.XXXXXX)
sed "s/__PORT__/$candidate_port/g" "$DEPLOY_ROOT/nginx-template.conf" > "$new_nginx_config"
mv "$new_nginx_config" "$nginx_config"

nginx -t
systemctl reload nginx

printf '%s\n' "$candidate" > "$ACTIVE_FILE"
echo "Production now serves $candidate on port $candidate_port."
