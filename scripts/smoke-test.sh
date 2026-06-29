#!/usr/bin/env bash
set -euo pipefail

API_URL="${1:-http://localhost:8000}"
API_URL="${API_URL%/}"

echo "Running smoke tests against ${API_URL}"

check_endpoint() {
  local path="$1"
  local expected_status="${2:-200}"
  local url="${API_URL}${path}"
  local status

  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 30 "$url")
  if [[ "$status" != "$expected_status" ]]; then
    echo "FAIL: ${url} returned ${status}, expected ${expected_status}"
    exit 1
  fi
  echo "OK: ${path} (${status})"
}

check_endpoint "/health" 200
check_endpoint "/api/v1/info" 200
check_endpoint "/metrics" 200

# Readiness may be 503 if DB/Redis unavailable (local smoke without deps)
ready_status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 30 "${API_URL}/ready")
echo "INFO: /ready returned ${ready_status}"

echo "Smoke tests passed"
