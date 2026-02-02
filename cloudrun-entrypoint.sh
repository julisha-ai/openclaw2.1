#!/bin/sh
set -eu

# Cloud Run injects PORT; default locally to 8080 if missing.
PORT="${PORT:-8080}"

# Require a password so the public service isn’t open to everyone.
: "${OPENCLAW_GATEWAY_PASSWORD:?Set OPENCLAW_GATEWAY_PASSWORD in Cloud Run env vars}"

# Create a minimal config file at container start time
# (so we can use env vars like PORT and password).
cat > /app/openclaw.cloudrun.json5 <<EOF
{
  gateway: {
    mode: "local",
    port: ${PORT},
    bind: "custom",
    customBindHost: "0.0.0.0",

    controlUi: { enabled: true },

    auth: {
      mode: "password",
      password: "${OPENCLAW_GATEWAY_PASSWORD}"
    }
  }
}
EOF

export OPENCLAW_CONFIG_PATH=/app/openclaw.cloudrun.json5

# If no args are provided, default to starting the gateway.
# If args ARE provided (from Docker CMD), run exactly those.
if [ "$#" -eq 0 ]; then
  set -- gateway --verbose
fi

exec node dist/index.js "$@"

