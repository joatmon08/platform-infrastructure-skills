---
name: platform-architect
description: Skill for architecting and designing cloud infrastructure like AWS EC2, VPC, load balancers, RDS, S3, OpenSearch, and EKS with infrastructure as code and Terraform. Use when the user asks about infrastructure and deployments on AWS and Kubernetes, generating Terraform configuration, or needs assistance with platform or DevOps skills to design and deploy cloud architecture. This skill does not generate Terraform or .tf files, as its main outcome is on architecture and design review.
---

# Platform Architect Skill

## Overview

Design and architect cloud infrastructure that is secure, production-ready, and
compliant with organization standards. 

Output the plan for deploying and implementing infrastructure in a proposal document called `ARCHITECTURE.md`.

---

# Process

## Phase 1: Prerequisites

Get the following information from the user:

- HCP Terraform organization: default `alice-publishing`
- HCP Terraform project: default `applications`
- Environment: default`nonprod`, can be `nonprod` or `prod`
- OwnedBy
- BusinessUnit
- Project
- Purpose

Before proceeding to Phase 2, verify:
- [ ] User has specified all information for HCP Terraform
- [ ] User has specified all information for tags

## Phase 2: Design

### Identify required infrastructure resources

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

### Discover available Terraform modules and Helm charts

1. Check if private Terraform modules or Helm charts exist for a resource
  2. Only use raw resources if:
    - No private module or public Helm chart exists
    - The module or chart doesn't meet specific requirements
3. Document why raw resources are used instead

#### Helm

Search for Helm charts using `helm search hub <keyword>`.

```markdown
| Service | Helm Chart Available? | Repository | Chart Name | Chart Version |
|---------|----------------------|------------|------------|---------|
| Qdrant  | Yes                  | https://qdrant.github.io/qdrant-helm | qdrant | 0.8.4 |
```

#### Terraform

Search for private modules with `search_private_modules` (organization-specific only).
Check latest stable version with `get_private_module details`.

```markdown
| Resources | Module Source | Version |
|---------|----------------------|------------|
| Cloudflare DNS Record | app.terraform.io/alice-publishing/alb-dns/cloudflare | 0.0.1 |
```

### Other Kubernetes resources

For other Kubernetes resources not addressed by Helm charts:

- Use AWS ALB Ingress
- Create a service account on Kubernetes for each service
- Each service has its own namespace, do not deploy to default

```markdown
- Deployment
- PVC
- Service
- ServiceAccount
- Ingress
- Secret
```

### Other Terraform resources

For other Terraform resources not addressed by private modules:

- `get_latest_provider_version` to get provider version
- `get_provider_details` to evaluate if the provider offers the resources required.
- Using the list of products and services to achieve the architecture,
find their equivalent resources and data sources in the provider
with `get_provider_capabilities`.
- If the user requests the resources be created on an existing resource,
suggest a list of Terraform data sources to use.

```markdown
#### Providers

| Provider | Version |
|---------|----------|
| `hashicorp/aws` | 6.43.0 |

#### Data Sources

- `data.aws_ami`
- `data.aws_availability_zones`
- `data.aws_region`
- `data.aws_caller_identity`
- `data.aws_elb_service_account`

#### Resources

Networking

- `aws_vpc`
- `aws_internet_gateway`
- `aws_subnet` (public)
- `aws_subnet` (private)
- `aws_route_table` (public)
- `aws_route_table` (private)
- `aws_route_table_association` (public)
- `aws_route_table_association` (private)
- `aws_route`
```

### Checklist

- [ ] User has approved the resource list
- [ ] All required variables have been identified
- [ ] Architecture aligns with AWS/HashiCorp best practices
- [ ] Private modules identified for all applicable resources
- [ ] Helm charts identified for Kubernetes services
- [ ] User understands the deployment approach

### Example

Refer to `EXAMPLE.md` for a full example of how to structure the architecture proposal.

## Recovery

If the user does not approve the `ARCHITECTURE.md`, prompt the user for feedback and repeat the process.

## External References

- [AWS Architecture Center](https://aws.amazon.com/architecture/reference-architecture-diagrams)
- [HashiCorp Well-Architected Framework](https://developer.hashicorp.com/well-architected-framework)