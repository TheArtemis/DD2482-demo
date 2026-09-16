# Without blue/green: v3 takes the app down

The release branch contains a broken v3 candidate:

```python
VERSION = "v3"
BROKEN = True
```

The unsafe deployer stops live v1 before validating v3. The candidate fails its health check and is removed, leaving Nginx without an app upstream.

**Result:** The app returns **HTTP 502**. The deployment log at `/logs` shows the failure. GitHub Actions stays green because the unit tests verify both healthy and broken responses; they do not approve a release for live traffic.
