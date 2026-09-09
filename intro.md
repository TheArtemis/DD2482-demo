# Local continuous deployment

This VM is deliberately self-contained. GitHub stores the KillerCoda scenario, but it is **not** in the live deployment path.

```text
/root/cd-demo (working repository)
        | git push production main
        v
/opt/git/cd-demo.git (bare repository)
        | post-receive hook
        v
/opt/cd-demo/deploy.sh
        | build, start inactive slot, validate, switch proxy
        v
native Nginx :80  -->  BLUE :8001  or  GREEN :8002
```

The setup script has already committed and pushed release `v1`, then started the other slot manually so both fixed mappings are visible:

```bash
curl -s http://127.0.0.1:8001/
curl -s http://127.0.0.1:8002/
curl -s http://127.0.0.1/ | grep -E 'Version|Slot'
```

Open the public endpoint here: {{TRAFFIC_HOST1_80}}

Only `VERSION` and `BROKEN` in `app.py` change during the demonstration. Continue to the next step to release v2 and prove that an unhealthy release is not switched into production.
