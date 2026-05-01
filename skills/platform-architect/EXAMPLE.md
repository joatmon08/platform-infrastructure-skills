---
name: platform-architect-example
description: Example for generating an ARCHITECTURE.md file for a web application over HTTPS hosted on AWS that runs in an EC2 instance.

# Architecture Proposal

## Context

This proposal is for a public web application over HTTPS hosted on AWS.
The web application runs in an EC2 instance.

## Tags

- HCP Terraform organization:  `alice-publishing`
- HCP Terraform project: `applications`
- Environment: `nonprod`
- OwnedBy: `rosemary`
- BusinessUnit: `bobs-books`
- Project: `bobs-book-agent-testing`
- Purpose: `Testing a new agent for editing books`

## Proposal

### Architecture

```
                                    ┌─────────────────────────────────────────────────────────────┐
                                    │                        Internet                              │
                                    │                                                              │
                                    │                    👤 End Users                              │
                                    │                  (HTTPS Requests)                            │
                                    └──────────────────────────┬──────────────────────────────────┘
                                                               │
                                                               │ 1. HTTPS Request (Port 443)
                                                               │
                                    ┌──────────────────────────▼──────────────────────────────────┐
                                    │              Amazon Route53 (DNS Service)                    │
                                    │                                                              │
                                    │              DNS Record: example.com                         │
                                    │              Resolves to ALB IP Address                      │
                                    └──────────────────────────┬──────────────────────────────────┘
                                                               │
                                                               │ 2. DNS Resolution
                                                               │
┌───────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    AWS Cloud                                                      │
│                                                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                    AWS Certificate Manager (ACM)                                         │    │
│  │                                                                                           │    │
│  │              SSL/TLS Certificate (*.example.com)                                         │    │
│  │              • Automatic Renewal                                                         │    │
│  │              • Free Certificate                                                          │    │
│  └────────────────────────────────────┬──────────────────────────────────────────────────┘    │
│                                        │                                                         │
│                                        │ Certificate Attached                                    │
│                                        │                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                           VPC (10.0.0.0/16)                                              │    │
│  │                                                                                           │    │
│  │  ┌────────────────────────────────────────────────────────────────────────────────┐     │    │
│  │  │                    Public Subnet (10.0.1.0/24)                                  │     │    │
│  │  │                                                                                 │     │    │
│  │  │  ┌──────────────────┐                                                          │     │    │
│  │  │  │ Internet Gateway │                                                          │     │    │
│  │  │  │                  │                                                          │     │    │
│  │  │  └────────┬─────────┘                                                          │     │    │
│  │  │           │                                                                     │     │    │
│  │  │           │ Internet Access                                                    │     │    │
│  │  │           │                                                                     │     │    │
│  │  │  ┌────────▼──────────────────────────────────────────┐                        │     │    │
│  │  │  │   Application Load Balancer (ALB)                 │                        │     │    │
│  │  │  │                                                    │                        │     │    │
│  │  │  │   • Listens on Port 443 (HTTPS)                   │◄───────────────────────┼─────┼────┤
│  │  │  │   • SSL/TLS Termination                           │    3. HTTPS Traffic    │     │    │
│  │  │  │   • Health Checks                                 │                        │     │    │
│  │  │  │   • Load Distribution                             │                        │     │    │
│  │  │  │                                                    │                        │     │    │
│  │  │  │   Security Group:                                 │                        │     │    │
│  │  │  │   • Inbound: 0.0.0.0/0 → 443 (HTTPS)             │                        │     │    │
│  │  │  └────────────────────┬───────────────────────────────┘                        │     │    │
│  │  │                       │                                                        │     │    │
│  │  └───────────────────────┼────────────────────────────────────────────────────────┘     │    │
│  │                          │                                                              │    │
│  │                          │ 4. Forward HTTP (Port 8080)                                  │    │
│  │                          │    Decrypted Traffic                                         │    │
│  │                          │                                                              │    │
│  │  ┌───────────────────────▼────────────────────────────────────────────────────────┐     │    │
│  │  │                    Private Subnet (10.0.2.0/24)                                │     │    │
│  │  │                                                                                 │     │    │
│  │  │  ┌──────────────────────────────────────────────────────────┐                  │     │    │
│  │  │  │           EC2 Instance (Web Application)                 │                  │     │    │
│  │  │  │                                                           │                  │     │    │
│  │  │  │   • Application Server                                   │                  │     │    │
│  │  │  │   • Listens on Port 8080 (HTTP)                          │                  │     │    │
│  │  │  │   • No Direct Internet Access                            │                  │     │    │
│  │  │  │   • Processes Requests                                   │                  │     │    │
│  │  │  │                                                           │                  │     │    │
│  │  │  │   Security Group:                                        │                  │     │    │
│  │  │  │   • Inbound: ALB Security Group → 8080 (HTTP)            │                  │     │    │
│  │  │  │   • No SSH from Internet                                 │                  │     │    │
│  │  │  └───────────────────────┬───────────────────────────────────┘                  │     │    │
│  │  │                          │                                                      │     │    │
│  │  │                          │ 5. Return Response                                   │     │    │
│  │  │                          │                                                      │     │    │
│  │  └──────────────────────────┼──────────────────────────────────────────────────────┘     │    │
│  │                             │                                                            │    │
│  │  ┌──────────────────────────┴──────────────────────────────────────────────────────┐     │    │
│  │  │                    Security Components                                           │     │    │
│  │  │                                                                                   │     │    │
│  │  │   • Network ACLs (Subnet Level Protection)                                       │     │    │
│  │  │   • Security Groups (Instance Level Protection)                                  │     │    │
│  │  │   • VPC Flow Logs (Network Monitoring)                                           │     │    │
│  │  └───────────────────────────────────────────────────────────────────────────────────┘     │    │
│  │                                                                                           │    │
│  └───────────────────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                                   │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌──────────────────────────────────────────────────────────────┐
                                    │                        Internet                              │
                                    │                                                              │
                                    │                    👤 End Users                              │
                                    │              (Receive HTTPS Response)                        │
                                    └──────────────────────────────────────────────────────────────┘
                                                               ▲
                                                               │
                                                               │ 6. Encrypted HTTPS Response
                                                               │
                                                        (ALB Encrypts Response)
```

#### Components

1. **Route53 (DNS Service)**
   - Manages domain name resolution
   - Routes traffic to the Application Load Balancer
   - Provides health checks and failover capabilities

2. **AWS Certificate Manager (ACM)**
   - Provides free SSL/TLS certificates
   - Automatic certificate renewal
   - Integrated with ALB for HTTPS termination

3. **Application Load Balancer (ALB)**
   - **HTTPS Termination**: Handles SSL/TLS encryption/decryption
   - Listens on port 443 (HTTPS)
   - Forwards decrypted traffic to EC2 on port 8080 (HTTP)
   - Provides health checks for EC2 instances
   - Distributes traffic across multiple instances (if scaled)

4. **VPC (Virtual Private Cloud)**
   - Isolated network environment (10.0.0.0/16)
   - Contains public and private subnets
   - Provides network-level isolation

5. **Public Subnet**
   - Contains internet-facing resources (ALB)
   - Has route to Internet Gateway
   - CIDR: 10.0.1.0/24

6. **Private Subnet**
   - Contains EC2 instance (web application)
   - No direct internet access
   - CIDR: 10.0.2.0/24

7. **EC2 Instance**
   - Hosts the web application
   - Runs in private subnet for security
   - Listens on port 8080 (HTTP)
   - Only accepts traffic from ALB

8. **Security Groups**
   - **ALB Security Group**: Allows inbound HTTPS (443) from anywhere
   - **EC2 Security Group**: Allows inbound HTTP (8080) only from ALB

9. **Internet Gateway**
   - Enables communication between VPC and internet
   - Attached to VPC for public subnet access

### Kubernetes

#### Helm Charts

| Service | Helm Chart Available? | Repository | Chart Name | Version | Command to Add Repo |
|---------|----------------------|------------|------------|---------|---------------------|
| Qdrant  | Yes                  | https://qdrant.github.io/qdrant-helm | qdrant | 0.8.4 | `helm repo add qdrant https://qdrant.github.io/qdrant-helm` |

#### Other Resources

### Terraform

#### Providers

| Provider | Version |
|---------|----------|
| `hashicorp/aws` | 6.43.0 |

#### Modules

| Resource | Module Available? | Module Source | Version |
|---------|----------------------|------------|---------|
| Cloudflare DNS Record | Yes | app.terraform.io/alice-publishing/alb-dns/cloudflare | 0.0.5 |

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

Security

- `aws_security_group` (ALB)
- `aws_security_group` (EC2)
- `aws_security_group_rule` (ALB inbound HTTPS)
- `aws_security_group_rule` (ALB outbound)
- `aws_security_group_rule` (EC2 inbound)
- `aws_security_group_rule` (EC2 outbound)

Certificates

- `aws_acm_certificate`
- `aws_acm_certificate_validation`

DNS

- `aws_route53_zone`
- `aws_route53_record` (application)
- `aws_route53_record` (certificate validation)

Load Balancing

- `aws_lb`
- `aws_lb_target_group`
- `aws_lb_listener`
- `aws_lb_target_group_attachment`
- `aws_lb_listener_rule`

Compute

- `aws_instance`
- `aws_key_pair`
- `aws_iam_role`
- `aws_iam_role_policy_attachment`
- `aws_iam_instance_profile`