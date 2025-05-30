#!/bin/bash
export CORESVG_VERBOSE=1
# Get the current uptime in days
days=$(uptime | awk -F'( |,)' '{for(i=1;i<=NF;i++){if($i~/day/) {print $(i-1)}}}')

if [ -z "$days" ]; then
    days=0
fi

echo "Current uptime in days: $days"

 Check if uptime is greater than 30 days
if [ "$days" -gt 30 ]; then
    echo "Uptime is more than 30 days. Triggering reboot dialog..."
    /usr/local/bin/dialog \
        --title "Recommended Reboot" \
        --message "Your device has been running for over 30 days without a reboot. Regular reboots help maintain optimal performance and stability.\n\nPlease save your work. You may reboot now or at your earliest convenience." \
        --icon caution \
        --height 200 \
        --width 600 \
        --button1text "OK" \
        --button2text "Reboot Now" \
else
    echo "Uptime is not more than 30 days. No dialog displayed."
fi

# Capture the exit code of dialog
dialog_exit_code=$?

echo "Dialog exited with code: $dialog_exit_code"

# If the user clicked "Reboot Now" (button2), the exit code should be 2.
if [ $dialog_exit_code -eq 2 ]; then
    echo "User chose to reboot now. Executing reboot command..."
    sudo reboot now
else
    echo "User did not choose to reboot."
fi
