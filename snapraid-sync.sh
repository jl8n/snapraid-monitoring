#!/bin/bash

# Read vars from .env
source .env  

# Check that environment variables are set
if [ -z "$GOTIFY_SERVER_URL" ] || [ -z "$GOTIFY_TOKEN" ]; then
  echo "Error: Environment variables not set." >&2
  exit 1
fi

# Construct Gotify URL from .env vars
GOTIFY_URL="${GOTIFY_SERVER_URL}/message?token=${GOTIFY_TOKEN}"

# Run SnapRAID sync and capture exit code
sync_log=$(snapraid sync 2>&1)
sync_status=$?

# Prepare message based on `snapraid sync` exit code
if [ "$sync_status" -eq 0 ]; then
    title="SnapRAID Sync Successful"
    priority=5
else
    title="SnapRAID Sync Failed"
    priority=1
fi

# Send notification using Gotify
curl "${GOTIFY_URL}" -F "title=${title}" -F "message=${sync_log}" -F "priority=${priority}"
