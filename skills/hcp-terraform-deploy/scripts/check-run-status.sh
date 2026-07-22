#!/bin/bash

# Script to check HCP Terraform run status using tfctl
# Usage: ./scripts/check-run-status.sh <run-id> [interval-seconds] [max-checks]

RUN_ID="${1}"
INTERVAL="${2:-180}"  # Default to 3 minutes (180 seconds)
MAX_CHECKS="${3:-10}" # Default to 10 checks before exiting

if [ -z "$RUN_ID" ]; then
    echo "Error: Run ID is required"
    echo "Usage: $0 <run-id> [interval-seconds] [max-checks]"
    exit 1
fi

if ! command -v tfctl &>/dev/null; then
    echo "Error: tfctl is not installed or not in PATH"
    exit 1
fi

echo "Monitoring run: $RUN_ID"
echo "Checking every $INTERVAL seconds (max $MAX_CHECKS checks)"
echo "Press Ctrl+C to stop monitoring"
echo ""

check_run_status() {
    local status
    local message
    local has_changes

    status=$(tfctl api /runs/"${RUN_ID}" --jq '.data.attributes.status' 2>/dev/null)
    local exit_code=$?

    if [ $exit_code -ne 0 ] || [ -z "$status" ] || [ "$status" = "null" ]; then
        echo "Error: Could not retrieve run status for ${RUN_ID} (tfctl exit code: $exit_code)"
        return 1
    fi

    message=$(tfctl api /runs/"${RUN_ID}" --jq '.data.attributes.message' 2>/dev/null)
    has_changes=$(tfctl api /runs/"${RUN_ID}" --jq '.data.attributes["has-changes"]' 2>/dev/null)

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Status: $status"

    if [ "$message" != "null" ] && [ -n "$message" ]; then
        echo "  Message: $message"
    fi

    case "$status" in
        applied)
            echo ""
            echo "✓ Run completed successfully!"
            if [ "$has_changes" = "true" ]; then
                echo "  Changes were applied to infrastructure"
            else
                echo "  No changes were needed"
            fi
            return 0
            ;;
        errored)
            echo ""
            echo "✗ Run failed with errors"
            echo ""
            echo "Getting apply logs..."
            local apply_id
            apply_id=$(tfctl api /runs/"${RUN_ID}" --jq '.data.relationships.apply.data.id' 2>/dev/null)
            if [ "$apply_id" != "null" ] && [ -n "$apply_id" ]; then
                local log_url
                log_url=$(tfctl api /applies/"${apply_id}" --jq '.data.attributes["log-read-url"]' 2>/dev/null)
                if [ "$log_url" != "null" ] && [ -n "$log_url" ]; then
                    curl -s "$log_url"
                fi
            fi
            return 1
            ;;
        canceled|discarded|force_canceled)
            echo ""
            echo "✗ Run was $status"
            return 1
            ;;
        planned)
            echo ""
            echo "✓ Plan completed - ready for apply"
            echo "Run needs manual approval in HCP Terraform UI"
            return 0
            ;;
        planned_and_finished)
            echo ""
            echo "✓ Plan completed (no apply needed)"
            return 0
            ;;
        applying|apply_queued|plan_queued|planning|queuing|pending|cost_estimating|cost_estimated|policy_checking|policy_checked|policy_override|confirmed|post_plan_running|post_plan_completed)
            echo "  Current phase: $status"
            return 2
            ;;
        *)
            echo "  Unknown phase: $status"
            return 2
            ;;
    esac
}

# Main monitoring loop
check_count=0
while true; do
    check_run_status
    exit_code=$?

    # Exit if terminal state (0 = success, 1 = failure)
    if [ $exit_code -eq 0 ] || [ $exit_code -eq 1 ]; then
        exit $exit_code
    fi

    # Continue monitoring (exit_code = 2)
    check_count=$((check_count + 1))

    if [ $check_count -ge $MAX_CHECKS ]; then
        echo ""
        echo "⚠ Maximum checks ($MAX_CHECKS) reached. Run may still be in progress."
        echo "Check HCP Terraform UI for current status: https://app.terraform.io"
        exit 2
    fi

    echo ""
    sleep "$INTERVAL"
done
