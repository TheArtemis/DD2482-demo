# Without blue/green: v3 takes the app down

In VSCode, switch to `release`. Set these lines in `blue-green-demo/assets/app.py`:

```python
VERSION = "v3"
BROKEN = True
```

Push a new commit:

```bash
git add blue-green-demo/assets/app.py
git commit -m "Broken v3 without blue-green"
git push origin release
```

If the file already contains those values, make an empty commit with `git commit --allow-empty -m "Retry broken v3"` and push it.

The unsafe deployer stops the live v1 container before validating v3. V3 fails its health check and is removed, leaving Nginx without an app upstream. Wait for the failure in [the log]({{TRAFFIC_HOST1_80}}/logs), then check in Killercoda:

```bash
curl -i http://127.0.0.1/
```

Expected: **HTTP 502**. The GitHub test for a healthy release also fails, but this VM does not wait for CI before attempting deployment.
