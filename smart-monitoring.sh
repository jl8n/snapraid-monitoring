#!/bin/bash
# smart_monitor.sh

# Source the environment variables from .env
source .env

# Check that all required variables are set
if [ -z "$GOTIFY_SERVER_URL" ] || [ -z "$GOTIFY_TOKEN" ] || [ -z "$PRIORITY" ] || [ -z "$DRIVES" ]; then
    echo "Missing required configuration in .env"
    exit 1
fi

GOTIFY_URL="${GOTIFY_SERVER_URL}/message?token=${GOTIFY_TOKEN}"

# Convert the comma-separated DRIVES variable into an array
IFS=',' read -r -a drive_array <<< "$DRIVES"

# Initialize alert flag and report message
alert=0
alert_msg="S.M.A.R.T. Report:\n"

# Loop through each drive and check its SMART health
for drive in "${drive_array[@]}"; do
    output=$(smartctl -H /dev/$drive)
    # Try two common ways to extract the health status
    health=$(echo "$output" | grep -i "SMART Health Status" | awk -F': ' '{print $2}')
    if [ -z "$health" ]; then
        health=$(echo "$output" | grep -i "SMART overall-health self-assessment test result" | awk -F': ' '{print $2}')
    fi

    # Determine if the drive passed the health check
    if [[ "$health" != *"PASSED"* ]]; then
        status="FAILED"
        alert=1
    else
        status="PASSED"
    fi

    alert_msg+="Drive /dev/$drive: $status ($health)\n"
done

# If any drive failed, send a Gotify notification
if [ $alert -eq 1 ]; then
    payload=$(printf '{"title": "SMART Alert", "message": "%s", "priority": %d}' "$alert_msg" "$PRIORITY")
    curl -X POST "$GOTIFY_URL" \
         -H "Content-Type: application/json" \
         -d "$payload"
fi
