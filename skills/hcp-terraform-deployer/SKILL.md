---
name: hcp-terraform-deployer
description: Skill for planning, applying, and monitoring Terraform deployment. Use this skill for deploying infrastructure changes to HCP Terraform workspaces or monitoring current plans and applies through the Terraform MCP Server.
---

# HCP Terraform Deployer

## Overview

Follow a to-do list to start a run, review a plan, and apply the changes to
a Terraform workspace with the Terraform MCP server.

1. Verify that the Terraform MCP server is available.
2. Verify the HCP Terraform organization
3. Verify the HCP Terraform workspace
4. Start a run based on the organization and workspace name.
5. Every 1 minute, try to get plan details.
6. If the plan succeeds, approve the apply with the comment "Approved by Bob".
7. Every 3 minutes, try to get apply details.
8. If the apply succeeds, finish the task.

If any of these steps fail in an error, stop and wait for me to review.