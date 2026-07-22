---
name: hcp-terraform-deployer
description: Skill for planning, applying, and monitoring Terraform deployment. Use this skill any time someone needs to deploy to HCP Terraform, trigger a Terraform run, apply infrastructure changes, or monitor plans and applies through tfctl.
---

# HCP Terraform Deployer

## Overview

Follow a to-do list to start a run, review a plan, and apply the changes to
a Terraform workspace with `tfctl`.

1. Verify that the Terraform MCP server is available.
2. Verify the HCP Terraform organization.
3. Verify the HCP Terraform workspace.
4. Start a run based on the organization and workspace name. Note the run ID returned.
5. Monitor the plan by running `scripts/check-run-status.sh <run-id> 60` — this polls every 60 seconds until the plan reaches a terminal state.
6. If the plan succeeds, approve the apply with the comment "Approved by Bob".
7. Monitor the apply by running `scripts/check-run-status.sh <run-id> 180` — this polls every 3 minutes until the apply reaches a terminal state.
8. If the apply succeeds, finish the task.

If any of these steps fail in an error, stop and wait for me to review.

## Monitoring Script

Use `scripts/check-run-status.sh` to poll run status instead of manually querying tfctl.

```bash
# Usage
./scripts/check-run-status.sh <run-id> [interval-seconds] [max-checks]

# Poll plan status every 60 seconds (up to 10 checks)
./scripts/check-run-status.sh run-ABC123 60

# Poll apply status every 3 minutes (up to 10 checks)
./scripts/check-run-status.sh run-ABC123 180
```

Exit codes returned by the script:
- `0` — run reached a successful terminal state (`applied`, `planned`, `planned_and_finished`)
- `1` — run failed or was cancelled; apply logs are printed automatically
- `2` — max checks reached without a terminal state; check HCP Terraform UI