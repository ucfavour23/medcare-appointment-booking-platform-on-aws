#!/usr/bin/env bash
set -euo pipefail

TARGET_GROUP_ARN="${1:?usage: wait_live_health.sh <target-group-arn> <url>}"
URL="${2:?usage: wait_live_health.sh <target-group-arn> <url>}"

for attempt in {1..18}; do
  state="$(
    aws elbv2 describe-target-health \
      --target-group-arn "$TARGET_GROUP_ARN" \
      --query 'TargetHealthDescriptions[*].TargetHealth.State' \
      --output text
  )"
  health="$(curl -s --max-time 10 "$URL/health" || true)"
  echo "attempt=$attempt target_state=$state health=$health"
  if [[ "$state" == "healthy" && "$health" == *'"status":"ok"'* ]]; then
    exit 0
  fi
  sleep 10
done

exit 1
