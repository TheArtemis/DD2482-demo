# Without blue/green: v3 takes the app down

The release branch contains a broken v3 candidate:

```python
VERSION = "v3"
BROKEN = True
```

The unsafe deployer stops live v1 and starts v3 on the same port. It does no health check, so the broken app stays live.

**Result:** The app returns **HTTP 500**. The deployment log at `/logs` shows that v3 went live without validation. GitHub Actions stays green because the unit tests verify both healthy and broken responses; they do not approve a release for live traffic.
