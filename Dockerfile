FROM nousresearch/hermes-agent:v2026.7.30

ARG HIMALAYA_VERSION=v1.2.0
ARG KUBECTL_VERSION=v1.32.3
ARG SHELLCHECK_VERSION=v0.10.0
ARG AGENT_BROWSER_VERSION=0.27.0
ARG PI_PACKAGE=@earendil-works/pi-coding-agent
ARG PI_VERSION=0.74.0

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system packages + python deps + tools — all baked into the image
# hadolint ignore=DL3008
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl \
      git \
      gh \
      jq \
      nodejs \
      npm \
      vim \
      nano \
      htop \
      net-tools \
      iputils-ping \
      chromium \
      python3-pip \
      python3-venv \
      python3-dev \
      build-essential \
      libssl-dev \
      libffi-dev \
      python3-requests \
      python3-yaml \
      python3-pytest \
      bats \
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

# Install shellcheck — detect arch at build time
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      aarch64) SHELLCHECK_ARCH="aarch64" ;; \
      x86_64)  SHELLCHECK_ARCH="x86_64" ;; \
      *)       echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.${SHELLCHECK_ARCH}.tar.xz" \
      | tar xJ -C /usr/local/bin --strip-components=1 shellcheck-${SHELLCHECK_VERSION}/shellcheck

# Install python-dotenv so the Kanban CLI (hermes kanban) works,
# agent-browser globally for Hermes browser automation, and
# pi.dev (https://pi.dev) coding agent for the `coding` profile.
RUN pip3 install --no-cache-dir --break-system-packages "python-dotenv==1.2.2" \
    && npm install -g "agent-browser@${AGENT_BROWSER_VERSION}" \
    && npm install -g "${PI_PACKAGE}@${PI_VERSION}"

ENV AGENT_BROWSER_EXECUTABLE_PATH=/usr/bin/chromium

# Newer upstream Hermes images use s6-overlay and must start as root so
# cont-init hooks can chown the data volume before services drop to hermes.
# Do not add a final USER here; upstream already leaves the image at root.

# Entry point is inherited from the base image — hermes gateway run
