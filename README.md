# mini-ops

A small self-hosted operations environment, built to practise the daily work of running Linux services: containers, monitoring, backups with restore tests, patching, automation and documentation.

Runs in GitHub Codespaces (Ubuntu 24.04) with Docker Compose.

## Architecture

| Service | Image | Port | Purpose |
|---|---|---|---|
| web | nginx:1.27-alpine | 8080 | Static website (site/) |
| monitor | louislam/uptime-kuma:1 | 3001 | Uptime monitoring and alerts |

## Repository layout

| Path | Content |
|---|---|
| docker-compose.yml | Service definitions |
| site/ | Website content |
| scripts/backup.sh | Backup with SHA-256 checksum and retention of the 7 latest backups |
| scripts/restore-test.sh | Verifies that the latest backup can actually be restored |
| scripts/update.sh | Safe update routine: backup, patch, health check, log |
| ansible/ | Playbook that sets up and verifies the environment |
| docs/ | Incident log, update log and restore test log |

## Quick start

    docker compose up -d
    curl http://localhost:8080

Uptime Kuma runs on port 3001. The HTTP monitor checks http://web:80, since containers reach each other by service name on the Docker network.

## Backups

    ./scripts/backup.sh
    ./scripts/restore-test.sh

The restore test verifies the checksum, compares the restored files with the originals, confirms that the monitoring database is included, and serves the restored site on port 8081. Results are appended to docs/restore-tests.log.

## Updates

    ./scripts/update.sh

Order: backup first, then system packages (apt), then container images, then a health check. Every run is logged in docs/update-log.md.

## Automation (Ansible)

    ansible-playbook -i ansible/inventory.ini ansible/site.yml

The playbook ensures folders, script permissions and .gitignore rules, starts the containers and checks that the website responds. It is idempotent: a second run reports changed=0.

## Runbook: website down

1. Check the alert in Uptime Kuma and note the time.
2. Run `docker ps` to see if the web container is running.
3. Check the logs: `docker logs web --tail 50`
4. Restart: `docker start web` or `docker compose up -d`
5. Verify with `curl http://localhost:8080` and wait for the monitor to turn green.
6. If the site content is broken, restore it from the latest backup.
7. Document what happened in docs/incident-log.md.

## Author

Musee Mengsteab – B.Sc. Computer Engineering (Embedded Systems), Jönköping University
github.com/musee-00
