# Unsafe deployment versus blue/green

The VM starts with v1 serving through Nginx. It checks GitHub's `release` branch every 10 seconds for commits pushed from your VSCode checkout. The first release uses an intentionally unsafe deployment: it replaces the live container before checking whether the replacement works.

You will push a broken v3, watch the app fail, restore v1 on the VM, and push v3 again. The second push uses blue/green deployment and keeps v1 available.

Keep these two pages open:

- [The app]({{TRAFFIC_HOST1_80}})
- [Deployment and Nginx logs]({{TRAFFIC_HOST1_80}}/logs)

The log page is served directly by Nginx, so it remains available even when the app is down. Killercoda reads this scenario from `main`; the VM independently watches `release`. If `release` already exists when the VM starts, the VM treats its current commit as a baseline and waits for your next push.

Confirm v1 in the Killercoda terminal:

```bash
curl -i http://127.0.0.1/
cat /opt/cd-demo/deployment-mode
```

You should see v1 and `unsafe`.
