# What blue/green gives us

**Good:** The previous version keeps serving while a candidate starts and passes health and smoke checks. A failed candidate does not take over the live endpoint.

**Limit:** Health and smoke checks only cover what they request. The unit tests in this demo pass for both `BROKEN` settings because they verify both responses; they do not decide whether a release is safe. A real pipeline needs tests that check release requirements and must pass before deployment.
