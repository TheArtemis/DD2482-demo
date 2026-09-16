# A healthy release switches traffic

The next candidate is healthy v4:

```python
VERSION = "v4"
BROKEN = False
```

The VM builds v4 in the inactive slot. Its health and smoke checks pass, then Nginx switches traffic to it.

**Result:** The app returns **HTTP 200** and shows v4 on the other slot. The deployment log at `/logs` shows the switch, and GitHub Actions passes.
