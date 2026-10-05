# AGENTS.md

> **READ THIS FIRST.** Every AI agent working in this repository (Claude, Gemini, Copilot,
> Cursor, ...) must read this file before doing anything else. It is the single source of
> truth for what this project is and how to work on it. After any structural change
> (new file, new workflow, new tag, changed secret), update this file in the same change.
>
> **Compaction rule:** keep this file describing the *current* state. Put dated history in
> [`CHANGE_HISTORY.md`](CHANGE_HISTORY.md).

## Repository

- remote: https://github.com/yohannaftali/dockerhub-yohannaftali-nginx
- platform: GitHub (use the `gh` CLI; it is already authenticated on the maintainer's machine)
- default branch: `main`
- Docker Hub image: `yohannaftali/nginx` (https://hub.docker.com/r/yohannaftali/nginx)

## Big Picture

A tiny repo that builds and publishes an [nginx](https://hub.docker.com/_/nginx) image
for production use. There is no application code: the product
is the Docker Hub image and its listing (overview, short description, tags, categories).

```
Dockerfile ──► GitHub Actions (build matrix, amd64+arm64) ──► Docker Hub yohannaftali/nginx
README.md  ──► peter-evans/dockerhub-description / scripts/dockerhub-update.sh ──► Hub overview
```

## Repository Layout

```
Dockerfile                       # FROM nginx:${NGINX_VERSION}; OCI labels
README.md                        # human docs AND the Docker Hub overview (synced as-is)
AGENTS.md / CHANGE_HISTORY.md    # agent guide / dated history
CLAUDE.md                        # points agents at this file
.env.example                     # variable names only; real .env is git-ignored
.github/workflows/docker-publish.yml   # build+push matrix, then description sync
scripts/dockerhub_update.py      # Docker Hub API helper (stdlib only, run via uv)
scripts/dockerhub-update.sh|.ps1 # bash / PowerShell wrappers around `uv run`
.claude/skills/                  # planner, coder, tester, reviewer (see below)
```

## Key Facts

- **Tags** are the `version` matrix in `docker-publish.yml`: `latest`, `stable`.
  Adding or dropping a version means editing that matrix **and** the Tags table in `README.md`.
- The workflow runs on push to `main`, weekly (Mon 03:00 UTC, to pick up upstream fixes) and
  manually. The `description` job syncs `README.md` to Docker Hub after all builds pass.
- **Secrets** (GitHub repo secrets): `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (Docker Hub PAT,
  scope *Read, Write, Delete*; description updates need Delete scope).
- **Categories cannot be set via the Docker Hub API** (it silently ignores them). They are set
  by hand in the web UI. Current: *Developer tools*, *Web servers*.
- **Legacy duplicate Docker Hub repos** (`yohannaftali/yohannaftali-nginx`) are older names for `yohannaftali/nginx`. Other apps still pull them, so they cannot be deleted. They are **frozen**: their overview carries a DEPRECATED notice pointing here (set 2026-10-05) and nothing may be pushed to them (apps may depend on its exact contents). Maintain only `yohannaftali/nginx`.
- `README.md` is published verbatim as the Hub overview: keep it self-contained, no
  repo-relative links that only work on GitHub.

## Conventions & Guardrails

- Never commit `.env` or any token. `.env.example` holds names and placeholders only.
- Never print tokens in output, logs or commit messages. Refer to them as `$TOKEN`.
- Keep the Dockerfile minimal: labels only for now (a logrotate setup is commented out and
  unfinished). Other behavior belongs to the
  upstream image; do not fork its entrypoint.
- Pinned versions go through the `NGINX_VERSION` build arg, not separate Dockerfiles.
- Python scripts are stdlib-only and run through `uv` (`uv run scripts/dockerhub_update.py`);
  bash and PowerShell wrappers must stay thin and behave identically.
- Commit message ends with the attribution trailer configured for the session.
- Pushing to `main` publishes images to Docker Hub. Treat it as a release.

## Validation (before pushing)

```bash
docker build -t nginx-test .
docker run --rm nginx-test nginx -t                   # config valid
docker build --build-arg NGINX_VERSION=stable -t nginx-test:stable .
uv run scripts/dockerhub_update.py status             # needs .env; read-only
```

See the `tester` skill for the full smoke test (container starts and serves HTTP 200).

## Agent Skills (`.claude/skills/`)

Adapted from the Senar project for a single-image repo (no issue-tracker UI, no browser).

- **`planner`**: create/track GitHub issues with `gh`; checks `CHANGE_HISTORY.md` for
  duplicates and keeps the Tracked Issues table below current.
- **`coder`**: implements an issue (Dockerfile, workflow, scripts, README) per these rules.
- **`tester`**: builds the image locally, smoke-tests it, and only then opens/merges a PR.
- **`reviewer`**: post-merge audit of what landed on `main` and on Docker Hub.

Flow: `planner` -> `coder` -> `tester` -> `reviewer`.

## Tracked Issues

| ID | Title | Status | Last Checked |
|----|-------|--------|--------------|

## Change Log Policy

- `AGENTS.md`: current architecture and rules only.
- `CHANGE_HISTORY.md`: one dated entry per notable change, newest first.
- Any agent making a structural change updates both files in the same change.
