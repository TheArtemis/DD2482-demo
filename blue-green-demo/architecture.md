# Demo architecture

```text
VSCode → GitHub release branch → VM watcher (every 10 seconds)
             │                            │
             └→ GitHub Actions tests      └→ Docker candidate
                                               │
                                        health + smoke checks
                                               │
                                           Nginx → live app
```

Killercoda loads the presentation from `main`. The VM watches `release` for app commits, and Nginx serves the app on port 80. The deployment log is at `/logs` on the same port.
