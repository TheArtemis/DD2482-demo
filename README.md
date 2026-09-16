# DD2482-demo

The [Killercoda scenario](blue-green-demo/) is a six-page presentation and live demo. It compares two ways to deploy broken v3, then shows healthy v4 switching traffic:

```text
VSCode -> GitHub release -> VM poller -> unsafe live replacement -> outage
                            |            reset bundled v1
                            +---------> blue/green health check -> v1 stays live
                            +---------> healthy v4 -> Nginx switches slots
```

Killercoda reads the scenario from `main`. The VM independently checks `release` every 10 seconds and deploys each new commit once. The first broken v3 release uses an intentionally unsafe deployment. Run `reset` in the VM to restore v1 and switch to blue/green mode, then push another commit with the same broken v3 code. Finally, push healthy v4 to show a successful slot switch.

The app and a separate `/logs` page are served by Nginx. `/logs` shows release fetches and deployment output, and remains available during the outage. The presentation starts at [the introduction](blue-green-demo/intro.md).

The VM fetches over HTTPS without credentials, so the GitHub repository must be public. A private repository needs a separate read-only credential in the VM; Killercoda's deploy key is not available there.
