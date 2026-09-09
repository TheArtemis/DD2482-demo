# Deploy v2, then reject broken v3

Work only in `/root/cd-demo`. The `production` remote is the local bare repository; its `post-receive` hook runs the deployment.

Release v2:

```bash
cd /root/cd-demo
sed -i 's/VERSION = "v1"/VERSION = "v2"/' app.py
git add app.py
git commit -m "Release v2"
git push production main
curl -s http://127.0.0.1/ | grep -E 'Version|Slot'
```

The release starts the inactive slot, waits for `GET /health` to return HTTP 200, performs a smoke test on `/`, then validates and reloads native Nginx to that slot. It does not restart the production app; it changes only the reverse-proxy destination. Confirm both the proxy and the individual slots:

```bash
curl -i http://127.0.0.1/health
curl -s http://127.0.0.1:8001/
curl -s http://127.0.0.1:8002/
cat /opt/cd-demo/active-slot
```

Now make v3 fail its health check. The push is expected to fail; the previously active production endpoint must remain on v2. The previous version remains running, ready for a fast rollback.

```bash
sed -i 's/VERSION = "v2"/VERSION = "v3"/; s/BROKEN = False/BROKEN = True/' app.py
git add app.py
git commit -m "Attempt broken v3"
git push production main || true
curl -s http://127.0.0.1/ | grep -E 'Version|Slot'
curl -i http://127.0.0.1/health
```

To restore a clean v1 state for another audience, run:

```bash
/root/cd-demo/reset-demo.sh
```
