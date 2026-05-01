---
name: terraform
description: Generate Terraform according to organization's best practices
---

## HCP Terraform

**ALWAYS prompt user for HCP Terraform organization and project at the start of each task.**

Workspace names should follow name of repository.

## Modules

**NEVER use public Terraform registry modules from the Terraform Registry.**

### Instead, You Must:

1. **Search for private modules** using `search_private_modules`
2. **Write native Terraform resources** using official provider documentation
3. **Create custom local modules** in `modules/` directory for reusability
4. **Use provider resources directly** (e.g., `aws_eks_cluster`, `kubernetes_deployment`)
5. **Reference official provider docs** via `search_providers` and `get_provider_details` tools

### Forbidden Actions:
- ❌ Using `module` blocks that reference registry modules (e.g., `terraform-aws-modules/*`)
- ❌ Referencing any module from `registry.terraform.io`
- ❌ Using `source` that points to external registries

### Required Actions:
- ✅ Write `resource` blocks directly
- ✅ Create local `modules/` for reusable components
- ✅ Use official provider documentation
- ✅ Design portable, maintainable infrastructure

## CLI

**ALWAYS add `-no-color` argument to `terraform` when available.**

```
terraform init -no-color
terraform validate -no-color
terraform plan -no-color
terraform apply -no-color
```

## Security Scanning

**NEVER use tfsec, as it is part of trivy and not approved. Scans will be done in HCP Terraform.**