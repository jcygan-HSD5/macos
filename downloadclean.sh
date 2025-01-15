#!/bin/bash
# Directory to scan
target_directory="/Users/laptop/Downloads"
# Find and delete files not accessed in over 90 days
find "$target_directory" -type f -atime +90 -exec rm -f {} \;
# Log the action
log_file="/var/log/delete_old_files.log"
echo "$(date): Deleted files not accessed in over 90 days from $target_directory" >> "$log_file"
# Set permissions for the log file (if necessary)
chmod 600 "$log_file"
exit 0
