#!/usr/bin/env bash
set -euo pipefail
PORT="${1:-8765}"
echo "Serving flows.html on http://localhost:${PORT}/flows.html"
echo "Press Ctrl+C to stop."
exec python3 -m http.server "$PORT"
