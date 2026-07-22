---
name: terraform
description: Generate Terraform according to organization's best practices
---

## Skills

**ALWAYS activate the following skills and prompts before writing Terraform code:**

1. **`tfctl` skill** — activate via `use_skill` for all HCP Terraform interactions (runs, workspaces, variables, policy checks).
2. **`/terraform/style-guide` prompt** — call this MCP prompt to apply HashiCorp's official Terraform style conventions before generating any `.tf` files.
3. **`/terraform/module-development` prompt** — call this MCP prompt when creating or modifying Terraform modules to follow module development best practices.

## Terraform Version

**ALWAYS require Terraform 1.15 or higher** in the `terraform` block:

```hcl
terraform {
  required_version = ">= 1.15"
}
```

## Providers

**ALWAYS use `get_latest_provider_version` tool before generating Terraform code.**

Before writing any Terraform configuration:
1. Use `get_latest_provider_version` to fetch the current version
2. Use the returned version in the `required_providers` block
3. Format as `~> X.Y` (major.minor) to allow patch updates

## Modules

1. **Search for private modules first** using `search_private_modules`
2. **Write native Terraform resources** using official provider documentation
3. **Search for public modules** using `search_public_modules` when no private module exists. Approved namespaces include:
   - `terraform-aws-modules`
   - `azure`
   - `terraform-google-modules`
4. **Create custom local modules** in `modules/` directory for reusable components

### Required Actions:
- ✅ Write `resource` blocks directly
- ✅ Create local `modules/` for reusable components
- ✅ Use official provider documentation
- ✅ Design portable, maintainable infrastructure

## HCP Terraform

**ALWAYS use `tfctl` CLI, including to start a run on a workspace.**

```
source tfctl.env && tfctl run start workspace-name --message="Run started with Bob using tfctl"
```

For plans, use `tfctl` to check the status after 60 seconds.

For applies, use `tfctl` to check the status after 180 seconds.

**ALWAYS append "Approved with IBM Bob" as part of the comments for each plan, run, and apply.**

**ALWAYS prompt user for HCP Terraform organization and project at the start of each task. Set as TFCTL_ORGANIZATION environment variable in `tfctl.env`.**

```
export TFCTL_ORGANIZATION=rosemary-production
```

**ALWAYS use `git` CLI to get the HCP Terraform workspace name.**

```
basename `git rev-parse --show-toplevel`
```

**ALWAYS warn user if the number of resources for a given state exceeds 500.**

```
Warning: You are creating more than 500 resources. This exceeds the free tier
limit of HCP Terraform.
```

## CLI

**ALWAYS add `-no-color` argument to `terraform` when available.**

```
terraform init -no-color
terraform validate -no-color
terraform plan -no-color
terraform apply -no-color
```