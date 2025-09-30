#!/bin/bash
set -e

FLUTTER_PORT=8080
HTTPS_PORT=8020
CERT="localhost.pem"
KEY="localhost-key.pem"

echo "🔨 Starting Flutter dev server (HTTP)..."

# Start SSL proxy in the background
local-ssl-proxy --source $HTTPS_PORT --target $FLUTTER_PORT --cert $CERT --key $KEY &

PROXY_PID=$!

# Trap Ctrl+C to clean up proxy
trap "echo 'Stopping HTTPS proxy...'; kill $PROXY_PID; exit" INT

# Start Flutter in foreground (so you can type R, r, etc.)
flutter run -d web-server --web-hostname localhost --web-port $FLUTTER_PORT




