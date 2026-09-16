# Blue/green deployment

Two app slots run side by side. Nginx sends traffic to one slot while the other receives the next version.

```text
BLUE  v1  ← live traffic
GREEN v3  ← candidate
```

The candidate gets a health check and a smoke test **before** Nginx switches traffic. If either check fails, the live slot keeps serving users.

The presentation shows the same broken release twice: first without blue/green protection, then with it enabled.

**Live app:** Killercoda menu (☰) → **Traffic / Ports** → Host 1, port **80** → **Access**. The **Live app** tab also opens port 80 when available. The deployment log is at `/logs` on the same port.
