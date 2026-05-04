FROM nousresearch/hermes-agent:v2026.4.30

ARG HIMALAYA_VERSION=v1.2.0
ARG KUBECTL_VERSION=v1.32.3

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system packages + python deps + tools — all baked into the image
# hadolint ignore=DL3008
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl \
      jq \
      vim \
      nano \
      htop \
      net-tools \
      iputils-ping \
      python3-pip \
      python3-venv \
      python3-dev \
      build-essential \
      libssl-dev \
      libffi-dev \
      python3-requests \
      python3-yaml \
    && rm -rf /var/lib/apt/lists/*

# Install himalaya (email CLI) — detect arch at build time
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      aarch64) HIMALAYA_ARCH="aarch64" ;; \
      x86_64)  HIMALAYA_ARCH="x86_64" ;; \
      *)       echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/pimalaya/himalaya/releases/download/${HIMALAYA_VERSION}/himalaya.${HIMALAYA_ARCH}-linux.tgz" \
      | tar xz -C /usr/local/bin himalaya && \
    chmod +x /usr/local/bin/himalaya

# Install kubectl — detect arch at build time
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      aarch64) KUBECTL_ARCH="arm64" ;; \
      x86_64)  KUBECTL_ARCH="amd64" ;; \
      *)       echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

# Install Python deps into the hermes venv (needed for Holographic memory provider)
# hadolint ignore=DL3013
RUN /opt/hermes/.venv/bin/pip install --no-cache-dir numpy

USER hermes

# Entry point is inherited from the base image — hermes gateway run