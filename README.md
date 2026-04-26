# Hermes Agent — Custom Image

Pre-baked Docker image for [Hermes Agent](https://github.com/NousResearch/hermes-agent) with all tools built-in, so Kubernetes pods start instantly instead of spending minutes installing packages at runtime.

## What's included (on top of base hermes-agent)

| Tool | Purpose |
|------|---------|
| `curl`, `jq` | HTTP calls & JSON parsing |
| `vim`, `nano` | Quick edits inside pod |
| `htop`, `net-tools`, `iputils-ping` | Debugging |
| `kubectl` (v1.32.3) | Kubernetes management |
| `himalaya` (v1.2.0) | Email CLI |
| `python3` + pip, venv, requests, yaml | Python runtime |

## Usage

```yaml
image: ghcr.io/vinitu/hermes-agent:v0.1.0
```

## CI/CD

Push a tag → GitHub Actions builds multi-arch image → pushes to GHCR.

| Branch prefix | Version bump |
|---------------|-------------|
| `major/` | major |
| `feature/` | minor |
| `fix/` | patch |

## Build locally

```bash
make build-arm64    # for homelab (ARM64)
make build-amd64    # for AMD64
```