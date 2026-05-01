# Agent Instructions

This repository contains custom rules, settings, and skills for Bob AI assistant to build and manage platform infrastructure on AWS with Terraform and Kubernetes.

## Repository Overview

This configuration extends Bob's capabilities with:
- **Rules**: Behavioral guidelines for security, compliance, and best practices
- **Settings**: Custom modes and MCP server configurations
- **Skills**: Specialized capabilities for platform architecture, compliance, and engineering

## Custom Skills Workflow

The custom platform skills work together in a three-phase workflow:

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

### Phase 1: Architecture Design (platform-architect)

**Skill**: `skills/platform-architect/SKILL.md`

**Purpose**: Design secure, production-ready cloud infrastructure architecture.

**When to Use**:
- Starting a new infrastructure project
- Planning AWS deployments
- Designing Kubernetes applications
- Evaluating infrastructure requirements

**Process**:
1. Gather prerequisites (HCP Terraform org/project, environment, tags)
2. Identify required infrastructure resources
3. Search for private Terraform modules and Helm charts
4. Document providers, data sources, and resources needed
5. Generate `ARCHITECTURE.md` proposal

**Output**: `ARCHITECTURE.md` - Comprehensive architecture proposal

**Key Capabilities**:
- Searches AWS Architecture Center and HashiCorp Well-Architected Framework
- Discovers private Terraform modules via MCP
- Searches Helm Hub for available charts
- Evaluates provider capabilities
- Documents resource dependencies

### Phase 2: Implementation (platform-engineer)

**Skill**: `skills/platform-engineer/SKILL.md`

**Purpose**: Generate Terraform configurations based on approved architecture.

**When to Use**:
- After architecture approval
- Implementing infrastructure as code
- Deploying to HCP Terraform
- Debugging deployment failures

**Process**:
1. Generate provider blocks with latest versions
2. Create backend.tf for HCP Terraform
3. Implement resources using private modules and Helm charts
4. Validate and format Terraform code
5. Create HCP Terraform workspace
6. Deploy via HCP Terraform runs

**Input**: `ARCHITECTURE.md`

**Output**: Complete Terraform configuration files

**Key Capabilities**:
- Retrieves latest provider versions via MCP
- Configures AWS and Kubernetes providers
- Implements resources with private modules
- Deploys Helm charts to Kubernetes
- Creates and manages HCP Terraform workspaces
- Debugs deployment failures systematically

### Phase 3: Compliance Review (platform-compliance)

**Skill**: `skills/platform-compliance/SKILL.md`

**Purpose**: Review infrastructure for security, compliance, and cost optimization.

**When to Use**:
- Before production deployment
- During security audits
- For cost optimization reviews
- Validating compliance requirements

**Process**:
1. Security code review (encryption, IAM, network, secrets)
2. Compliance evaluation (tags, secrets management, module usage)
3. Cost estimation using Infracost CLI
4. Generate recommendations

**Output**: 
- `COMPLIANCE_REVIEW.md` - Security and compliance findings
- `MONTHLY_COST.md` - Cost breakdown and optimization recommendations

**Key Capabilities**:
- Security code review
- Compliance validation against organization policies
- Cost estimation with Infracost
- Identifies high-priority security issues
- Provides remediation guidance

## Rules Overview

### Container Testing (`rules/container-testing.md`)
- **Always use Podman** instead of Docker
- Applies to all container operations (build, run, push, pull)
- Use `podman-compose` for multi-container applications

### Documentation (`rules/docs.md`)
- **Always update documentation** when making changes
- Keep AGENTS.md synchronized with code
- Update README files for structural changes
- Use HashiCorp Developer documentation links

### Platform-Specific Rules

#### EKS (`rules/rules-platform/eks.md`)
- Create clusters with publicly available endpoints
- Deploy using Helm and Kubernetes provider
- **Always use ALB** for ingress (never nginx)
- Attach ALB to Cloudflare DNS records
- Include ingress hostname outputs

#### Terraform (`rules/rules-platform/terraform.md`)
- **Always prompt for HCP Terraform organization and project**
- Workspace names follow repository name
- **Never use public Terraform registry modules**
- Search private modules first, then write native resources
- Add `-no-color` to all Terraform CLI commands
- Use Sentinel policy sets for security scanning (not tfsec)

## HashiCorp Agent Skills (Submodule)

The `skills/agent-skills/` submodule provides official HashiCorp skills for:

### Terraform Skills
- **Code Generation**: Style guide, testing, Azure Verified Modules, search/import
- **Module Generation**: Refactoring, Terraform Stacks
- **Provider Development**: New providers, actions, resources, testing

### Packer Skills
- **Builders**: AWS AMI, Azure images, Windows images
- **HCP Integration**: Push to HCP Packer registry

See `skills/agent-skills/AGENTS.md` for detailed documentation.

## MCP Server Integration

### Terraform MCP Server

All Terraform-related skills use the Terraform MCP Server for:
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

## Typical Workflow Example

### Scenario: Deploy a new application to AWS EKS

1. **Architecture Phase** (platform-architect):
   ```
   User: "I need to deploy a Python web application with PostgreSQL on EKS"
   
   Bob: [Gathers prerequisites]
   - HCP Terraform org: alice-publishing
   - Project: applications
   - Environment: nonprod
   - Tags: OwnedBy, BusinessUnit, Project, Purpose
   
   Bob: [Searches for resources]
   - Finds private module for Cloudflare DNS
   - Finds PostgreSQL Helm chart
   - Identifies AWS resources needed (VPC, EKS, ALB, RDS)
   
   Bob: [Generates ARCHITECTURE.md]
   ```

2. **Implementation Phase** (platform-engineer):
   ```
   Bob: [Reads ARCHITECTURE.md]
   
   Bob: [Generates Terraform code]
   - Creates terraform.tf with providers
   - Creates backend.tf for HCP Terraform
   - Implements VPC using private module
   - Deploys PostgreSQL via Helm
   - Creates ALB ingress
   - Adds Cloudflare DNS record
   
   Bob: [Validates and deploys]
   - Runs terraform init, fmt, validate
   - Creates HCP Terraform workspace
   - Creates run with comment "Requested by IBM Bob"
   ```

3. **Compliance Phase** (platform-compliance):
   ```
   Bob: [Reviews Terraform code]
   
   Bob: [Security review]
   - Checks encryption at rest/transit
   - Validates IAM roles (least privilege)
   - Reviews network security groups
   - Verifies secrets in AWS Secrets Manager
   
   Bob: [Compliance check]
   - Validates all required tags present
   - Confirms no public modules used
   - Verifies Helm chart usage
   
   Bob: [Cost estimation]
   - Runs Infracost CLI
   - Generates MONTHLY_COST.md
   - Provides optimization recommendations
   
   Bob: [Generates COMPLIANCE_REVIEW.md]
   ```

## Best Practices

### When Using Custom Skills

1. **Always start with platform-architect** for new projects
2. **Wait for architecture approval** before implementation
3. **Run platform-compliance** before production deployment
4. **Iterate based on feedback** from compliance reviews

### Security Considerations

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

**Issue**: Private module not found
- **Solution**: Verify module exists in private registry using `search_private_modules`

**Issue**: HCP Terraform workspace creation fails
- **Solution**: Check organization and project names, verify API token permissions

**Issue**: Helm chart deployment fails
- **Solution**: Check cluster connectivity, verify namespace exists, review pod logs

**Issue**: Compliance review fails
- **Solution**: Review COMPLIANCE_REVIEW.md, address high-priority issues, document justifications

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
- [Terraform Documentation](https://developer.hashicorp.com/terraform)
- [HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs)
- [Terraform Plugin Framework](https://developer.hashicorp.com/terraform/plugin/framework)
- [Packer Documentation](https://developer.hashicorp.com/packer)
- [HCP Packer](https://developer.hashicorp.com/hcp/docs/packer)
- [HashiCorp Well-Architected Framework](https://developer.hashicorp.com/well-architected-framework)

### AWS Documentation
- [AWS Architecture Center](https://aws.amazon.com/architecture/reference-architecture-diagrams)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Tools
- [Terraform MCP Server](https://github.com/hashicorp/terraform-mcp-server)
- [Infracost](https://www.infracost.io/)
- [Helm](https://helm.sh/)
- [Podman](https://podman.io/)

## Contributing

When adding new skills or rules:

1. Follow the existing structure and format
2. Include comprehensive documentation
3. Add examples where applicable
4. Update this AGENTS.md file
5. Update root README.md
6. Test thoroughly before committing

## License

This configuration is for personal/organizational use with Bob AI assistant. The agent-skills submodule is licensed under the terms specified in the [HashiCorp agent-skills repository](https://github.com/hashicorp/agent-skills).