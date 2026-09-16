# Demo architecture

```text
VSCode → GitHub release branch → VM watcher (every 10 seconds)
             │                            │
             └→ GitHub Actions tests       └→ Docker candidate
                                               │
                                        health + smoke checks
                                               │
                                           Nginx → live app
```

Killercoda loads these presentation pages from `main`. The VM watches `release` for app commits. Nginx serves the app and the [deployment log]({{TRAFFIC_HOST1_80}}/logs).

At startup, v1 is live and the VM is in `unsafe` mode. If `release` already exists, its current commit is treated as a baseline; the next push starts the demo. If it does not exist, create it from `main` at v1 on your machine:

```bash
git switch -c release main
git push -u origin release
```

Wait for that initial push to finish deploying before moving on.

```bash
curl -s http://127.0.0.1/ | grep -E 'Version|Slot'
cat /opt/cd-demo/deployment-mode
```
