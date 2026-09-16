#!/usr/bin/env bash
set -Eeuo pipefail

REPO=/opt/git/cd-demo.git
DEPLOY_ROOT=/opt/cd-demo
RELEASE_DIR="$DEPLOY_ROOT/release"
LAST_ATTEMPTED="$DEPLOY_ROOT/last-attempted-revision"
BRANCH=release
POLL_SECONDS=10

while true; do
  if ! git --git-dir="$REPO" fetch --quiet --depth=1 origin \
    "refs/heads/$BRANCH:refs/remotes/origin/$BRANCH"; then
    echo "Could not fetch $BRANCH; retrying in $POLL_SECONDS seconds" >&2
    sleep "$POLL_SECONDS"
    continue
  fi

  revision=$(git --git-dir="$REPO" rev-parse "refs/remotes/origin/$BRANCH")
  if [[ "$revision" != "$(cat "$LAST_ATTEMPTED" 2>/dev/null || true)" ]]; then
    echo "New $BRANCH revision: $revision"
    staging=$(mktemp -d)
    if git --git-dir="$REPO" archive "$revision" \
      blue-green-demo/assets/app.py \
      blue-green-demo/assets/requirements.txt \
      blue-green-demo/assets/Dockerfile |
      tar -x -C "$staging" --strip-components=2; then
      cp "$staging"/* "$RELEASE_DIR"/
      printf '%s\n' "$revision" > "$LAST_ATTEMPTED"
      if "$DEPLOY_ROOT/deploy.sh" "$revision"; then
        echo "Deployed $revision"
      else
        echo "Deployment rejected for $revision; waiting for a new push" >&2
      fi
    else
      echo "Release files missing at $revision; waiting for a new push" >&2
      printf '%s\n' "$revision" > "$LAST_ATTEMPTED"
    fi
    rm -rf "$staging"
  fi

  sleep "$POLL_SECONDS"
done
