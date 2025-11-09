# Use Ubuntu as base image for broader compatibility
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    python3 \
    python3-pip \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Install Node.js and npm (needed for Claude-Flow)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude CLI (official Anthropic CLI if available, or placeholder for community tools)
# Note: Installing claude-cli npm package as a reference
RUN npm install -g @anthropic-ai/claude-cli 2>/dev/null || echo "Claude CLI not available via npm, will be configured in setup script"

# Set working directory
WORKDIR /workspace

# Switch back to dialog for any interactive operations
ENV DEBIAN_FRONTEND=dialog
