# Reflection

The demonstration compressed a usual production topology:

```text
Production: GitHub -> CI/CD runner -> registry -> production host
This demo:  working copy -> bare Git repo -> hook -> production
```

That makes the experiment deterministic and small enough to show in seven minutes. The safety property remains visible: native Nginx only switches after the inactive BLUE or GREEN slot has passed its health check and smoke test. A failed v3 therefore leaves v2 serving traffic, while the previous container remains available for a fast rollback.

For production, replace the local hook with CI, use an image registry, add authentication/TLS and durable observability.
