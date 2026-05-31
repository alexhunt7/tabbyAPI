#!/bin/bash
# Wrapper: start TabbyAPI, wait for model to load, then notify systemd it's ready.
set -euo pipefail

cd "$(dirname "$(realpath "$0")")"

# Start the actual service in the background
./start.sh &
TABBY_PID=$!

# Forward SIGTERM/SIGINT to the background process
trap 'kill -TERM $TABBY_PID; wait $TABBY_PID' EXIT

PORT="$(awk '/  port: / {print $NF}' config.yml)"

# Wait until port 8080 is listening (model fully loaded)
while ! ss -tln | grep -q ":${PORT} "; do
    sleep 1
done

# Tell systemd the service is ready (no-op if not running under systemd)
systemd-notify READY=1

# Keep running; forward exit status of the child
wait $TABBY_PID
