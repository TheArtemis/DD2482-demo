# Push broken v3 twice

If your GitHub repository has no `release` branch, create it from `main` in your VSCode checkout and push it first. This seeds the branch with v1:

```bash
git switch -c release
git push -u origin release
```

Otherwise, switch to the existing `release` branch and pull it. Wait for the VM log page to finish any v1 deployment before continuing.

## 1. Unsafe release: take the app down

In VSCode, edit `blue-green-demo/assets/app.py` on `release` so it contains:

```python
VERSION = "v3"
BROKEN = True
```

Push from your machine:

```bash
git add blue-green-demo/assets/app.py
git commit -m "Try broken v3 without blue-green"
git push origin release
```

If those two lines were already set from an earlier run, use `git commit --allow-empty -m "Retry broken v3"` before pushing. A new commit is needed because the VM deploys each commit once.

Watch `/logs` until it says the unsafe deployment was rejected. The first deployment stops the live v1 container, runs v3 on the live port, then removes v3 after its health check fails. Nginx has no working app upstream. In the Killercoda terminal, check the failed request:

```bash
curl -i http://127.0.0.1/
```

You should see HTTP 502 after v3 is removed. The deployment log shows the failed health check. The GitHub unit-test workflow should also turn red for this commit; the VM deliberately does not wait for CI in this comparison.

## 2. Restore v1 and enable blue/green

In the **Killercoda terminal**:

```bash
reset
curl -i http://127.0.0.1/
cat /opt/cd-demo/deployment-mode
```

You should see v1, HTTP 200, and `blue-green`. The reset uses the bundled v1 image, so no GitHub push is needed.

## 3. Push the same broken v3 with blue/green

On **your machine**, create another commit while leaving `VERSION = "v3"` and `BROKEN = True`:

```bash
git commit --allow-empty -m "Try broken v3 with blue-green"
git push origin release
```

The VM builds v3 in the inactive slot. Its health check fails, so Nginx keeps pointing to v1. Watch `/logs`, then confirm in the Killercoda terminal:

```bash
curl -i http://127.0.0.1/
cat /opt/cd-demo/active-slot
```

You should still see HTTP 200 and v1. The deployment log shows that the failed health check kept the live slot unchanged.
