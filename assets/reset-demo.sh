#!/usr/bin/env bash
set -Eeuo pipefail

cd /root/cd-demo
sed -i 's/^VERSION = ".*"/VERSION = "v1"/; s/^BROKEN = .*/BROKEN = False/' app.py
git add app.py
if ! git diff --cached --quiet; then
  git commit -m "Reset demo to v1"
  git push production main
fi
