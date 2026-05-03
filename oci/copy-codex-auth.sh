#!/usr/bin/env bash
set -euo pipefail

SSH_KEY="${1:-${HOME}/.ssh/oracle_id_ed25519}"
AUTH_FILE="${HOME}/.codex/auth.json"
INSTANCE_IP="$(terraform -chdir=terraform output -raw instance_public_ip)"
REMOTE_AUTH_FILE='/home/opc/.codex/auth.json'

if [[ ! -f "${AUTH_FILE}" ]]; then
  echo "Codex auth file not found: ${AUTH_FILE}" >&2
  exit 1
fi

scp -i "${SSH_KEY}" "${AUTH_FILE}" "opc@${INSTANCE_IP}:${REMOTE_AUTH_FILE}"
ssh -i "${SSH_KEY}" "opc@${INSTANCE_IP}" "chmod 600 '${REMOTE_AUTH_FILE}'"
