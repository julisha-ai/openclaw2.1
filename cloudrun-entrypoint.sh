#!/bin/sh
set -eu

# Cloud Run injects PORT; default locally to 8080 if missing.
PORT="${PORT:-8080}"

# Require a password to protect the public endpoint.
: "${OPENCLAW_GATEWAY_PASSWORD:?Set OPENCLAW_GATEWAY_PASSWORD in Cloud Run env vars}"

# Generate the dynamic OpenClaw config for Cloud Run
cat > /app/openclaw.cloudrun.json5 <<EOF
{
  gateway: {
    mode: "local",
    port: ${PORT},
    bind: "0.0.0.0",  // Important: expose to all interfaces

    controlUi: { enabled: true },

    auth: {
      mode: "password",
      password: "${OPENCLAW_GATEWAY_PASSWORD}"
    }
  }
}
EOF

export OPENCLAW_CONFIG_PATH=/app/openclaw.cloudrun.json5

# Print debug info
echo "===================================================="
echo "🟢 Starting OpenClaw Gateway"
echo "PORT: $PORT"
echo "Using config file at: $OPENCLAW_CONFIG_PATH"
cat "$OPENCLAW_CONFIG_PATH"
echo "===================================================="

# Optional: Validate entrypoint (can help debug dist/index.js issues)
if ! node --check dist/index.js; then
  echo "❌ JavaScript file dist/index.js has syntax or build errors!"
  exit 1
fi

# Default behavior if no custom command provided
if [ "$#" -eq 0 ]; then
  set -- gateway run --verbose
fi

# Start the Gateway
exec node dist/index.js "$@"
