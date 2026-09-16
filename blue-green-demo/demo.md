# Push v2, then watch v3 fail safely

On **your own machine**, create `release` from the current repository if it does not exist yet:

```bash
git switch -c release
git push -u origin release
```

If `release` already exists, switch to it and pull its latest commit instead. The GitHub Actions workflow runs unit tests on each push.

In your local checkout, change `VERSION` to `"v2"` in `blue-green-demo/assets/app.py`, then push:

```bash
git add blue-green-demo/assets/app.py
git commit -m "Release v2"
git push origin release
```

The VM polls every 10 seconds; the Docker build can take longer. In the **Killercoda terminal**, watch the deployment and confirm the result:

```bash
journalctl -u cd-demo-watch -f
curl -s http://127.0.0.1/ | grep -E 'Version|Slot'
cat /opt/cd-demo/active-slot
```

Press Ctrl+C to stop following the log. The release starts the inactive slot, checks `/health` and `/`, then switches Nginx only after both checks pass.

Back on **your machine**, set `VERSION = "v3"` and `BROKEN = True` in `blue-green-demo/assets/app.py`, then push:

```bash
git add blue-green-demo/assets/app.py
git commit -m "Attempt broken v3"
git push origin release
```

The VM attempts this commit once. Its health check rejects v3, leaving v2 serving traffic. Check in Killercoda:

```bash
journalctl -u cd-demo-watch -n 30 --no-pager
curl -s http://127.0.0.1/ | grep -E 'Version|Slot'
curl -i http://127.0.0.1/health
```

To run the demo again, push a new commit on `release` that restores `VERSION = "v1"` and `BROKEN = False`.
