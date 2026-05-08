# Hermes Agent — Custom Image

Pre-baked Docker image for [Hermes Agent](https://github.com/NousResearch/hermes-agent) with all tools built-in, so Kubernetes pods start instantly instead of spending minutes installing packages at runtime.

## What's included (on top of base hermes-agent)

| Tool | Purpose |
|------|---------|
| `curl`, `jq` | HTTP calls & JSON parsing |
| `git`, `gh` | Git and GitHub CLI workflows |
| `vim`, `nano` | Quick edits inside pod |
| `htop`, `net-tools`, `iputils-ping` | Debugging |
| `kubectl` (v1.32.3) | Kubernetes management |
| `himalaya` (v1.2.0) | Email CLI |
| `python3` + pip, venv, requests, yaml | Python runtime |

## Usage

```yaml
image: ghcr.io/vinitu/hermes-agent:<release-tag>
```

## CI/CD

Push to `main` → GitHub Actions reads the upstream Hermes Agent tag from `Dockerfile` → builds a multi-arch image → pushes that release tag and `latest` to GHCR.

If the upstream tag already exists in this repository, CI appends a build suffix:

```text
v2026.5.7
v2026.5.7-build.1
v2026.5.7-build.2
```

## Build locally

```bash
make build-arm64    # for homelab (ARM64)
make build-amd64    # for AMD64
```
