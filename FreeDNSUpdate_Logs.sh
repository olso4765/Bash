#!/bin/bash

LOG_FILE="/tmp/freedns_Dogsand_us_to.log"
HISTORY_FILE="/tmp/freedns_history.log"
DELAY=20  # Adjust delay if needed

# Ensure log file exists with initial entry
if [ ! -s "$LOG_FILE" ]; then
    INITIAL_IP=$(curl -s http://sync.afraid.org/u/<tokenRedacted>/ | grep -oP '(?<=Updated: ).*')
    echo "$(date +'%Y-%m-%d %H:%M:%S') | DNS Updated to $INITIAL_IP" >> "$LOG_FILE"
fi

# Delay execution
sleep $DELAY

# Get current updated IP
CURRENT_IP=$(curl -s http://sync.afraid.org/u/<tokenRedacted>/ | grep -oP '(?<=Updated: ).*')

# Get last recorded IP
LAST_IP=$(tail -n 1 "$LOG_FILE" | awk -F'|' '{print $4}')

# Log only if IP has changed
if [[ "$CURRENT_IP" != "$LAST_IP" ]]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') | DNS Updated to $CURRENT_IP" | tee -a "$LOG_FILE" "$HISTORY_FILE"

    # Send Email Alert
    echo "DNS Updated to $CURRENT_IP at $(date)" | mail -s "DNS Change Alert" your@email.com
fi

# **Auto-Cleanup: Remove logs older than 30 days**
find /tmp -name "freedns_log*" -mtime +30 -exec rm {} \;


