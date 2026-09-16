# DD2482-demo

The Killercoda scenario is in [blue-green-demo](blue-green-demo/). It demonstrates blue/green deployment from GitHub:

```text
local machine -> GitHub release branch -> VM polls/fetches -> health checks -> Nginx switch
                   |-> GitHub Actions unit tests
```

Keep Killercoda configured to read `main`. Its webhook updates the scenario from that branch. The VM independently checks `release` every 10 seconds and deploys new app revisions without changing the running scenario.

The VM fetches over HTTPS without credentials, so the GitHub repository must be public. If it is private, the VM needs a separate read-only credential; Killercoda's deploy key is not available inside the VM. No GitHub webhook or inbound VM address is required.

Create `release` from `main` and push it before or during the demo. Then edit `blue-green-demo/assets/app.py` on your machine and push to `release`. The scenario's [demo instructions](blue-green-demo/demo.md) show the v2 and rejected v3 sequence.
