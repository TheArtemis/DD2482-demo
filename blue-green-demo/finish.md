# What blue/green gives us

**Good:** The previous version keeps serving while a candidate starts and passes health and smoke checks. A failed candidate does not take over the live endpoint.

**Limit:** These checks only cover what they test. They may miss broken business behavior or other defects. Unit tests, integration tests, and other CI checks are still needed. This demo runs CI separately; a real release pipeline should require those checks to pass before deployment.
