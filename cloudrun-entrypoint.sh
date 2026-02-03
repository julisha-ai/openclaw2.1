#!/bin/sh
set -eu

# 1. Cloud Run provides this — fallback for local dev.
PORT="${PORT:-8080}"

# 2. Exit with an error if this required secret is not set in Cloud Run.
: "${OPENCLAW_GATEWAY_PASSWORD:?Set OPENCLAW_GATEWAY_PASSWORD in Cloud Run env vars}"

# 3. Build the minimal config file using PORT and injected password
cat > /app/openclaw.cloudrun.json5 <<EOF
{
  gateway: {
    mode: "local",
    port: ${PORT},
    bind: "lan",

    // Serve Control UI (dashboard)
    controlUi: { enabled: true },

    // Require auth with password for public access
    auth: {
      mode: "password",
      password: "${OPENCLAW_GATEWAY_PASSWORD}"
    }
  }
}
EOF

# 4. Export config path for the gateway to pick up
export OPENCLAW_CONFIG_PATH=/app/openclaw.cloudrun.json5

# 5. Default to running the gateway unless args override
if [ "$#" -eq 0 ]; then
  set -- gateway --verbose
fi

# 6. Print logs for debugging in Cloud Run
echo "PORT=$PORT"
echo "Using config at: $OPENCLAW_CONFIG_PATH"
echo "Config contents:"
cat "$OPENCLAW_CONFIG_PATH"
echo "Starting: node dist/index.js gateway run --verbose"

echo "Generated Gateway Config:"
cat /app/openclaw.cloudrun.json5
echo "Launching Gateway..."

# 7. Start the gateway
exec node dist/index.js "$@"
