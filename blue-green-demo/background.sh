#!/usr/bin/env bash
set -Eeuo pipefail

WORKING_REPO=/root/cd-demo
BARE_REPO=/opt/git/cd-demo.git
DEPLOY_ROOT=/opt/cd-demo
GITHUB_REPO=https://github.com/TheArtemis/DD2482-demo.git

# Wait for Docker to be ready
until docker info >/dev/null 2>&1; do
  sleep 1
done

# No interactive prompts
export DEBIAN_FRONTEND=noninteractive

# Install Nginx
apt-get update -qq
apt-get install -y -qq nginx
rm -f /etc/nginx/sites-enabled/default
systemctl enable --now nginx

mkdir -p "$DEPLOY_ROOT/release" "$(dirname "$BARE_REPO")"
chmod +x "$DEPLOY_ROOT/deploy.sh" "$DEPLOY_ROOT/watch-release.sh"

# Boot with the bundled v1, even when the release branch has not been created yet.
cp "$WORKING_REPO/app.py" "$WORKING_REPO/requirements.txt" \
  "$WORKING_REPO/Dockerfile" "$DEPLOY_ROOT/release/"
"$DEPLOY_ROOT/deploy.sh" bundled-v1

# Keep both fixed slot mappings visible at startup.
docker run --detach --name app-green \
  --env SLOT=GREEN \
  --publish 127.0.0.1:8002:8000 \
  cd-demo:bundled-v1 >/dev/null

# Fetch the app from GitHub inside this VM. Killercoda's own webhook still
# watches main for scenario updates; it is not involved in app deployment.
git init --bare "$BARE_REPO"
git --git-dir="$BARE_REPO" remote add origin "$GITHUB_REPO"
cat > /etc/systemd/system/cd-demo-watch.service <<'EOF'
[Unit]
Description=Watch GitHub release branch and deploy app changes
After=network-online.target docker.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/opt/cd-demo/watch-release.sh
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now cd-demo-watch.service
