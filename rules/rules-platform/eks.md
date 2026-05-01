---
name: eks
description: Design Kubernetes resources on AWS EKS clusters
---

## Cluster Configuration

Create Kubernetes cluster with publicly available endpoint

## Service Deployment

Deploy using Helm and Kubernetes provider for Terraform.
If a Terraform resource does not exist for a Kubernetes resource, use `kubernetes_manifest_v1`.

## Ingress

**NEVER use nginx. Always use ALB.**

- `search_private_modules` for a Terraform module to attach the ALB to a Cloudflare DNS record.
- If the implementation has an ingress, include an output that retrieves the hostname of the ingress.
  ```hcl
  output "helloworld_agent_server_url" {
  description = "URL to access helloworld-agent-server"
  value       = length(kubernetes_ingress_v1.helloworld_agent_server.status) > 0 && length(kubernetes_ingress_v1.helloworld_agent_server.status[0].  load_balancer) > 0 && length(kubernetes_ingress_v1.helloworld_agent_server.status[0].load_balancer[0].ingress) > 0 ? "http://$  {kubernetes_ingress_v1.helloworld_agent_server.status[0].load_balancer[0].ingress[0].hostname}" : "pending"
  }
  ```