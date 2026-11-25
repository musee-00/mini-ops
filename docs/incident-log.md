# Incident log

## 2026-11-25 – Planned outage test (web)
- **Detected:** 23:02:31 by Uptime Kuma (monitor "mini-ops web" went Down, "timeout exceeded")
- **Cause:** Web container stopped on purpose with `docker stop web` to test alerting
- **Action:** Restarted with `docker start web`
- **Result:** Monitor back to Up, alerting confirmed working
