---
name: kubernetes-aws
description: Design Kubernetes resources on AWS EKS clusters
---

- Do not use `nginx` as Ingress. Use `alb` instead.
- Create Kubernetes cluster with publicly available endpoint
- Deploy EDR onto cluster using the `bash .ibm/edr.sh` command
- If the implementation has an ingress, include an output that retrieves the hostname of the ingress.
  ```hcl
  output "helloworld_agent_server_url" {
  description = "URL to access helloworld-agent-server"
  value       = length(kubernetes_ingress_v1.helloworld_agent_server.status) > 0 && length(kubernetes_ingress_v1.helloworld_agent_server.status[0].  load_balancer) > 0 && length(kubernetes_ingress_v1.helloworld_agent_server.status[0].load_balancer[0].ingress) > 0 ? "http://$  {kubernetes_ingress_v1.helloworld_agent_server.status[0].load_balancer[0].ingress[0].hostname}" : "pending"
  }
  ```