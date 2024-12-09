#!/bin/bash

# Get the current uptime in days by parsing the output of the `uptime` command.
# The `uptime` command typically returns something like:
#  "13:32  up 16 days,  2:53, 2 users, load averages: 1.45 1.38 1.31"
days=$(uptime | awk -F'( |,)' '{for(i=1;i<=NF;i++){if($i~/day/) {print $(i-1)}}}')

# If the system has been up less than one full day, `days` will be empty. 
# Set it to 0 in that case.
if [ -z "$days" ]; then
    days=0
fi

# Check if uptime is greater than 14 days
if [ "$days" -gt 14 ]; then
    /usr/local/bin/dialog \
        --title "Recommended Reboot" \
        --message "Your device has been running for over 14 days without a reboot. Regular reboots help maintain optimal performance and stability. Please save your work and reboot your machine at your earliest convenience." \
        --icon caution \
        --height 200 \
        --width 400 \
        --button1text "OK" \
        --button1action "quit"
fi
