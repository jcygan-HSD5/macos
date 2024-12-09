#!/bin/bash

# Get the current uptime in days
#days=$(uptime | awk -F'( |,)' '{for(i=1;i<=NF;i++){if($i~/day/) {print $(i-1)}}}')

#if [ -z "$days" ]; then
#    days=0
#fi

#echo "Current uptime in days: $days"

# Check if uptime is greater than 14 days
#if [ "$days" -gt 0 ]; then
    echo "Uptime is more than 14 days. Triggering reboot dialog..."
    /usr/local/bin/dialog \
        --title "Recommended Reboot" \
        --message "Your device has been running for over 14 days without a reboot. Regular reboots help maintain optimal performance and stability.\n\nPlease save your work. You may reboot now or at your earliest convenience." \
        --icon caution \
        --height 200 \
        --width 600 \
        --button1text "OK" \
        --button1action "quit" \
        --button2text "Reboot Now" \
        --button2action "run_command:/usr/bin/touch $HOME/dialog_command_ran"
#else
#    echo "Uptime is not more than 14 days. No dialog displayed."
#fi
