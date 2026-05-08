# Pending Work

This document tracks follow-up work from the review of `docs` and `oci/terraform`.
Tackle one item at a time and update the status as decisions are made.

Status legend:

- `[ ]` Pending
- `[~]` In progress
- `[x]` Done

## P1

- [x] **1. Decide whether the development instance must be internet-facing.**
  - Current state: Terraform creates a public subnet, public IP, default internet route, and SSH ingress from `0.0.0.0/0`.
  - Challenge: if this is meant to be disposable but still powerful, broad public SSH is not a harmless default.
  - Likely first fix: add an `ssh_ingress_cidr_blocks` variable and stop defaulting SSH to the whole internet.
  - Files: `oci/terraform/main.tf`, `oci/terraform/variables.tf`, `oci/README.md`.

- [x] **2. Enforce IMDSv2 on the compute instance.**
  - Current state: remediation docs require IMDSv2, but Terraform does not disable legacy IMDS endpoints.
  - Likely first fix: add `instance_options { are_legacy_imds_endpoints_disabled = true }` to the instance resource.
  - Files: `oci/terraform/main.tf`, `oci/README.md`.

- [x] **3. Treat the binaries pre-authenticated URL as sensitive.**
  - Current state: `binaries_pre_authenticated_link` is a normal string and is passed as a remote command argument.
  - Risk: the URL may appear in Terraform state, logs, or process listings.
  - Likely first fix: mark the variable `sensitive = true` and pass it to the remote script through a less exposed mechanism.
  - Files: `oci/terraform/variables.tf`, `oci/terraform/main.tf`, `oci/terraform/scripts/bootstrap.sh`.

- [x] **4. Make bootstrap and verification changes trigger reprovisioning.**
  - Current state: `null_resource` provisioners have no triggers tied to script or config content.
  - Risk: changing bootstrap, verify, or config files may not rerun provisioning.
  - Likely first fix: add `triggers` using file hashes for `bootstrap.sh`, `verify.sh`, and `codex-config.toml`.
  - Files: `oci/terraform/main.tf`.

## P2

- [ ] **5. Normalize supply-chain verification for downloaded and installed tools.**
  - Current state: some artifacts have checksums, while others use unverified downloads, `curl | bash`, unpinned npm installs, or a mutable Git branch.
  - Challenge: the script already proves checksums are feasible, so the exceptions should be deliberate and documented.
  - Likely first fix: pin and verify `hey`, JMeter, SDKMAN/Codex install path, and `sw` revision; document any unavoidable installer trust.
  - Progress: `hey` now has a pinned expected SHA-256 for the downloaded object, JMeter is verified against Apache's published SHA-512, and Codex CLI is pinned to an explicit npm package version.
  - Accepted exception: the Falcon installer comes from Oracle's internal Falcon support bucket and SDKMAN uses its official upstream installer; both are trusted installers without independent checksums in this script.
  - Remaining: decide how to handle the `sw` default build from a mutable branch.
  - Files: `oci/terraform/scripts/bootstrap.sh`, `oci/README.md`.

- [ ] **6. Restore Terraform provider reproducibility.**
  - Current state: the OCI provider uses `>= 8.10.0`, and `.terraform.lock.hcl` is ignored.
  - Challenge: disposable infrastructure still needs repeatable plans.
  - Likely first fix: commit `.terraform.lock.hcl` and use a bounded provider constraint.
  - Files: `oci/terraform/main.tf`, `oci/terraform/.gitignore`, `oci/terraform/.terraform.lock.hcl`.

- [ ] **7. Move remediation docs to tracked editable source.**
  - Current state: `docs/.gitignore` ignores all docs, and the available documents are PDF-only.
  - Risk: review, diffing, and maintenance are poor.
  - Likely first fix: add Markdown source files and generate PDFs only as derived artifacts if PDFs are still needed.
  - Files: `docs/.gitignore`, `docs/*.md`.

- [ ] **8. Rewrite the dynamic-group procedure.**
  - Current state: `3 Tighten Dynamic-Group Scope - Operator Procedure.pdf` appears to duplicate the blast-radius procedure.
  - Risk: operators may not get concrete dynamic-group matching-rule guidance.
  - Likely first fix: create a source doc focused on matching rules, compartments, tags, shared groups, and validation.
  - Files: `docs/3-tighten-dynamic-group-scope.md`.

## P3

- [ ] **9. Reconsider broad `defined_tags` drift masking.**
  - Current state: most resources ignore changes to `defined_tags`.
  - Challenge: if Terraform declares tags, silently ignoring drift needs a clear reason.
  - Likely first fix: either remove `ignore_changes` or document the external tag manager that requires it.
  - Files: `oci/terraform/main.tf`, `oci/README.md`.

- [ ] **10. Decouple image selection from a single region default.**
  - Current state: `region` is configurable, but the default image OCID is Ashburn-specific.
  - Risk: changing region without overriding the image can fail or create confusing behavior.
  - Likely first fix: remove the image default or use an OCI image data source keyed by region and OS requirements.
  - Files: `oci/terraform/variables.tf`, `oci/terraform/main.tf`, `oci/README.md`.

## Completed

- Task 1: SSH access is now restricted to explicit CIDR blocks through `ssh_ingress_cidr_blocks`, and `oci/README.md` documents how to find the current public IP for a `/32` allowlist entry.
- Task 2: The compute instance now disables legacy IMDSv1 metadata endpoints and `oci/README.md` documents that IMDSv2 is required.
- Task 3: The binaries pre-authenticated URL is now a sensitive Terraform variable and bootstrap reads it from `/tmp/.binaries-pre-authenticated-link` instead of receiving it as a shell command argument.
- Task 4: Bootstrap and verification `null_resource` blocks now use file-hash triggers so script and Codex config changes rerun provisioning; verification also reruns after bootstrap replacement.
