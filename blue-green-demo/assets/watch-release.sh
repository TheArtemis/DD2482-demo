#!/usr/bin/env bash
set -Eeuo pipefail

REPO=/opt/git/cd-demo.git
DEPLOY_ROOT=/opt/cd-demo
RELEASE_DIR="$DEPLOY_ROOT/release"
LAST_ATTEMPTED="$DEPLOY_ROOT/last-attempted-revision"
BRANCH=release
POLL_SECONDS=10
LOG_FILE="$DEPLOY_ROOT/deploy.log"
MODE_FILE="$DEPLOY_ROOT/deployment-mode"

exec > >(tee -a "$LOG_FILE") 2>&1

log() {
  printf '[%s] %s\n' "$(date -u '+%H:%M:%S UTC')" "$*"
}

log "Watching $BRANCH at $(git --git-dir="$REPO" remote get-url origin)"
fetch_failures=0

while true; do
  # A depth-1 fetch may hide the parent commit, so Git cannot prove a normal
  # branch update is fast-forward. The + updates only this VM's tracking ref.
  if fetch_output=$(GIT_TERMINAL_PROMPT=0 timeout 20s git --git-dir="$REPO" fetch --depth=1 origin \
    "+refs/heads/$BRANCH:refs/remotes/origin/$BRANCH" 2>&1); then
    if (( fetch_failures > 0 )); then
      log "GitHub fetch recovered after $fetch_failures failed attempt(s)"
    fi
    fetch_failures=0
  else
    fetch_status=$?
    fetch_failures=$((fetch_failures + 1))
    if (( fetch_failures == 1 || fetch_failures % 6 == 0 )); then
      log "Could not fetch $BRANCH (exit $fetch_status, attempt $fetch_failures): ${fetch_output:-Git produced no error output}"
    fi
    sleep "$POLL_SECONDS"
    continue
  fi

  revision=$(git --git-dir="$REPO" rev-parse "refs/remotes/origin/$BRANCH")
  if [[ "$revision" != "$(cat "$LAST_ATTEMPTED" 2>/dev/null || true)" ]]; then
    log "Fetched new $BRANCH release: $revision"
    staging=$(mktemp -d)
    if git --git-dir="$REPO" archive "$revision" \
      blue-green-demo/assets/app.py \
      blue-green-demo/assets/requirements.txt \
      blue-green-demo/assets/Dockerfile |
      tar -x -C "$staging" --strip-components=2; then
      cp "$staging"/* "$RELEASE_DIR"/
      printf '%s\n' "$revision" > "$LAST_ATTEMPTED"
      mode=$(cat "$MODE_FILE")
      log "Deploying $revision in $mode mode"
      if [[ "$mode" == unsafe ]]; then
        deploy_command="$DEPLOY_ROOT/deploy-unsafe.sh"
      elif [[ "$mode" == blue-green ]]; then
        deploy_command="$DEPLOY_ROOT/deploy.sh"
      else
        log "Unknown deployment mode: $mode"
        rm -rf "$staging"
        sleep "$POLL_SECONDS"
        continue
      fi
      if "$deploy_command" "$revision"; then
        log "Deployed $revision"
      else
        log "Deployment rejected for $revision; waiting for a new push"
      fi
    else
      log "Release files missing at $revision; waiting for a new push"
      printf '%s\n' "$revision" > "$LAST_ATTEMPTED"
    fi
    rm -rf "$staging"
  fi

  sleep "$POLL_SECONDS"
done
