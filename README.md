# platform-infrastructure-skills

IBM Bob mode, rules, skills, and settings for building platform infrastructure.

This repository contains custom configuration files for the Bob AI assistant, including rules, settings, and skills that enhance Bob's capabilities for infrastructure development and automation tasks.

## 📁 Repository Structure

```
.
├── rules/                      # Custom rules for Bob's behavior
│   ├── container-testing.md   # Container runtime preferences (podman)
│   ├── docs.md                # Documentation update requirements
│   ├── ibm.md                 # IBM-specific corporate workflows (gitignored)
│   ├── security.md            # Security standards and requirements (gitignored)
│   └── rules-platform/        # Platform-specific rules
│       ├── eks.md             # Kubernetes on AWS EKS guidelines
│       └── terraform.md       # Terraform best practices
├── settings/                   # Bob configuration settings
│   ├── custom_modes.yaml      # Custom operational modes
│   └── mcp_settings.json      # MCP settings (gitignored)
└── skills/                     # Extended skills and capabilities
    ├── agent-skills/          # HashiCorp agent skills (submodule)
    ├── platform-architect/    # Architecture design skill
    ├── platform-compliance/   # Security and compliance review skill
    └── platform-engineer/     # Infrastructure implementation skill
```

## 🚀 Quick Start

### Initial Setup

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url>
   cd <repo-name>
   ```

2. **Initialize submodules:**
   ```bash
   git submodule init
   git submodule update
   ```

3. **(Optional) Configure sensitive files:**
   - Create `settings/mcp_settings.json` with your MCP settings

### Updating Agent Skills

To update the HashiCorp agent-skills to the latest version:

```bash
git submodule update --remote skills/agent-skills
git add skills/agent-skills
git commit -m "Update agent-skills submodule"
```

## 🔧 Rules

### Container Testing (`rules/container-testing.md`)
Enforces the use of Podman instead of Docker for all container operations:
- Container builds, runs, and management
- Image operations and registry interactions
- Multi-container applications with podman-compose

### Documentation (`rules/docs.md`)
Enforces documentation updates whenever changes are made to the repository:
- AGENTS.md stays synchronized with code changes
- Project and root README files are kept up-to-date
- All documentation reflects current functionality and architecture
- External links use HashiCorp Developer documentation

### Platform-Specific Rules

#### EKS (`rules/rules-platform/eks.md`)
Guidelines for Kubernetes resources on AWS EKS clusters:
- Publicly available cluster endpoints
- Helm and Kubernetes provider deployment
- ALB ingress (never nginx)
- Cloudflare DNS integration for ingress
- Ingress hostname output patterns

#### Terraform (`rules/rules-platform/terraform.md`)
Terraform best practices and requirements:
- HCP Terraform organization and project configuration
- Workspace naming conventions
- Private module usage (never public registry modules)
- CLI formatting with `-no-color` flag
- Sentinel policy sets for security scanning (no tfsec)

## 🎯 Skills

### HashiCorp Agent Skills (Submodule)
This repository includes the official [HashiCorp agent-skills](https://github.com/hashicorp/agent-skills) collection as a Git submodule. This provides comprehensive skills for:

- **Packer**:
  - AWS AMI builder
  - Azure image builder
  - Windows builder
  - HCP registry integration

- **Terraform**:
  - **Code generation**: Azure Verified Modules, search/import, style guide, testing
  - **Module generation**: Refactoring, Terraform Stacks
  - **Provider development**: New providers, actions, documentation, resources, testing

For detailed documentation on these skills, see the [agent-skills repository](https://github.com/hashicorp/agent-skills).

### Custom Platform Skills

#### Platform Architect (`skills/platform-architect/`)
Architecture design and planning skill for cloud infrastructure:
- **Purpose**: Design secure, production-ready cloud infrastructure
- **Output**: `ARCHITECTURE.md` proposal document
- **Capabilities**:
  - Identifies required infrastructure resources
  - Discovers available Terraform modules and Helm charts
  - Searches private module registry
  - Evaluates provider capabilities
  - Generates resource lists and architecture proposals
- **Use when**: Planning new infrastructure deployments, designing cloud architecture, or reviewing infrastructure requirements

#### Platform Compliance (`skills/platform-compliance/`)
Security, compliance, and cost review skill:
- **Purpose**: Review infrastructure for security, compliance, and cost optimization
- **Output**: `COMPLIANCE_REVIEW.md` and `MONTHLY_COST.md`
- **Capabilities**:
  - Security code review (encryption, IAM, network security, secrets management)
  - Compliance evaluation (required tags, secrets management, module usage)
  - Cost estimation using Infracost CLI
  - Cost optimization recommendations
- **Use when**: Reviewing Terraform configurations before deployment, auditing existing infrastructure, or assessing infrastructure costs

#### Platform Engineer (`skills/platform-engineer/`)
Infrastructure implementation skill for generating Terraform code:
- **Purpose**: Generate Terraform configurations based on architecture proposals
- **Input**: `ARCHITECTURE.md` file
- **Capabilities**:
  - Generates provider blocks with latest versions
  - Creates backend.tf for HCP Terraform
  - Implements resources using private modules and Helm charts
  - Validates and formats Terraform code
  - Creates HCP Terraform workspaces
  - Debugs deployment failures
- **Use when**: Implementing approved architecture designs, generating Terraform code, or deploying infrastructure to HCP Terraform

### Security Checklist Before Committing

- [ ] Verify `.gitignore` includes all sensitive files
- [ ] Check for hardcoded credentials, API keys, or tokens
- [ ] Review AWS account IDs, IAM role ARNs, and usernames
- [ ] Ensure no internal hostnames or IP addresses are exposed
- [ ] Validate that submodules are properly configured

## 📝 Usage

These configuration files are automatically loaded by Bob when operating in the workspace directory. The rules guide Bob's behavior, while skills extend its capabilities for specific tasks.

### Adding New Rules

Create new rule files in the `rules/` directory with the following format:

```markdown
---
name: rule-name
description: Brief description of the rule
---

## Rule Content

Your rule guidelines here...
```

### Adding New Skills

Add custom skill definitions to the `skills/` directory following the existing structure. Each skill should include a `SKILL.md` file with clear instructions and examples.

## 📚 Additional Resources

- [Bob AI Assistant Documentation](https://docs.bob.ai)
- [HashiCorp Agent Skills](https://github.com/hashicorp/agent-skills)
- [Terraform Documentation](https://developer.hashicorp.com/terraform)
- [Packer Documentation](https://developer.hashicorp.com/packer)

## ⚠️ Important Notes

- This repository is designed for use with Bob AI assistant
- Rules are automatically enforced during Bob's operation
- Skills extend Bob's capabilities for specific domains
- The agent-skills submodule is maintained by HashiCorp
- Always review changes for sensitive information before committing
- Keep your local sensitive configuration files backed up securely

## 📄 License

This configuration is for personal/organizational use with Bob AI assistant. The agent-skills submodule is licensed under the terms specified in the [HashiCorp agent-skills repository](https://github.com/hashicorp/agent-skills).
