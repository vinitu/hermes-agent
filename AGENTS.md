# AGENTS.md

## Purpose

This repository builds and releases a custom `ghcr.io/vinitu/hermes-agent` image on top of `nousresearch/hermes-agent`.

The repo is intentionally small:

- `Dockerfile` defines the image contents.
- `README.md` documents what is baked into the image and how releases work.
- `.github/workflows/` handles PR checks, tagging, image publishing, and release creation.
- `Makefile` provides local build and push shortcuts.

## Working Rules

- Keep changes minimal and centered on image composition, release flow, or documentation.
- Treat the `FROM nousresearch/hermes-agent:<tag>` line in `Dockerfile` as the source of truth for the upstream Hermes version.
- When adding or removing baked-in tools, update `README.md` in the same change.
- Prefer pinned versions for externally downloaded binaries where the Dockerfile already uses `ARG` values.
- Avoid changing CI tag-generation logic unless the release process itself is the task.

## Dockerfile Conventions

- Keep package installation non-interactive and clean up apt metadata in the same layer.
- Prefer `--no-install-recommends` for apt packages unless a recommended dependency is required.
- Keep architecture-specific install logic explicit, as done for `himalaya`, `kubectl`, and `shellcheck`.
- If a tool depends on a system browser or runtime, configure it in the image so Hermes can use it without first-run setup.
- Add short comments only where they explain non-obvious build decisions.

## Validation

For changes to the image or build tooling, use the smallest relevant checks:

1. Read the affected workflow or build file before editing.
2. Run a local Docker build when the change affects `Dockerfile`, installed packages, or image startup behavior.
3. If documentation changed, verify it matches the actual image contents and release flow.

Useful commands:

```bash
docker buildx build --platform linux/arm64 -t hermes-agent:test --load .
hadolint Dockerfile
make build-arm64
```

## CI Notes

- PR workflow only determines version bump and can auto-merge matching PRs.
- Pushes to `main` lint the Dockerfile, compute a release tag from the upstream Hermes tag, build/push an `arm64` image, and publish a GitHub release.
- Repository tags may be either the upstream Hermes tag itself or `<base-tag>-build.N` if that tag already exists in this repo.

## Common Tasks

- Bump upstream Hermes version: update the `FROM` tag, then ensure README and release expectations still match.
- Add a built-in tool: install it in `Dockerfile`, document it in `README.md`, and verify the image still builds.
- Adjust release behavior: inspect both GitHub workflows before editing, because `ci-main.yml` and `ci-pr.yml` split responsibilities.
