# Blue/green deployment

Two app slots run side by side. Nginx sends traffic to one slot while the other receives the next version.

```text
BLUE  v1  ← live traffic
GREEN v3  ← candidate
```

The candidate gets a health check and a smoke test **before** Nginx switches traffic. If either check fails, the live slot keeps serving users.

In this demo, we first skip that protection so the failure is visible. Then we repeat the same release with blue/green enabled.

[Open the app]({{TRAFFIC_HOST1_80}}) and [open the deployment log]({{TRAFFIC_HOST1_80}}/logs) in separate tabs.
