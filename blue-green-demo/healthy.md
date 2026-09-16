# A healthy release switches traffic

In VSCode, fix the app and give it a new version in `blue-green-demo/assets/app.py`:

```python
VERSION = "v4"
BROKEN = False
```

Push the change to `release`:

```bash
git add blue-green-demo/assets/app.py
git commit -m "Release healthy v4"
git push origin release
```

The VM builds v4 in the inactive slot. Its health and smoke checks pass, then Nginx switches to it. In Killercoda:

```bash
curl -i http://127.0.0.1/
cat /opt/cd-demo/active-slot
```

Expected: **HTTP 200** and v4 on the other slot. [The deployment log]({{TRAFFIC_HOST1_80}}/logs) shows the switch. GitHub Actions should also pass for this commit.
