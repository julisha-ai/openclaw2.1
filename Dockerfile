FROM node:22-bookworm

# Install Bun (used for build scripts)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Enable Corepack for pnpm
RUN corepack enable

# Create app directory
WORKDIR /app

# Optional: install extra packages
ARG OPENCLAW_DOCKER_APT_PACKAGES=""
RUN if [ -n "$OPENCLAW_DOCKER_APT_PACKAGES" ]; then \
      apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $OPENCLAW_DOCKER_APT_PACKAGES && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*; \
    fi

# Copy lockfiles and config
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY patches ./patches
COPY scripts ./scripts

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy remaining source files
COPY . .

# Build backend and UI
RUN OPENCLAW_A2UI_SKIP_MISSING=1 pnpm build
ENV OPENCLAW_PREFER_PNPM=1
RUN pnpm ui:build

# Add the custom entrypoint for Cloud Run
COPY cloudrun-entrypoint.sh /app/cloudrun-entrypoint.sh
RUN chmod +x /app/cloudrun-entrypoint.sh

# Environment settings
ENV NODE_ENV=production

# Switch to non-root user for security
RUN chown -R node:node /app
USER node

# Set entrypoint for Cloud Run (uses your dynamic config logic)
CMD ["/app/cloudrun-entrypoint.sh"]
