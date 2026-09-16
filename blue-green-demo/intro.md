# GitHub-powered continuous deployment

This VM starts with the bundled v1 app. A service checks the GitHub `release` branch every 10 seconds. When it sees a new commit, it fetches the app files and runs the blue/green deployment. Pushes happen from **your own machine**.

```text
Your machine -> GitHub release branch -> VM poller -> inactive BLUE/GREEN slot -> Nginx
                    |-> GitHub Actions unit tests
```

Killercoda reads the scenario from `main`. The app poller reads `release`; it does not need another webhook or a GitHub credential on the VM if the repository is public. The first `release` push can happen after this scenario starts.

Check the starting state:

```bash
curl -s http://127.0.0.1:8001/
curl -s http://127.0.0.1:8002/
curl -s http://127.0.0.1/ | grep -E 'Version|Slot'
systemctl status cd-demo-watch --no-pager
```

Open the public endpoint here: {{TRAFFIC_HOST1_80}}
