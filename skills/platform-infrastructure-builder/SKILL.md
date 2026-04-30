---
name: platform-infrastructure-builder
description: Guide for deploying cloud infrastructure like VMs, networks, load balancers, databases, and other managed service offerings with infrastructure as code. Use when generating Terraform and deploying and configuring infrastructure for AWS and Kubernetes in this organization.
---

# Platform Infrastructure Builder Guide

## Overview

Create cloud infrastructure that is secure, production-ready, and
compliant with organization standards.

## Prerequisites

Before starting any infrastructure deployment, ensure the following are available:

### Required Tools
- **Terraform** (>= 1.14)
- **AWS CLI** (configured with appropriate credentials)
- **kubectl** (for Kubernetes deployments)
- **Helm** (>= 3.x for Kubernetes package management)
- **Infracost CLI** (for cost estimation)

### Required Access
- **HCP Terraform account** with appropriate organization access
- **AWS IAM credentials** with necessary permissions:
  - EC2, VPC, EKS management
  - IAM role creation
  - Secrets Manager access
  - CloudWatch Logs access
- **Kubernetes cluster access** (if deploying to existing cluster)
- **Git repository access** for VCS integration

### Required Information
Before beginning, gather:
- Target environment (nonprod/prod)
- Required tags (OwnedBy, BusinessUnit, Project, Purpose)
- Budget constraints (if any)
- Compliance requirements
- Existing resources to integrate with (VPC, cluster, etc.)

---

# Process

## Phase 0: Gather Information

Get the following information from the user:

- HCP Terraform organization: default `alice-publishing`
- HCP Terraform project: default `applications`
- Environment: `nonprod`
- OwnedBy
- BusinessUnit
- Project
- Purpose

Before proceeding to Phase 1, verify:
- [ ] User has specified all information for HCP Terraform
- [ ] User has specified all information for tags

## Phase 1: Deep Research and Planning

Write the results of this phase to `ARCHITECTURE.md`.

### 1.1 Identify required infrastructure resources

- Search architecture documentation for the use case
  - [AWS Architecture Center](https://aws.amazon.com/architecture/reference-architecture-diagrams)
  - [HashiCorp Well-Architected Framework](https://developer.hashicorp.com/well-architected-framework)
- If architecture guidance does not exist, conduct a broader web search.
- Identify service offerings required to achieve architecture.
- Generate a list of products and services to use to achieve the architecture.

If the user specifies that they must use an existing resource (such as a VPC or Kubernetes cluster),
get more information on the tags related to the existing resource.

Ask for clarification if you find missing information.

AWS Requirements:

- Create networking (e.g., VPC) or runtime (e.g., EC2 instances) unless otherwise
  specified by the user
- Store in secrets in AWS Secrets Manager.
- Create IAM roles and security roups for components.
- Use AWS ALB for load balancing services, when possible

### 1.2 Discover official Helm charts

- Before identifying resources, search for official Helm charts first:
  1. Check if official Helm charts exist for each service
  2. Only use raw Kubernetes resources (Deployment, Service, etc.) if:
    - No official Helm chart exists
    - The Helm chart doesn't meet specific requirements
  3. Document why raw resources are used instead of Helm charts

For each service identified:
1. Add the Helm repository: `helm repo add <repo-name> <repo-url>`
2. Update repositories: `helm repo update`
3. Search for charts: `helm search repo <keyword> --versions` (e.g., `helm search repo qdrant --versions`)
4. Verify chart repository URLs
5. Check latest stable versions
6. Review chart values: `helm show values <repo-name>/<chart-name> --version <version>`

Output a table:
| Service | Helm Chart Available? | Repository | Chart Name | Version | Command to Add Repo |
|---------|----------------------|------------|------------|---------|---------------------|
| Qdrant  | Yes                  | https://qdrant.github.io/qdrant-helm | qdrant | 0.8.4 | `helm repo add qdrant https://qdrant.github.io/qdrant-helm` |

### 1.3 Discover available Terraform modules

**IMPORTANT: Only use private modules from the organization's registry. Public modules are not vetted for security.**

- Before identifying resources, search for private Terraform modules first:
  1. Check if private modules exist for each resource type
  2. Only use raw resources if:
    - No private module exists
    - The module doesn't meet specific requirements
  3. Document why raw resources are used instead of modules

For each resource identified:
1. Search for private modules with `search_private_modules` (organization-specific only)
2. Check resources created in module with `get_private_module_details`
3. Check latest stable version
4. Review module inputs, outputs, and dependencies

Output a table:
| Resource | Module Available? | Module Source | Version |
|---------|----------------------|------------|---------|
| Cloudflare DNS Record | Yes | app.terraform.io/alice-publishing/alb-dns/cloudflare | 0.0.1 |
| AWS VPC | No | N/A - Use raw aws_vpc resource | N/A |

### 1.4 Study resources in Kubernetes

- Prioritize use of an Ingress resource backed by an AWS ALB for public service
- Create a service account on Kubernetes for each service
- Each service has its own namespace, do not deploy to default

### 1.5 Study resources in Terraform

- Prioritize the use of ofificial modules and make note of any
resources that are not in the module. 
- Use the Terraform AWS, Helm, and Kubernetes providers
- Start with the Terraform MCP server to `get_provider_details` to
evaluate if the provider offers the resources required.
- Using the list of products and services to achieve the architecture,
find their equivalent resources and data sources in the provider
with `get_provider_capabilities`.
- Use `search_private_modules` on the Terraform MCP server to find
similar modules in the Terraform private registry that are offered
as part of this organization.

If the user requests the resources be created on an existing resource,
suggest a list of Terraform data sources to use.

Output a list of Terraform resources, data sources, and modules to use
to achieve the architecture. For modules, list out the types of resources it
creates.

### Phase Transition Checklist

Before proceeding to Phase 2, verify:
- [ ] User has approved the resource list
- [ ] All required variables have been identified
- [ ] Architecture aligns with AWS/HashiCorp best practices
- [ ] Private modules identified for all applicable resources
- [ ] Helm charts identified for Kubernetes services
- [ ] User understands the deployment approach

Only proceed to Phase 2 once user explicitly approves.

### Example

Example chat:

```
User: Deploy a public web application on an existing Kubernetes cluster.

Agent: What HCP Terraform organization and tags would you like to add?

User: HCP Terraform organization: `alice-publishing`, workspace `bobs-book-agent`. Tags: `nonprod` OwnedBy=`rosemary`

Agent: Over HTTP or HTTPS?

User: HTTP.

Agent: Accessible from everywhere, 0.0.0.0/0?

User: Yes.

Agent: What tags?

User: It is in the `prod` environment and `OwnedBy` `rosemary`.

Agent: I have written the architecture to `ARCHITECTURE.md`.
```

`ARCHITECTURE.md`

```
Data sources
- aws_eks_cluster

Resources
- kubernetes_namespace_v1
- kubernetes_ingress_v1
- helm_release

Module
- alice-publishing/web-application/kubernetes
  - kubernetes_service_v1
  - kubernetes_deployment_v1
  - kubernetes_service_account_v1
```

---

## Phase 2: Implementation

`get_latest_provider_version` with the Terraform MCP server to
get the latest provider version before generating code.

When possible, use data sources to retrieve information
from AWS about Kubernetes and other components. If the cluster
name is not specified by the user, prompt the user for
more information.

When deploying to EKS, ALWAYS use the AWS provider with 
`aws_eks_cluster` and `aws_eks_cluster_auth` data sources to 
configure the Kubernetes and Helm providers. 
Never use local kubeconfig files.

### Generate backend.tf file

- Ask user for the HCP Terraform organization and project for deployment
- Suggest a workspace name based on current repository name.
- Create `backend.tf` file in the root of the project to reference HCP Terraform.

```hcl
# backend.tf
terraform {
  cloud {
    organization = "alice-publishing"
    workspaces {
      name = "bobs-book-agent"
    }
  }
}
```

### AWS Provider Credentials & Region

Provider credentials are set up through HCP using a variable set.

1. Use `list_variable_sets` to get the variables available to the project and workspace
2. Check for required AWS credentials in variable sets:
   - `AWS_ACCESS_KEY_ID` (environment variable)
   - `AWS_SECRET_ACCESS_KEY` (environment variable)
   - `region` (Terraform variable)
3. If AWS credentials are not found in any variable set:
   - Prompt user to attach the appropriate variable set to the workspace
   - Provide instructions: "Attach the AWS credentials variable set to your workspace in HCP Terraform"
4. Declare Terraform variables that match the variable sets

```hcl
# Variable set includes a `region` Terraform variable

variable "region" {
  type        = string
  description = "AWS region"
}
```

### Tagging

The following tags are required for the AWS provider's `default_tags`.
If not specified, ask the user.

```hcl
ManagedBy    = "Terraform" # always "Terraform"
Environment  = "nonprod" # always "nonprod" or "prod"
OwnedBy      = "rosemary"
BusinessUnit = "publishing"
Project      = "some-project"
Purpose      = "test"
```

### Example

```hcl
# terraform.tf
terraform {
  required_version = ">= 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  tags {
    default_tags = {
      ManagedBy    = "Terraform"
      Environment  = "nonprod"
      OwnedBy      = "rosemary"
      BusinessUnit = "publishing"
      Project      = "some-project"
      Purpose      = "test"
    }
  }
}

# variables.tf
variable "environment" {
  description = "Target deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# locals.tf
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# main.tf
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# outputs.tf
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}
```

---

## Phase 3: Review and Test

Run `terraform init -nocolor` to initialize the state.

Run `terraform fmt -recursive` to format the configuration.

Run `terraform validate -nocolor` to validate the configuration.
If validate fails, try to fix and re-validate before proceeding
to plan.

### Phase Transition Checklist

Before proceeding to Phase 4, verify:
- [ ] `terraform init` completed successfully
- [ ] `terraform fmt` applied to all files
- [ ] `terraform validate` passed with no errors
- [ ] All provider versions locked
- [ ] Backend configuration correct
- [ ] No syntax errors in configuration

---

## Phase 4: Deployment & Debugging

- `create_workspace` under the `applications` project.
- Provide [steps](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/vcs) to set up VCS manually for workspace
- Wait for user to complete before `create_run`. Add a comment to HCP Terraform `Requested by IBM Bob`.

### Phase Transition Checklist

Before proceeding to Phase 5, verify:
- [ ] Workspace created successfully
- [ ] VCS integration configured (if applicable)
- [ ] Variables attached to workspace
- [ ] Run completed successfully or errors documented
- [ ] User has reviewed run output

---

## Phase 5: Compliance Review

### Security Review

Review the Terraform configuration and provide a list of suggestions
on how to secure it better. Consider:

- Encryption at rest and in transit
- IAM roles and policies (principle of least privilege)
- Network security (security groups, NACLs)
- Secrets management (AWS Secrets Manager usage)
- Public exposure of resources
- Logging and monitoring configuration

### Cost Estimation

Use Infracost CLI to provide cost estimates for the deployed infrastructure:

```bash
infracost breakdown --path .
```

**Cost Analysis Guidelines:**
- Include monthly cost estimates in the review
- Highlight any resources with significant costs (>$100/month)
- Note any resources with variable costs based on usage
- If Infracost cannot estimate a resource, note "Cost unknown - manual review required"
- Provide cost optimization recommendations from Infracost output
- Compare against budget constraints if provided

**Example Cost Output:**
```
Estimated Monthly Cost: $245.67

Breakdown:
- EKS Cluster: $73.00/month
- EC2 Instances (t3.medium x2): $60.74/month
- ALB: $22.50/month
- RDS (db.t3.small): $89.43/month
- Cost unknown: AWS Secrets Manager (usage-based)

Cost Optimization Recommendations:
- Consider Reserved Instances for EC2 (potential 30% savings)
- RDS storage can be optimized with gp3 instead of gp2
```

### Compliance Checklist

Verify the configuration meets organizational requirements:
- [ ] All resources have required tags (ManagedBy, Environment, OwnedBy, BusinessUnit, Project, Purpose)
- [ ] Secrets stored in AWS Secrets Manager (not hardcoded)
- [ ] IAM roles follow least privilege principle
- [ ] Encryption enabled for data at rest
- [ ] Encryption enabled for data in transit
- [ ] Network security properly configured
- [ ] Logging and monitoring enabled
- [ ] Cost estimate within acceptable range
- [ ] No public modules used (only private vetted modules)

---

## Phase 6: Debugging

If the user reports a failed run, follow this systematic approach:

### 1. Analyze Error Logs
- Go to HCP Terraform run and review the error output
- Download the diagnostic file if available
- Upload the diagnostic file to IBM Bob for analysis

### 2. Common Error Patterns & Solutions

#### Kubernetes Errors

**ImagePullBackOff / ErrImagePull**
- Check image name and tag are correct
- Verify image registry credentials (imagePullSecrets)
- Confirm image exists in registry
- Check network connectivity to registry

**CrashLoopBackOff**
- Check pod logs: `kubectl logs <pod-name> -n <namespace>`
- Review container startup command and arguments
- Verify environment variables and configuration
- Check resource limits (CPU/memory)

**Pending Pods**
- Check node resources: `kubectl describe nodes`
- Verify PVC status: `kubectl get pvc -n <namespace>`
- Check for missing StorageClass
- Review pod scheduling constraints (nodeSelector, affinity)

**PVC Provisioning Failed**
- Verify StorageClass exists: `kubectl get storageclass`
- Check storage provisioner is running
- Confirm sufficient storage quota
- **Defer to platform team if StorageClass is missing**

#### Terraform Errors

**State Lock Errors**
- Check for stuck locks in HCP Terraform
- Verify no concurrent runs

**Provider Authentication Failures**
- Verify AWS credentials in variable sets
- Check IAM role permissions
- Confirm region is correct

**Resource Already Exists**
- Check if resource was created outside Terraform
- Consider importing with the Terraform `import` block
- Review for naming conflicts

**Resource Quota Exceeded**
- Check AWS service quotas
- Review account limits
- Request quota increase if needed

**Timeout Errors**
- Increase timeout values in resource configuration
- Check network connectivity
- Verify dependent resources are healthy

### 3. Debugging Commands

```bash
# Kubernetes debugging
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Check PVC status
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Check services and ingress
kubectl get svc -n <namespace>
kubectl get ingress -n <namespace>
kubectl describe ingress <ingress-name> -n <namespace>
```

### 4. Escalation Criteria

**Defer to platform engineering team if:**
- Missing cluster-level resources (StorageClass, IngressClass)
- Cluster configuration issues (CNI, CSI drivers)
- Node-level problems
- Cluster autoscaling issues
- Network policy conflicts
- RBAC/IAM role binding issues at cluster level

### Example

```text
User: The run failed to deploy the Helm release. Diagnostic logs
are in `logs/`.

Agent: I see the error is that the Helm chart timed out. Let me check
`kubectl get pods -n bobs-book-agent` to get the status of the release.

Agent: I see that the release is stuck on `Pending`. Let me check the
Kubernetes logs for the release.

Agent: From `kubectl describe pvc -n bobs-book-agent data-postgresql-0`,
the PVC failed with `Warning  ProvisioningFailed  4m21s (x122 over 34m)  persistentvolume-controller  storageclass.storage.k8s.io "gp3" not found`.

This is a cluster-level issue - the gp3 StorageClass is not configured in the cluster.
This requires platform team intervention to:
1. Create the gp3 StorageClass
2. Configure the EBS CSI driver if not already installed
3. Verify IAM permissions for EBS volume provisioning

Reach out to your platform engineering team for help.
```



---

## Phase 7: Rollback & Recovery

If a deployment fails or needs to be rolled back, follow this systematic approach:

### 1. Assess the Situation

Determine the scope and impact:
- Which resources were successfully created?
- Which resources failed?
- Are there any resources in an inconsistent state?
- Is the failure blocking other operations?

### 2. Terraform State Management

**For Stuck Resources:**
```bash
# View current state
terraform state list

# Remove stuck resource from state (does not delete actual resource)
terraform state rm <resource_address>

# Re-import if needed
terraform import <resource_address> <resource_id>
```

**For State Lock Issues:**
```bash
# Check lock status in HCP Terraform UI
# Force unlock only if absolutely necessary and no other runs are active
```

### 3. Rollback Strategies

**Option A: Destroy Failed Resources**
```bash
# Target specific failed resources
terraform destroy -target=<resource_address>

# Or destroy all resources if needed
terraform destroy
```

**Option B: Restore Previous Configuration**
1. Revert code changes in Git
2. Create new run in HCP Terraform
3. Apply previous working configuration

**Option C: Manual Cleanup**
For resources not managed by Terraform state:
1. Document the resource IDs
2. Use AWS CLI or Console to manually delete
3. Update Terraform state if needed

### 4. Kubernetes-Specific Rollback

**For Failed Helm Releases:**
```bash
# Check release status
helm list -n <namespace>

# Rollback to previous revision
helm rollback <release-name> <revision> -n <namespace>

# Or uninstall completely
helm uninstall <release-name> -n <namespace>
```

**For Failed Kubernetes Resources:**
```bash
# Delete specific resources
kubectl delete <resource-type> <resource-name> -n <namespace>

# Delete entire namespace (caution!)
kubectl delete namespace <namespace>
```

### 5. Recovery Checklist

After rollback, verify:
- [ ] All failed resources removed from AWS/Kubernetes
- [ ] Terraform state is consistent
- [ ] No orphaned resources consuming costs
- [ ] HCP Terraform workspace is unlocked
- [ ] Root cause documented
- [ ] Prevention measures identified

### 6. Post-Rollback Actions

1. **Document the incident:**
   - What failed and why
   - Steps taken to rollback
   - Resources that required manual cleanup
   - Lessons learned

2. **Update configuration:**
   - Fix the root cause
   - Add validation to prevent recurrence
   - Update tests if applicable

3. **Communicate:**
   - Notify stakeholders of rollback
   - Provide timeline for retry
   - Share lessons learned

### Common Rollback Scenarios

**Scenario: Partial Deployment Failure**
- Some resources created, others failed
- Action: Use `terraform destroy -target` for failed resources
- Then fix and re-apply

**Scenario: State Corruption**
- Terraform state doesn't match reality
- Action: Use `terraform state rm` and `terraform import`
- Or restore state from backup in HCP Terraform

**Scenario: Kubernetes Resource Conflicts**
- Resources exist but Terraform can't manage them
- Action: Delete manually with kubectl, then re-apply

**Scenario: Cost Overrun**
- Deployed resources exceed budget
- Action: Immediate `terraform destroy` of expensive resources
- Redesign with cost constraints

### Prevention Best Practices

- Always review `terraform plan` before applying
- Use `-target` flag for incremental deployments
- Test in nonprod environment first
- Keep state backups (automatic in HCP Terraform)
- Document all manual changes
- Use version control for all configuration changes
