# What the comparison showed

Both pushes contained the same broken v3 app. The unsafe deployment stopped the live v1 container before validation; after v3 failed, Nginx had no working upstream and returned HTTP 502. The reset restored the bundled v1 image and enabled blue/green mode.

With blue/green, the VM started v3 in the inactive slot and checked it before changing Nginx. The failed health check left v1 serving HTTP 200. The deployment log shows the decision, while the Nginx access and error logs show its effect on requests.

GitHub Actions tests run on each push. The v3 commits fail the test that expects a healthy release, but the VM intentionally watches GitHub commits rather than waiting for CI. This keeps the demo focused on the difference between the two deployment strategies.
