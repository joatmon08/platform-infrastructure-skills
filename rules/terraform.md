---
name: terraform
description: Design Terraform
---

**NEVER use public Terraform registry modules from the Terraform Registry.**

### Instead, You Must:

1. **Search for private modules** using `search_private_modules`
1. **Write native Terraform resources** using official provider documentation
2. **Create custom local modules** in `modules/` directory for reusability
3. **Use provider resources directly** (e.g., `aws_eks_cluster`, `kubernetes_deployment`)
4. **Reference official provider docs** via `search_providers` and `get_provider_details` tools

### Forbidden Actions:
- ❌ Using `module` blocks that reference registry modules (e.g., `terraform-aws-modules/*`)
- ❌ Referencing any module from `registry.terraform.io`
- ❌ Using `source` that points to external registries

### Required Actions:
- ✅ Write `resource` blocks directly
- ✅ Create local `modules/` for reusable components
- ✅ Use official provider documentation
- ✅ Design portable, maintainable infrastructure