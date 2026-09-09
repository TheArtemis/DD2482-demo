#!/usr/bin/env bash
set -Eeuo pipefail

WORKING_REPO=/root/cd-demo
BARE_REPO=/opt/git/cd-demo.git
DEPLOY_ROOT=/opt/cd-demo

until docker info >/dev/null 2>&1; do
  sleep 1
done

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq nginx
rm -f /etc/nginx/sites-enabled/default
systemctl enable --now nginx

mkdir -p "$DEPLOY_ROOT/release" "$(dirname "$BARE_REPO")"
# Init the bare repo first. KillerCoda assets must not land under hooks/
# beforehand — git init recreates that directory from templates.
git init --bare --initial-branch=main "$BARE_REPO"
cp "$DEPLOY_ROOT/post-receive" "$BARE_REPO/hooks/post-receive"
chmod +x "$BARE_REPO/hooks/post-receive" "$DEPLOY_ROOT/deploy.sh" "$WORKING_REPO/reset-demo.sh"

git -C "$WORKING_REPO" init -b main
git -C "$WORKING_REPO" config user.name "KillerCoda Demo"
git -C "$WORKING_REPO" config user.email "demo@killercoda.local"
git -C "$WORKING_REPO" add app.py requirements.txt Dockerfile reset-demo.sh
git -C "$WORKING_REPO" commit -m "Initial v1 release"
git -C "$WORKING_REPO" remote add production "$BARE_REPO"
git -C "$WORKING_REPO" push -u production main

# Keep both fixed ports observable before the first automated release. The next
# deployment deliberately replaces this inactive green container.
initial_revision=$(git -C "$WORKING_REPO" rev-parse HEAD)
docker run --detach --name app-green \
  --env SLOT=GREEN \
  --publish 127.0.0.1:8002:8000 \
  "cd-demo:${initial_revision}" >/dev/null
