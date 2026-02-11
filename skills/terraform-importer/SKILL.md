---
name: terraform-importer
description: Terraform import workflow specialized for existing AWS resources in this repository. Use when preparing modular Terraform files and import blocks for account 424848769759 (ap-northeast-1, stg), validating with terraform plan, and explicitly avoiding apply/state mv.
---

# Terraform Importer

Follow this workflow to prepare import tasks only.

## 1) Lock scope and constraints

- Work in `/Users/itokuda/dev/study/cp/cp-terraform-private`.
- Keep existing module-first structure: `modules/aws/<service>` and `stg/aws.tf`.
- Use environment defaults unless user overrides:
  - account_id: `424848769759`
  - region: `ap-northeast-1`
  - env: `stg`
- Never run `terraform apply`.
- Never run `terraform state mv`.

## 2) Gather target resources

- Ask user which AWS resources to import when not specified.
- For each resource type, check latest schema and import ID format in:
  - `https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/<resource>`
- Keep only minimum required arguments needed for clean `terraform plan`.
- Add practical non-required fields when likely needed for stable plans (for example: `tags`, `name`, `vpc_id`, queue policy JSON, route targets).

## 3) Model resources as modules

- Reuse existing patterns in this repository:
  - one service module under `modules/aws/<service>`
  - `variables.tf` for inputs
  - `outputs.tf` only when used by another module/root
  - wire modules from `stg/aws.tf`
- Keep names aligned to existing naming convention (`cp-...-${var.env}`).
- Avoid introducing unrelated refactors.

### IAM modeling rule

- Keep IAM role and policy attachments in `modules/aws/iam_role`.
- Do not use `data.aws_iam_policy` for managed policy attachments; write `policy_arn` directly in `aws_iam_role_policy_attachment`.
- If custom policies are required, split files inside the same IAM module (for example `custom_policies.tf`) and define `aws_iam_policy` there.
- Keep custom policy attachment resources in the same IAM module; do not create a separate service module only for attachments.

## 4) Add import blocks

- Place import blocks in `stg/imports_<service>.tf`.
- Prefer Terraform `import {}` blocks so import intent is versioned.
- One block per resource address.
- Use exact module resource address, e.g.:

```hcl
import {
  to = module.vpc.aws_vpc.vpc
  id = "vpc-0123456789abcdef0"
}
```

- Keep IDs as placeholders when actual IDs are unknown; clearly mark TODO.

## 5) Validate with plan only

- Run:
  - `terraform -chdir=stg fmt -recursive`
  - `terraform -chdir=stg init`
  - `terraform -chdir=stg validate`
  - `terraform -chdir=stg plan`
- If plan fails, add missing minimum arguments and retry.
- Stop after plan is clean or blocked by unknown remote values.

## 6) Report format

- Report:
  - created/updated files
  - import blocks added
  - plan result and remaining blockers
- Explicitly state that `apply` and `state mv` were not run.

## 7) Post-import operating mode (per resource type)

- Apply this rule per AWS resource type/service (for example IAM, SQS, SES).
- For each resource type, do first implementation with import to establish a correct template/module pattern.
- For the same resource type after first success, reuse that established template/module pattern.
- Keep import-first workflow only for the first case of that resource type or when adopting pre-existing unmanaged resources.
- Remove or archive `stg/imports_<service>.tf` after each import task is completed and verified.
- For managed resources of already-templated types, use normal `plan/apply` workflow.

## References

- Import templates and resource-specific notes: `references/aws-import-templates.md`
- Optional helper command wrapper: `scripts/run_import_plan.sh`
