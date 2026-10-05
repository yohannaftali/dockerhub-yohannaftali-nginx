# CHANGE_HISTORY.md

Newest first. One dated entry per notable change.

## [2026-10-05] — chore: categories set
- Docker Hub categories set manually: *Developer tools*, *Web servers* (verified via `scripts/dockerhub_update.py status`).

## [2026-10-05] — chore: apply the MariaDB repo's setup
- `Dockerfile`: `NGINX_VERSION` build arg, OCI labels (kept the existing `github` label and the commented-out logrotate draft).
- `.github/workflows/docker-publish.yml`: matrix `latest`/`stable`, amd64+arm64, weekly + on push + manual, then syncs README to the Hub overview. This rebuilds `latest`, last pushed 2023-09-05.
- `README.md` (renamed from `readme.md` so the workflow path matches on Linux): overview, tags, usage, GitHub source links, maintenance scripts. Replaces the 2-line stub with the wrong Hub URL.
- Added `scripts/` (uv-run Docker Hub helper plus bash/PowerShell wrappers), `.env.example`, `.gitignore`, `CLAUDE.md`, `AGENTS.md`, and `.claude/skills/` (`planner`, `coder`, `tester`, `reviewer`), all adapted from `dockerhub-yohannaftali-mariadb`.
- Docker Hub category still to be set manually in the web UI.

## Earlier
- `Dockerfile` `FROM nginx:latest` with a `github` source label and an unfinished, commented-out logrotate setup; published once as `yohannaftali/nginx:latest` (2023-09-05).
