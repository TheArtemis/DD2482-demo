# DD2482-demo

The [Killercoda scenario](blue-green-demo/) compares two ways to deploy the same broken v3 release from GitHub:

```text
VSCode -> GitHub release -> VM poller -> unsafe live replacement -> outage
                            |            reset bundled v1
                            +---------> blue/green health check -> v1 stays live
```

Killercoda reads the scenario from `main`. The VM independently checks `release` every 10 seconds and deploys each new commit once. The first commit pushed during a session uses an intentionally unsafe deployment. Run `/opt/cd-demo/reset-v1.sh` in the VM to restore v1 and switch to blue/green mode, then push another commit with the same broken v3 code.

The app and a separate `/logs` page are served by Nginx. `/logs` shows deployment output plus Nginx access and error logs, and remains available during the outage. See the [walkthrough](blue-green-demo/demo.md) for exact steps.

The VM fetches over HTTPS without credentials, so the GitHub repository must be public. A private repository needs a separate read-only credential in the VM; Killercoda's deploy key is not available there.
