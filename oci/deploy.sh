#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=terraform init -upgrade
terraform -chdir=terraform fmt
terraform -chdir=terraform apply -auto-approve -input=false
