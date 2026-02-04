#!/bin/sh
set -eu

PORT="${PORT:-8080}"
: "${OPENCLAW_GATEWAY_PASSWORD:?Set OPENCLAW_GATEWAY_PASSWORD in Cloud Run env vars}"

# Write a dynamic config that uses the Cloud Run PORT
cat > /app/openclaw.cloudrun.json5 <<EOF
{
  gateway: {
    mode: "local",
    port: ${PORT},
    bind: "0.0.0.0",
    controlUi: { enabled: true },
    auth: {
      mode: "password",
      password: "${OPENCLAW_GATEWAY_PASSWORD}"
    }
  }
}
EOF

export OPENCLAW_CONFIG_PATH=/app/openclaw.cloudrun.json5

echo "===================================================="
echo "🟢 Starting OpenClaw Gateway"
echo "PORT: $PORT"
echo "Using config file at: $OPENCLAW_CONFIG_PATH"
cat "$OPENCLAW_CONFIG_PATH"
echo "===================================================="

# Optional sanity check
if ! node --check dist/index.js; then
  echo "❌ JavaScript file dist/index.js has syntax or build errors!"
  exit 1
fi

# If no arguments passed, default to `gateway run --verbose`
if [ "$#" -eq 0 ]; then
  set -- gateway run --verbose
fi

# ✅ Corrected: Run your CLI entrypoint with arguments
echo "📦 Executing: node dist/index.js $@"
exec node dist/index.js "$@"
