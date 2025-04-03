#!/bin/bash

# Script to grant standard users rights to install macOS updates without admin credentials

# Array of authorizationdb rights to adjust
rights=(
  "system.install.apple-software"
  "system.install.software"
  "system.install.os.install"
)

# Function to update authorization rights
update_rights() {
  local right="$1"
  echo "Updating authorization right: $right"
  if /usr/bin/security authorizationdb write "$right" authenticate-session-user; then
    echo "Successfully updated $right"
  else
    echo "Failed to update $right" >&2
  fi
}

# Iterate through each right and update
for right in "${rights[@]}"; do
  update_rights "$right"
done

# Verify changes
verify_rights() {
  local right="$1"
  echo "Verifying authorization right: $right"
  output=$(/usr/bin/security authorizationdb read "$right")
  if echo "$output" | grep -q "authenticate-session-user"; then
    echo "Verification successful for $right"
  else
    echo "Verification failed for $right" >&2
  fi
}

# Verify each right
for right in "${rights[@]}"; do
  verify_rights "$right"
done

echo "Script completed at $(date)"

exit 0
