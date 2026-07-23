---
name: hcp-terraform-deploy
description: Skill for planning, applying, and monitoring Terraform deployment. Use this skill any time someone needs to deploy to HCP Terraform, trigger a Terraform run, apply infrastructure changes, or monitor plans and applies through tfctl.
---

# HCP Terraform Deploy

## Overview

Follow a to-do list to start a run, review a plan, and apply the changes to
a Terraform workspace with `tfctl`.

1. Verify the HCP Terraform organization and workspace exist using `tfctl`.
2. Start a run based on the organization and workspace name. Note the run ID returned.
3. Monitor the plan by running the skill's monitoring script at `scripts/check-run-status.sh <run-id> 60` — this polls every 60 seconds until the plan reaches a terminal state.
4. If the plan succeeds, approve the apply with the comment "Approved with IBM Bob".
5. Monitor the apply by running `scripts/check-run-status.sh <run-id> 180` — this polls every 3 minutes until the apply reaches a terminal state.
6. If the apply succeeds, finish the task.

If any of these steps fail in an error, stop and debug using the steps below before waiting for review.

## Monitoring Script

The monitoring script lives inside this skill directory. Always reference it by its full skill path — do **not** copy it into the repository.

```bash
# Full path to the script (never copy to repo)
/Users/rosemary/.bob/skills/hcp-terraform-deploy/scripts/check-run-status.sh

# Poll plan status every 60 seconds (up to 10 checks)
bash /Users/rosemary/.bob/skills/hcp-terraform-deploy/scripts/check-run-status.sh run-ABC123 60

# Poll apply status every 3 minutes (up to 10 checks)
bash /Users/rosemary/.bob/skills/hcp-terraform-deploy/scripts/check-run-status.sh run-ABC123 180
```

Exit codes returned by the script:
- `0` — run reached a successful terminal state (`applied`, `planned`, `planned_and_finished`)
- `1` — run failed or was cancelled; apply logs are printed automatically
- `2` — max checks reached without a terminal state; check HCP Terraform UI

## Debugging a Failed Plan

When the monitoring script exits with code `1` (errored), use these `tfctl` calls to diagnose the failure.

### 1. Get the plan and apply IDs for the run

```bash
source tfctl.env && tfctl api /runs/<run-id> --jq '.data.relationships | {plan: .plan.data.id, apply: .apply.data.id}'
```

### 2. Get the plan log URL

```bash
source tfctl.env && tfctl api /plans/<plan-id> --jq '.data.attributes.["log-read-url"]'
```

### 3. Fetch and grep the plan log for errors

```bash
source tfctl.env && tfctl api /plans/<plan-id> --jq '.data.attributes.["log-read-url"]' | xargs curl -s | grep -E '"@level":"error"|Error' | head -30
```

This surfaces Terraform diagnostic messages (e.g. `Cannot import non-existent remote object`) that explain exactly why the plan failed.