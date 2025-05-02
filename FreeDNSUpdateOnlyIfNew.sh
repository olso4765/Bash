#!/bin/bash

LOG_FILE="/tmp/freedns_<your-subdomain>.log"
DELAY=20  # Adjust delay if needed

# Ensure log file exists with initial entry
if [ ! -s "$LOG_FILE" ]; then
    INITIAL_IP=$(curl -s http://sync.afraid.org/u/<token>/ | grep -oP '(?<=Updated: ).*')
    echo "$(date +'%Y-%m-%d %H:%M:%S') | DNS Updated to $INITIAL_IP" >> "$LOG_FILE"
fi

# Delay execution
sleep $DELAY

# Fetch currently stored IP from FreeDNS
STORED_IP=$(dig +short <your-subdomain>.afraid.org @8.8.8.8 | tail -n 1)

# Fetch current IP you’d be updating
CURRENT_IP=$(curl -s --fail http://sync.afraid.org/u/<token>/ | grep -oP '(?<=Updated: ).*')
if [[ -z "$CURRENT_IP" ]]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') | ERROR: Failed to fetch current IP" >> /tmp/freedns_errors.log
    exit 1
fi

# Compare before sending update request
if [[ "$CURRENT_IP" != "$STORED_IP" ]]; then
    curl -s http://sync.afraid.org/u/<token>/
    echo "$(date +'%Y-%m-%d %H:%M:%S') | DNS Updated to $CURRENT_IP" >> "$LOG_FILE"
    # Send Email Alert
    echo "DNS Updated to $CURRENT_IP at $(date)" | mail -s "DNS Change Alert" your@email.com
fi
