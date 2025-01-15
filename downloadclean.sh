#!/bin/bash

# Directory to scan
target_directory="/Users/laptop/Downloads"

# Log file path
log_file="/var/log/delete_old_files.log"

# Inform the user (console output) that the script is starting
echo "Starting old file cleanup script..."
echo "Target directory: $target_directory"

# Find files not accessed in over 90 days
echo "Scanning for files not accessed in over 90 days..."
old_files=$(find "$target_directory" -type f -atime +90 2>/dev/null)

# Check if we found any files
if [ -z "$old_files" ]; then
    echo "No files older than 90 days found. Exiting."
    exit 0
fi

# Show which files are slated for deletion
echo "Found the following files to delete:"
echo "$old_files"

# Now delete the files
echo "Deleting files..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        rm -v "$file"
    fi
done <<< "$old_files"

# Log the action
echo "$(date): Deleted files not accessed in over 90 days from $target_directory" >> "$log_file"

# Set permissions for the log file (if necessary)
chmod 600 "$log_file"

echo "Cleanup complete. Log file updated at $log_file."

exit 0
