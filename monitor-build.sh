#!/bin/bash
# Monitor GitHub Actions and show status

REPO="MilkywayRides/Linux"

while true; do
    clear
    echo "=== BlazeNeuro Build Monitor ==="
    echo "Checking: https://github.com/$REPO/actions"
    echo ""
    
    # Get latest workflow run
    gh run list --repo $REPO --limit 1 --json status,conclusion,name,createdAt
    
    echo ""
    echo "Press Ctrl+C to stop monitoring"
    echo "Refreshing in 30 seconds..."
    sleep 30
done
