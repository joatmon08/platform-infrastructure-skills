# Agent Instructions

This repository contains custom rules, settings, and skills for Bob AI assistant to build and manage platform infrastructure on AWS with Terraform and Kubernetes.

## Repository Overview

- **Rules**: Behavioral guidelines for security, compliance, and best practices
- **Settings**: Custom modes and MCP server configurations
- **Skills**: Specialized capabilities for platform architecture, compliance, and engineering

## Custom Skills Workflow

```
┌─────────────────────┐
│ Platform Architect  │ → Design & Planning
│ (ARCHITECTURE.md)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Platform Engineer   │ → Implementation
│ (Terraform Code)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Platform Compliance │ → Review & Validation
│ (COMPLIANCE_REVIEW) │
└─────────────────────┘
```

### Skills Overview

| Skill | Purpose | Input | Output | Key Tools |
|-------|---------|-------|--------|-----------|
| **platform-architect** | Design secure cloud infrastructure | User requirements | ARCHITECTURE.md | search_private_modules, helm search hub, get_provider_details |
| **platform-engineer** | Generate Terraform code | ARCHITECTURE.md | .tf files | get_latest_provider_version, create_workspace, create_run |
| **platform-compliance** | Security & cost review | Terraform code | Security findings window, COMPLIANCE_REVIEW.md, COST_REVIEW.md | Infracost CLI |

### Phase 1: Architecture Design (platform-architect)

**When to Use**: Starting new projects, planning AWS/K8s deployments, evaluating requirements

**Process**:
1. Gather prerequisites (HCP Terraform org/project, environment, tags)
2. Identify required infrastructure resources
3. Search for private Terraform modules and Helm charts
4. Document providers, data sources, and resources needed
5. Generate `ARCHITECTURE.md` proposal

**Key Capabilities**:
- Searches AWS Architecture Center and HashiCorp Well-Architected Framework
- Discovers private Terraform modules via MCP
- Searches Helm Hub for available charts
- Evaluates provider capabilities

### Phase 2: Implementation (platform-engineer)

**When to Use**: After architecture approval, implementing IaC, deploying to HCP Terraform, debugging failures

**Process**:
1. Generate provider blocks with latest versions
2. Create backend.tf for HCP Terraform
3. Implement resources using private modules and Helm charts
4. Validate and format Terraform code
5. Create HCP Terraform workspace
6. Deploy via HCP Terraform runs

**Key Capabilities**:
- Retrieves latest provider versions via MCP
- Configures AWS and Kubernetes providers
- Implements resources with private modules
- Deploys Helm charts to Kubernetes
- Creates and manages HCP Terraform workspaces
- Debugs deployment failures systematically

### Phase 3: Compliance Review (platform-compliance)

**When to Use**: Before production deployment, security audits, cost optimization, validating compliance

**Process**:
1. Security code review (encryption, IAM, network, secrets)
2. Compliance evaluation (tags, secrets management, module usage)
3. Cost estimation using Infracost CLI
4. Generate recommendations

**Key Capabilities**:
- Security code review
- Compliance validation against organization policies
- Cost estimation with Infracost
- Identifies high-priority security issues
- Provides remediation guidance

## Rules Overview

| Rule | Key Requirements |
|------|------------------|
| **container-testing** | Always use Podman (not Docker); use podman-compose for multi-container |
| **docs** | Always update documentation when making changes; keep AGENTS.md synchronized |
| **eks** | Public endpoints; Helm + K8s provider; Always ALB (never nginx); Cloudflare DNS |
| **terraform** | Always prompt for HCP Terraform org/project; Never use public registry modules; Add -no-color to CLI; Use Sentinel (not tfsec) |

## HashiCorp Agent Skills (Submodule)

The `skills/agent-skills/` submodule provides official HashiCorp skills:

**Terraform**: Style guide, testing, Azure Verified Modules, search/import, refactoring, Stacks, provider development
**Packer**: AWS AMI, Azure images, Windows images, HCP Packer registry

See `skills/agent-skills/AGENTS.md` for details.

## MCP Server Integration

### Terraform MCP Server

All Terraform skills use the Terraform MCP Server for:
- Searching private module registry
- Getting provider details and versions
- Managing HCP Terraform workspaces
- Creating and monitoring runs

**Configuration** (in `settings/mcp_settings.json`):
```json
{
  "mcpServers": {
    "terraform": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "TFE_TOKEN", "-e", "TFE_ADDRESS", "hashicorp/terraform-mcp-server"],
      "env": {
        "TFE_TOKEN": "${TFE_TOKEN}",
        "TFE_ADDRESS": "${TFE_ADDRESS}"
      }
    }
  }
}
```

**Required Environment Variables**:
- `TFE_TOKEN` - HCP Terraform API token
- `TFE_ADDRESS` - HCP Terraform address (defaults to app.terraform.io)

## Best Practices

### Workflow
1. Always start with platform-architect for new projects
2. Wait for architecture approval before implementation
3. Run platform-compliance before production deployment
4. Iterate based on feedback from compliance reviews

### Security
- Never hardcode credentials or secrets
- Always use private modules when available
- Validate all inputs and outputs
- Follow principle of least privilege
- Use encryption for data at rest and in transit

### Cost Optimization
- Review Infracost output before deployment
- Consider reserved instances for long-running resources
- Use appropriate instance sizes
- Implement auto-scaling where applicable
- Clean up unused resources

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Private module not found | Verify module exists using `search_private_modules` |
| HCP Terraform workspace creation fails | Check org/project names, verify API token permissions |
| Helm chart deployment fails | Check cluster connectivity, verify namespace, review pod logs |
| Compliance review fails | Review COMPLIANCE_REVIEW.md, address high-priority issues, document justifications |

### Escalation Criteria

Escalate to platform engineering team for:
- Cluster-level resource issues (StorageClass, IngressClass)
- Cluster configuration problems (CNI, CSI drivers)
- Node-level issues
- Cluster autoscaling problems
- Network policy conflicts
- RBAC/IAM role binding at cluster level

## References

### HashiCorp Documentation
- [Terraform](https://developer.hashicorp.com/terraform)
- [HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs)
- [Terraform Plugin Framework](https://developer.hashicorp.com/terraform/plugin/framework)
- [Packer](https://developer.hashicorp.com/packer)
- [HCP Packer](https://developer.hashicorp.com/hcp/docs/packer)
- [HashiCorp Well-Architected Framework](https://developer.hashicorp.com/well-architected-framework)

### AWS Documentation
- [AWS Architecture Center](https://aws.amazon.com/architecture/reference-architecture-diagrams)
- [Amazon EKS](https://docs.aws.amazon.com/eks/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Tools
- [Terraform MCP Server](https://github.com/hashicorp/terraform-mcp-server)
- [Infracost](https://www.infracost.io/)
- [Helm](https://helm.sh/)
- [Podman](https://podman.io/)

## Contributing

When adding new skills or rules:
1. Follow existing structure and format
2. Include comprehensive documentation
3. Add examples where applicable
4. Update this AGENTS.md file
5. Update root README.md
6. Test thoroughly before committing

## License

This configuration is for personal/organizational use with Bob AI assistant. The agent-skills submodule is licensed under the terms specified in the [HashiCorp agent-skills repository](https://github.com/hashicorp/agent-skills).