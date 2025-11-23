#!/bin/bash

# Test CI stability by running multiple workflow runs
# This script will trigger multiple CI runs and collect timing data

set -e

RUNS_COUNT=10
WORKFLOW_FILE="main.yml"
RESULTS_FILE="ci_stability_results.txt"

echo "=== CI Stability Test ===" > "$RESULTS_FILE"
echo "Testing test-next job stability with $RUNS_COUNT runs" >> "$RESULTS_FILE"
echo "Started at: $(date)" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Array to store run IDs
declare -a run_ids=()

echo "Triggering $RUNS_COUNT workflow runs..."

# Trigger multiple workflow runs
for i in $(seq 1 $RUNS_COUNT); do
    echo "Triggering run $i/$RUNS_COUNT..."
    
    # Trigger workflow run and capture the run ID
    run_url=$(gh workflow run "$WORKFLOW_FILE" --ref develop 2>&1 | grep "https://github.com" || echo "")
    
    if [[ -n "$run_url" ]]; then
        # Extract run ID from URL
        run_id=$(echo "$run_url" | grep -o '[0-9]\+$')
        run_ids+=("$run_id")
        echo "  Run $i triggered: $run_id"
    else
        echo "  Failed to trigger run $i"
    fi
    
    # Wait a bit between triggers to avoid rate limiting
    sleep 5
done

echo ""
echo "Triggered ${#run_ids[@]} runs: ${run_ids[*]}"
echo ""

# Wait for runs to start
echo "Waiting 30 seconds for runs to start..."
sleep 30

# Monitor the runs
echo "Monitoring runs..."
echo "" >> "$RESULTS_FILE"
echo "Run Results:" >> "$RESULTS_FILE"
echo "============" >> "$RESULTS_FILE"

all_completed=false
max_wait=1800  # 30 minutes
wait_time=0
check_interval=30

while [[ "$all_completed" == false ]] && [[ $wait_time -lt $max_wait ]]; do
    all_completed=true
    
    for run_id in "${run_ids[@]}"; do
        if [[ -n "$run_id" ]]; then
            status=$(gh run view "$run_id" --json status --jq '.status' 2>/dev/null || echo "unknown")
            
            if [[ "$status" == "in_progress" || "$status" == "queued" ]]; then
                all_completed=false
            fi
        fi
    done
    
    if [[ "$all_completed" == false ]]; then
        echo "Some runs still in progress... waiting $check_interval seconds"
        sleep $check_interval
        wait_time=$((wait_time + check_interval))
    fi
done

echo ""
echo "Collecting results..."

# Collect detailed results
for i in "${!run_ids[@]}"; do
    run_id="${run_ids[$i]}"
    run_num=$((i + 1))
    
    if [[ -n "$run_id" ]]; then
        echo ""
        echo "=== Run $run_num (ID: $run_id) ===" >> "$RESULTS_FILE"
        
        # Get run details
        run_details=$(gh run view "$run_id" --json status,conclusion,createdAt,updatedAt,jobs 2>/dev/null || echo "{}")
        
        status=$(echo "$run_details" | jq -r '.status // "unknown"')
        conclusion=$(echo "$run_details" | jq -r '.conclusion // "unknown"')
        created_at=$(echo "$run_details" | jq -r '.createdAt // "unknown"')
        updated_at=$(echo "$run_details" | jq -r '.updatedAt // "unknown"')
        
        echo "Status: $status" >> "$RESULTS_FILE"
        echo "Conclusion: $conclusion" >> "$RESULTS_FILE"
        echo "Created: $created_at" >> "$RESULTS_FILE"
        echo "Updated: $updated_at" >> "$RESULTS_FILE"
        
        # Calculate duration if both timestamps are available
        if [[ "$created_at" != "unknown" && "$updated_at" != "unknown" ]]; then
            # Convert to epoch time and calculate difference
            created_epoch=$(date -d "$created_at" +%s 2>/dev/null || echo "0")
            updated_epoch=$(date -d "$updated_at" +%s 2>/dev/null || echo "0")
            
            if [[ $created_epoch -gt 0 && $updated_epoch -gt 0 ]]; then
                duration=$((updated_epoch - created_epoch))
                duration_min=$((duration / 60))
                duration_sec=$((duration % 60))
                echo "Duration: ${duration_min}m ${duration_sec}s" >> "$RESULTS_FILE"
            fi
        fi
        
        # Get test-next job details
        test_next_job=$(echo "$run_details" | jq -r '.jobs[] | select(.name == "test-next") | .conclusion // "unknown"')
        if [[ "$test_next_job" != "unknown" ]]; then
            echo "test-next job: $test_next_job" >> "$RESULTS_FILE"
        fi
        
        echo "" >> "$RESULTS_FILE"
        
        echo "Run $run_num: $status/$conclusion"
    else
        echo "Run $run_num: Failed to trigger" >> "$RESULTS_FILE"
        echo "Run $run_num: Failed to trigger"
    fi
done

echo "" >> "$RESULTS_FILE"
echo "Test completed at: $(date)" >> "$RESULTS_FILE"

# Summary
echo ""
echo "=== SUMMARY ===" >> "$RESULTS_FILE"

success_count=0
failure_count=0
error_count=0

for run_id in "${run_ids[@]}"; do
    if [[ -n "$run_id" ]]; then
        conclusion=$(gh run view "$run_id" --json conclusion --jq '.conclusion' 2>/dev/null || echo "unknown")
        
        case "$conclusion" in
            "success")
                success_count=$((success_count + 1))
                ;;
            "failure")
                failure_count=$((failure_count + 1))
                ;;
            *)
                error_count=$((error_count + 1))
                ;;
        esac
    else
        error_count=$((error_count + 1))
    fi
done

total_runs=${#run_ids[@]}
success_rate=$(( (success_count * 100) / total_runs ))

echo "Total runs: $total_runs" >> "$RESULTS_FILE"
echo "Successful: $success_count" >> "$RESULTS_FILE"
echo "Failed: $failure_count" >> "$RESULTS_FILE"
echo "Errors/Unknown: $error_count" >> "$RESULTS_FILE"
echo "Success rate: $success_rate%" >> "$RESULTS_FILE"

echo ""
echo "Results written to $RESULTS_FILE"
echo "Summary:"
echo "  Total runs: $total_runs"
echo "  Successful: $success_count"
echo "  Failed: $failure_count"
echo "  Errors/Unknown: $error_count"
echo "  Success rate: $success_rate%"

# Show the results file
echo ""
echo "=== DETAILED RESULTS ==="
cat "$RESULTS_FILE"
