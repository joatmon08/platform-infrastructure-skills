---
name: terraform
description: Generate Terraform for platform infrastructure — stricter module rules supersede the global terraform rule
---

## Modules

> **Platform mode override** — replaces the Modules section in the global terraform rule.

**NEVER use public Terraform registry modules.**

### Instead, You Must:

1. **Search for private modules** using `search_private_modules`
2. **Write native Terraform resources** using official provider documentation
3. **Create custom local modules** in `modules/` directory for reusability
4. **Use provider resources directly** (e.g., `aws_eks_cluster`, `kubernetes_deployment`)
5. **Reference official provider docs** via `search_providers` and `get_provider_details` tools

### Forbidden Actions:
- ❌ Using `module` blocks that reference any public registry module
- ❌ Referencing any module from `registry.terraform.io`
- ❌ Using `source` that points to external registries (including `terraform-aws-modules`, `azure`, `terraform-google-modules`)

### Required Actions:
- ✅ Write `resource` blocks directly
- ✅ Create local `modules/` for reusable components
- ✅ Use official provider documentation
- ✅ Design portable, maintainable infrastructure
