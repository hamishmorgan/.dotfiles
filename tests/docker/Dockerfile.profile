# Dockerfile for profiling dot health command and BATS tests
# Uses strace (Linux equivalent of dtruss) for system call profiling
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for dotfiles + profiling tools + BATS
RUN apt-get update && apt-get install -y \
    bash \
    git \
    stow \
    strace \
    time \
    bc \
    perl \
    tmux \
    zsh \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install BATS from source (Ubuntu package may be outdated)
RUN git clone https://github.com/bats-core/bats-core.git /tmp/bats-core && \
    cd /tmp/bats-core && \
    ./install.sh /usr/local && \
    rm -rf /tmp/bats-core

# Create test user (non-root for realistic testing)
RUN useradd -m -s /bin/bash testuser

# Set up git config (required for tests)
RUN git config --global user.name "Test User" && \
    git config --global user.email "test@example.com"

# Switch to test user
USER testuser
WORKDIR /workspace

# Make dot executable (will be mounted as volume)
# Note: dotfiles will be mounted at runtime

# Default command - can be overridden
CMD ["./dot", "health"]

