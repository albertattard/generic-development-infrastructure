# Repository Guidelines

## Purpose
- This repository provisions a reusable OCI-based development machine using Terraform.
- The main entrypoint is [`oci/terraform/main.tf`](./oci/terraform/main.tf); instance bootstrapping happens in [`oci/terraform/scripts/bootstrap.sh`](./oci/terraform/scripts/bootstrap.sh).
- Keep changes aligned with the goal of creating and maintaining a disposable Java tooling environment, not a general-purpose platform.

## Repository layout
- [`README.md`](./README.md): top-level usage and submodule guidance.
- [`oci/README.md`](./oci/README.md): OCI setup, required variables, deployment, and teardown flow.
- [`oci/deploy.sh`](./oci/deploy.sh): wrapper for `terraform init`, `fmt`, and `apply`.
- [`oci/destroy.sh`](./oci/destroy.sh): wrapper for destroying the stack.
- [`oci/terraform/variables.tf`](./oci/terraform/variables.tf): all user-supplied inputs.
- [`oci/terraform/main.tf`](./oci/terraform/main.tf): OCI networking, compute instance, bootstrap provisioning, and outputs.
- [`oci/terraform/scripts/bootstrap.sh`](./oci/terraform/scripts/bootstrap.sh): downloads, checksum verification, and installation of JDKs and tools on the instance.

## Working rules
- Prefer minimal, targeted changes. This repository is small, so avoid introducing extra abstraction unless it clearly reduces risk.
- Preserve the current structure unless a user asks for a broader refactor.
- When changing Terraform inputs or behavior, update the relevant documentation in [`oci/README.md`](./oci/README.md).
- When changing installed software versions or artifacts, keep filename and checksum updates together in [`oci/terraform/scripts/bootstrap.sh`](./oci/terraform/scripts/bootstrap.sh).
- Do not hardcode secrets, OCIDs, SSH keys, or pre-authenticated links in tracked files.
- Treat `terraform.tfvars` as local-only configuration. Do not create or commit environment-specific values.

## Coding standards
- Use `terraform fmt` formatting for all Terraform files before finishing Terraform changes.
- Prefer explicit, readable Terraform over clever abstractions. Keep resource definitions straightforward and predictable.
- Declare new Terraform inputs in [`oci/terraform/variables.tf`](./oci/terraform/variables.tf) with clear descriptions and sensible defaults only when they are genuinely safe.
- Keep Terraform resource names, outputs, and variable names stable unless a rename is required. Renames can force unnecessary churn for users and state.
- Keep related Terraform behavior close together. Networking, compute, inputs, outputs, and bootstrap wiring should remain easy to locate in [`oci/terraform/main.tf`](./oci/terraform/main.tf).
- When adding shell logic, write Bash that is compatible with `#!/usr/bin/env bash` and keep `set -euo pipefail`.
- Quote shell variables by default and avoid relying on implicit word splitting or globbing.
- Prefer small shell functions for repeated logic or validations instead of copying command blocks.
- Use uppercase shell variable names for script-level constants and downloaded artifact metadata.
- Keep shell comments brief and focused on intent, operational constraints, or non-obvious behavior.
- Keep download URLs, file names, and SHA-256 checksums aligned in [`oci/terraform/scripts/bootstrap.sh`](./oci/terraform/scripts/bootstrap.sh); update them as one logical change.
- Prefer changes that fail fast with clear error messages over silent fallbacks, especially in provisioning scripts.

## Validation
- For Terraform changes, run `terraform -chdir=oci/terraform fmt`.
- Prefer `terraform -chdir=oci/terraform validate` for static verification when possible.
- Only run `terraform apply` or `oci/deploy.sh` if the user explicitly wants infrastructure changes applied. These commands create or modify billable OCI resources.
- Only run destroy flows if the user explicitly asks. Destruction is irreversible.
- For bootstrap script edits, at minimum review shell syntax carefully and keep checksum/file references internally consistent. If `shellcheck` is available, use it on [`oci/terraform/scripts/bootstrap.sh`](./oci/terraform/scripts/bootstrap.sh).

## OCI and bootstrap notes
- The Terraform stack creates a VCN, internet gateway, default route/security resources, a public subnet, and one public compute instance.
- The instance is configured through a Terraform `null_resource` that uploads and executes [`oci/terraform/scripts/bootstrap.sh`](./oci/terraform/scripts/bootstrap.sh) over SSH.
- Bootstrap changes should assume a fresh Oracle Linux instance and remain idempotent enough for Terraform reprovisioning scenarios.
- Be cautious with network, firewall, and SSH changes in [`oci/terraform/main.tf`](./oci/terraform/main.tf); they can make the machine unreachable.

## Commits
- Only create commits when the user explicitly asks.
- Write commit subjects as a short imperative phrase that starts with a verb and states the outcome.
- Example subject: `Install Rust`
- Add a body only when it helps explain the reason for the change, tradeoffs, or intent.
- Prefer commit bodies that explain why the change is being made rather than restating the file-level implementation details.
- If the reason is obvious and the subject is sufficient, omit the body.
