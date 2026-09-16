# With blue/green: v1 stays live

With blue/green enabled, the same broken v3 candidate starts in the inactive slot. Its health check fails, so Nginx keeps sending traffic to v1.

**Result:** The app still returns **HTTP 200** and shows v1. The deployment log at `/logs` shows the rejected candidate even though the unit tests pass.
