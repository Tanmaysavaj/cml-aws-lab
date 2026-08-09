#!/bin/bash
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Running Terraform steps in: $(pwd)"
echo

echo "==> Initializing Terraform..."
terraform init

echo
echo "==> Formatting Terraform..."
terraform fmt -recursive

echo
echo "==> Validating Terraform..."
terraform validate

echo
echo "==> Creating Terraform plan..."
terraform plan

echo
echo "==> Current Terraform outputs..."
terraform output || true

echo
echo "Terraform workflow complete."