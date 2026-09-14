# DD2482-demo

The KillerCoda scenario is in [blue-green-demo](blue-green-demo/). It demonstrates a local, deterministic continuous-deployment pipeline:

```text
working repository -> bare Git repository -> post-receive hook -> BLUE/GREEN deployment -> Nginx
```

GitHub is used only to publish the KillerCoda scenario; it is deliberately outside the live deployment path.
