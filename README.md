# yohannaftali/nginx

[![Docker Pulls](https://img.shields.io/docker/pulls/yohannaftali/nginx)](https://hub.docker.com/r/yohannaftali/nginx)
[![Docker Image Size](https://img.shields.io/docker/image-size/yohannaftali/nginx/latest)](https://hub.docker.com/r/yohannaftali/nginx)

[Nginx](https://hub.docker.com/_/nginx) image for production use, built `FROM` the official `nginx` image and rebuilt weekly so it picks up upstream fixes.

- Docker Hub: <https://hub.docker.com/r/yohannaftali/nginx>
- Source code (Dockerfile, build workflow, scripts): <https://github.com/yohannaftali/dockerhub-yohannaftali-nginx>
- Issues and feature requests: <https://github.com/yohannaftali/dockerhub-yohannaftali-nginx/issues>

## Use this image

No build needed. Pull the prebuilt image straight from Docker Hub:

```bash
docker pull yohannaftali/nginx
```

Or reference it in your `docker-compose.yml`:

```yaml
services:
  web:
    image: yohannaftali/nginx:latest
```

## Overview

The image currently adds only metadata (OCI labels) on top of the official image. Entrypoint, configuration paths, ports and environment behave exactly like the official image, so see its [documentation](https://hub.docker.com/_/nginx) for full usage.

## Tags

| Tag | Base image |
| --- | --- |
| `latest` | `nginx:latest` (mainline) |
| `stable` | `nginx:stable` |

## Quick start

```bash
docker run -d --name nginx -p 8080:80 yohannaftali/nginx:latest
curl -I http://localhost:8080
```

### docker-compose with your own config

```yaml
services:
  web:
    image: yohannaftali/nginx:latest
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./conf.d:/etc/nginx/conf.d:ro
      - ./logs:/var/log/nginx
```

## Build (maintainers)

```bash
docker login

# latest
docker build -t yohannaftali/nginx:latest .

# specific nginx tag
docker build --build-arg NGINX_VERSION=stable -t yohannaftali/nginx:stable .

docker push yohannaftali/nginx --all-tags
```

Multi-arch (amd64 + arm64):

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  --build-arg NGINX_VERSION=stable \
  -t yohannaftali/nginx:stable --push .
```

## Automated publishing

`.github/workflows/docker-publish.yml` builds and pushes the images on every push to `main`, weekly (to pick up upstream security fixes), and on manual dispatch. It also syncs this README to the Docker Hub **overview** and the short **description**.

Required GitHub repository secrets:

| Secret | Value |
| --- | --- |
| `DOCKERHUB_USERNAME` | `yohannaftali` |
| `DOCKERHUB_TOKEN` | Docker Hub access token with *Read, Write, Delete* scope |

To change which nginx tags are published, edit the `version` matrix in the workflow and the Tags table above.

## Maintaining the Docker Hub repository

- **Overview**: synced from this `README.md` by the workflow.
- **Short description**: set in the workflow (`short-description`), max 100 characters.
- **Manual sync / status**: see [Maintenance scripts](#maintenance-scripts).
- **Category**: not exposed through the API; set manually in *Repository → Settings → Categories*.
- **Tags**: remove stale tags in *Repository → Tags*.

## Maintenance scripts

Helper scripts in `scripts/` manage the Docker Hub repository from your machine. They need [uv](https://docs.astral.sh/uv/) and a `.env` file (copy `.env.example`) with `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`. There are no other dependencies.

| Command | Action |
| --- | --- |
| *(none)* / `sync` | Push `README.md` as the overview and set the short description |
| `status` | Show description, categories, pull and star counts |
| `tags` | List tags with last update and size |
| `delete-tag <tag>` | Delete a tag |

Bash:

```bash
./scripts/dockerhub-update.sh            # sync
./scripts/dockerhub-update.sh status
./scripts/dockerhub-update.sh tags
./scripts/dockerhub-update.sh delete-tag stable
```

PowerShell:

```powershell
.\scripts\dockerhub-update.ps1            # sync
.\scripts\dockerhub-update.ps1 status
.\scripts\dockerhub-update.ps1 tags
.\scripts\dockerhub-update.ps1 delete-tag stable
```

Both wrappers call `scripts/dockerhub_update.py` through `uv run`. Set `DOCKERHUB_REPO` to target a repository other than `nginx`.

## Source and contributing

The Dockerfile, GitHub Actions workflow and maintenance scripts live at <https://github.com/yohannaftali/dockerhub-yohannaftali-nginx>. Open an issue there to request a new nginx tag or report a problem.

## License

The Dockerfile in this repository is provided as-is. Nginx is licensed under the 2-clause BSD license; see the [official image](https://hub.docker.com/_/nginx) for details.
