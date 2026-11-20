---
name: updater
description: >
  Rebuilds yohannaftali/nginx from the newest upstream nginx images and publishes them to
  Docker Hub, without any code change. Pulls latest/stable locally, smoke-tests them, then
  triggers the publish workflow and verifies the result. Use for "update nginx", "pull latest
  and publish", "refresh the image", "/updater", or when an upstream nginx release should ship
  before the weekly Monday rebuild.
---

# Updater Skill

The Dockerfile builds `FROM nginx:${NGINX_VERSION}` and the workflow matrix publishes every
tag in it (currently `latest`, `stable`). So "updating" never needs a commit: pull the newest
upstream images, verify them, and re-run the publish workflow. Publishing to Docker Hub is a
release; only do it when the user asked for an update.

## Step 1 — Load conventions
Read `AGENTS.md`. Take the tag list from the `version` matrix in
`.github/workflows/docker-publish.yml` (do not hardcode it). Never touch the frozen legacy
repo `yohannaftali/yohannaftali-nginx`.

## Step 2 — Prerequisites
- `docker info` works. If not, stop and say so; do not publish untested images.
- `gh auth status` succeeds.
- `git fetch origin && git status -sb`: on `main`, in sync with `origin/main`. The workflow
  builds `origin/main`, so unpushed local changes would not be what ships; if there are any,
  stop and tell the user (code changes go through `coder` -> `tester`).
- `gh run list -L 3 --workflow docker-publish.yml`: if a run is already in progress, watch it
  instead of starting another.

## Step 3 — Pull and smoke-test every tag
For each tag `<v>` in the matrix:
```bash
docker build --pull --build-arg NGINX_VERSION=<v> -t nginx-update:<v> .
docker run --rm nginx-update:<v> nginx -v                 # record the version
docker run --rm nginx-update:<v> nginx -t                 # config is valid
docker run -d --name nginx-update -p 8080:80 nginx-update:<v>
curl -sI http://localhost:8080 | head -1                   # expect HTTP/1.1 200 OK
docker rm -f nginx-update
```
`--pull` is required so the local build uses the newest upstream base, not a cached one.
If any tag fails, stop: do not publish, report the exact command and output.

Optionally compare with what is live to tell the user whether anything actually changes:
```bash
docker pull -q yohannaftali/nginx:<v> && docker run --rm yohannaftali/nginx:<v> nginx -v
```
If every tag is already on the same version, still publish if the user asked (upstream may
ship OS/security fixes under the same nginx version), but say so.

## Step 4 — Publish
```bash
gh workflow run docker-publish.yml --ref main
gh run list -L 1 --workflow docker-publish.yml      # get the new run id (wait a few seconds)
gh run watch <id> --exit-status
```
The workflow builds amd64+arm64 for every tag, pushes to `yohannaftali/nginx`, then syncs
`README.md` to the Hub overview. If it fails, show `gh run view <id> --log-failed` and stop;
do not retry blindly.

## Step 5 — Verify on Docker Hub
For each tag: `docker pull yohannaftali/nginx:<v>` and `nginx -v` should match Step 3.
`uv run scripts/dockerhub_update.py tags` (needs `.env`, read-only) shows the push times.

## Step 6 — Clean up and report
Remove the `nginx-update:*` images and any test container. Report a table of tag ->
nginx version -> platforms, the run URL, and any workflow annotations (e.g. deprecations).
No commit is needed for a plain update; only add a `CHANGE_HISTORY.md` entry if the user asks
or something notable happened (a new upstream major version, a failure).

## Notes
Never print tokens. Never push to `main` or edit files as part of an update; if the update
requires a change (new tag, broken build), hand it to `planner`/`coder` instead.
