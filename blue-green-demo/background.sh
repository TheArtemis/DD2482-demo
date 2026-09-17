#!/usr/bin/env bash
set -Eeuo pipefail

WORKING_REPO=/root/cd-demo
BARE_REPO=/opt/git/cd-demo.git
DEPLOY_ROOT=/opt/cd-demo
GITHUB_REPO=https://github.com/TheArtemis/DD2482-demo.git

# Keep setup output even if Nginx never starts and /logs is unavailable.
mkdir -p "$DEPLOY_ROOT"
# A step can be entered again while an earlier setup is still running.
exec 9>"$DEPLOY_ROOT/setup.lock"
if ! flock -n 9; then
  exit 0
fi
exec >>"$DEPLOY_ROOT/setup.log" 2>&1
chmod 644 "$DEPLOY_ROOT/setup.log"
trap 'status=$?; printf "Setup failed at line %s (exit %s): %s\n" "$LINENO" "$status" "$BASH_COMMAND"' ERR
echo "Starting scenario setup"

if [[ -s "$DEPLOY_ROOT/active-slot" ]] && systemctl is-active --quiet cd-demo-watch.service; then
  echo "Scenario already initialized; keeping the active slot"
  exit 0
fi

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
chmod +x "$DEPLOY_ROOT/deploy.sh" "$DEPLOY_ROOT/deploy-unsafe.sh" \
  "$DEPLOY_ROOT/reset-v1.sh" "$DEPLOY_ROOT/watch-release.sh"
ln -sf "$DEPLOY_ROOT/reset-v1.sh" /usr/local/bin/reset
touch "$DEPLOY_ROOT/deploy.log"
chmod 644 "$DEPLOY_ROOT/deploy.log" "$DEPLOY_ROOT/logs.html"
if [[ ! -e "$DEPLOY_ROOT/deployment-mode" ]]; then
  printf '%s\n' unsafe > "$DEPLOY_ROOT/deployment-mode"
fi

# Boot with the bundled v1, even when the release branch has not been created yet.
active_slot=$(cat "$DEPLOY_ROOT/active-slot" 2>/dev/null || true)
case "$active_slot" in
  blue) active_port=8001 ;;
  green) active_port=8002 ;;
  *) active_port= ;;
esac
if [[ -z "$active_port" ]] || ! curl --fail --silent "http://127.0.0.1:${active_port}/health" >/dev/null; then
  cp "$WORKING_REPO/app.py" "$WORKING_REPO/requirements.txt" \
    "$WORKING_REPO/Dockerfile" "$DEPLOY_ROOT/release/"
  "$DEPLOY_ROOT/deploy.sh" bundled-v1 2>&1 | tee -a "$DEPLOY_ROOT/deploy.log"
else
  echo "Keeping healthy $active_slot slot on port $active_port"
fi

# Keep both fixed slot mappings visible at startup.
if ! docker container inspect app-green >/dev/null 2>&1; then
  docker run --detach --name app-green \
    --env SLOT=GREEN \
    --publish 127.0.0.1:8002:8000 \
    cd-demo:bundled-v1 >/dev/null
fi

# Fetch the app from GitHub inside this VM. Killercoda's own webhook still
# watches main for scenario updates; it is not involved in app deployment.
if [[ ! -d "$BARE_REPO" ]]; then
  git init --bare "$BARE_REPO"
fi
if ! git --git-dir="$BARE_REPO" remote get-url origin >/dev/null 2>&1; then
  git --git-dir="$BARE_REPO" remote add origin "$GITHUB_REPO"
fi
# If release already exists, treat its current commit as the starting point.
# Only commits pushed after this VM starts should trigger the first deployment.
if [[ ! -e "$DEPLOY_ROOT/last-attempted-revision" ]]; then
  if baseline_output=$(GIT_TERMINAL_PROMPT=0 timeout 20s git --git-dir="$BARE_REPO" fetch --depth=1 origin \
    +refs/heads/release:refs/remotes/origin/release 2>&1); then
    baseline_revision=$(git --git-dir="$BARE_REPO" rev-parse refs/remotes/origin/release)
    printf '%s\n' "$baseline_revision" > "$DEPLOY_ROOT/last-attempted-revision"
    echo "Starting from release revision $baseline_revision; waiting for a new push" | tee -a "$DEPLOY_ROOT/deploy.log"
  else
    echo "Initial release fetch failed; watcher will retry: ${baseline_output:-Git produced no error output}" | tee -a "$DEPLOY_ROOT/deploy.log"
  fi
fi
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
echo "Scenario setup complete"
