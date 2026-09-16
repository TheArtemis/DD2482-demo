# Reflection

You pushed code to a real GitHub branch from your machine. GitHub Actions ran unit tests, while the Killercoda VM independently fetched new `release` commits and deployed them. The VM did not need an inbound webhook: a small service checked GitHub every 10 seconds.

The deployment gate is still visible. Native Nginx switches only after the inactive BLUE or GREEN slot passes its health and smoke checks. A broken v3 remains on GitHub but never becomes the active app; v2 keeps serving traffic.

The unit tests exercise both healthy and broken health responses. They are separate from the live deployment gate, so a green unit-test run does not mean an intentionally unhealthy release will deploy.
