# platform-infrastructure-skills

IBM Bob mode, rules, skills, and settings for building platform infrastructure.

This repository contains custom configuration files for the Bob AI assistant, including rules, settings, and skills that enhance Bob's capabilities for infrastructure development and automation tasks.

## 📁 Repository Structure

```
.
├── rules/                      # Custom rules for Bob's behavior
│   ├── docs.md                # Documentation update requirements
│   └── kubernetes-aws.md      # Kubernetes on AWS EKS guidelines
├── settings/                   # Bob configuration settings
│   ├── custom_modes.yaml      # Custom operational modes
│   └── mcp_settings.json      # MCP settings (gitignored)
└── skills/                     # Extended skills and capabilities
    ├── agent-skills/          # HashiCorp agent skills (submodule)
    └── platform-infrastructure-builder/  # Platform infrastructure skill
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

### Documentation Rule (`rules/docs.md`)
Enforces documentation updates whenever changes are made to the repository. Ensures that:
- AGENTS.md stays synchronized with code changes
- Project and root README files are kept up-to-date
- All documentation reflects current functionality and architecture

### Kubernetes-AWS Rule (`rules/kubernetes-aws.md`)
Provides guidelines for designing Kubernetes resources on AWS EKS clusters:
- Uses ALB ingress instead of nginx
- Creates clusters with publicly available endpoints
- Includes EDR deployment instructions
- Provides ingress hostname output patterns

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

### Platform Infrastructure Builder (Custom)
Custom skill for building and managing platform infrastructure specific to your organization's needs.

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
