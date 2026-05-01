---
name: platform-engineer
description: Skill for architecting and designing cloud infrastructure like AWS EC2, VPC, load balancers, RDS, S3, OpenSearch, and EKS with infrastructure as code and Terraform. Use when user asks for generating Terraform configuration based on an ARCHITECTURE.md file. This skill creates Terraform or .tf files based on an architecture proposal.
---

# Platform Engineer Skill

## Overview

Design and architect cloud infrastructure that is secure, production-ready, and
compliant with organization standards. 

Generate Terraform and .tf files based on the architecture proposal outlined in `ARCHITECTURE.md`.

---

## Phase 1: Implementation

Activate the terraform-style-guide skill for more complete instructions on general best practices
to write Terraform. Apply the following organzation-specific requirements as well.

### 1.1 Generate provider blocks

`get_latest_provider_version` on the Terraform MCP server to
get the latest provider version before generating code.

When possible, use data sources to retrieve information
from AWS about Kubernetes and other components. If the cluster
name is not specified by the user, prompt the user for
more information.

#### AWS provider block

Check AWS credentials are set up in HCP Terraform using a variable set.

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

**NEVER guess on defaults tags. If you do not know, prompt the user to specify the correct tags.**

#### Kubernetes provider block

```hcl
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
```

### 1.2 Generate backend.tf file

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
variable "region" {
  type        = string
  description = "AWS region"
}

# locals.tf
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, length(var.vpc_private_subnets))
}

# main.tf
data "aws_availability_zones" "available" {
  state = "available"
}

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

  owners = local.owners
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

## Phase 2: Review and Test

Run `terraform init -nocolor` to initialize the state.

Run `terraform fmt -recursive` to format the configuration.

Run `terraform validate -nocolor` to validate the configuration.
If validate fails, try to fix and re-validate before proceeding
to plan.

### Phase Transition Checklist

Before proceeding, verify:
- [ ] `terraform init` completed successfully
- [ ] `terraform fmt` applied to all files
- [ ] `terraform validate` passed with no errors
- [ ] All provider versions locked
- [ ] Backend configuration correct
- [ ] No syntax errors in configuration

---

## Phase 3: Deployment

- `create_workspace` under the HCP Terraform organization and project specified by user.
- Provide [steps](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/vcs) to set up VCS manually for workspace
- Wait for user to complete before `create_run`. Add a comment to HCP Terraform `Requested by IBM Bob`.

### Phase Transition Checklist

Before proceeding, verify:
- [ ] Workspace created successfully
- [ ] VCS integration configured (if applicable)
- [ ] Variables attached to workspace
- [ ] Run completed successfully or errors documented
- [ ] User has reviewed run output

---

## Phase 4: Debugging

If the user reports a failed run, follow this systematic approach:

### 4.1 Analyze Error Logs
- Prompt the user to go to the run and download the diagnostic file
- Upload the diagnostic file to IBM Bob for analysis

### 4.2 Escalation Criteria

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