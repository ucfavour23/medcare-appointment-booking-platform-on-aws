#!/usr/bin/env bash
set -euo pipefail

INSTANCE_ID="${1:?usage: check_ec2_app.sh <instance-id>}"

COMMAND_ID="$(
  aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name AWS-RunShellScript \
    --parameters 'commands=[
      "systemctl status medcare-appointments --no-pager || true",
      "journalctl -u medcare-appointments -n 80 --no-pager || true",
      "ss -ltnp | grep 5000 || true",
      "cloud-init status --long || true"
    ]' \
    --query 'Command.CommandId' \
    --output text
)"

echo "CommandId=$COMMAND_ID"
aws ssm wait command-executed --command-id "$COMMAND_ID" --instance-id "$INSTANCE_ID"
aws ssm get-command-invocation \
  --command-id "$COMMAND_ID" \
  --instance-id "$INSTANCE_ID" \
  --query 'StandardOutputContent' \
  --output text
