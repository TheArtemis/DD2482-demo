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

Killercoda loads the presentation from `main`. The VM watches `release` for app commits, and Nginx serves the [live app]({{TRAFFIC_HOST1_80}}) and [deployment log]({{TRAFFIC_HOST1_80}}/logs).
