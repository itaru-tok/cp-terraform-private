#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-/Users/itokuda/dev/study/cp/cp-terraform-private}"
STG_DIR="${ROOT_DIR}/stg"

if [[ ! -d "${STG_DIR}" ]]; then
  echo "stg directory not found: ${STG_DIR}" >&2
  exit 1
fi

terraform -chdir="${STG_DIR}" validate
terraform -chdir="${STG_DIR}" plan

echo "Completed plan-only workflow. apply/state mv were not executed."
