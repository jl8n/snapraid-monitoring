#!/bin/bash

# Read vars from .env
source .env  

# Construct Gotify URL from .env vars
GOTIFY_URL="$GOTIFY_SERVER-URL/message?token=$GOTIFY_TOKEN"

# Run SnapRAID sync and capture exit code
snapraid sync && sync_status=$?

# Prepare message based on `snapraid sync` exit code
if [ $sync_status -eq 0 ]; then
    title="SnapRAID Sync Successful"
    message="Your SnapRAID sync completed without errors."
    priority=5
else
    title="SnapRAID Sync Failed"
    message="Check the logs for details on your SnapRAID sync error."
    priority=8
fi

# GOTIFY vars are sourced from the .env file
curl "$GOTIFY_URL" -F "title=$title" -F "message=$message" -F "priority=2"