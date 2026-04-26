.PHONY: build build-arm64 build-amd64 push help

IMAGE ?= ghcr.io/vinitu/hermes-agent
TAG  ?= latest

build-arm64:
	docker buildx build --platform linux/arm64 -t $(IMAGE):$(TAG) --load .

build-amd64:
	docker buildx build --platform linux/amd64 -t $(IMAGE):$(TAG) --load .

build: build-arm64

push:
	docker push $(IMAGE):$(TAG)

help:
	@echo "Targets:"
	@echo "  build-arm64   Build image for arm64 (default for homelab)"
	@echo "  build-amd64   Build image for amd64"
	@echo "  push          Push image to registry"
	@echo ""
	@echo "Variables:"
	@echo "  IMAGE  Registry image name (default: ghcr.io/vinitu/hermes-agent)"
	@echo "  TAG    Image tag (default: latest)"