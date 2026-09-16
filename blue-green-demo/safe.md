# With blue/green: v1 stays live

First, restore v1 and enable blue/green in the Killercoda terminal:

```bash
reset
cat /opt/cd-demo/deployment-mode
curl -i http://127.0.0.1/
```

Expected: `blue-green`, HTTP 200, and v1.

In VSCode, leave `VERSION = "v3"` and `BROKEN = True` unchanged. Push a new commit so the VM tries that same broken code again:

```bash
git commit --allow-empty -m "Broken v3 with blue-green"
git push origin release
```

This time v3 starts in the inactive slot. Its health check fails, so Nginx keeps sending traffic to v1. Confirm in Killercoda:

```bash
curl -i http://127.0.0.1/
cat /opt/cd-demo/active-slot
```

Expected: **HTTP 200**, still v1. [The deployment log]({{TRAFFIC_HOST1_80}}/logs) shows the rejected candidate.
