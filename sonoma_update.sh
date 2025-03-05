#!/bin/bash

# Define variables
VERSION="14.7.4"

# Start the installer download
printf "Downloading macOS %s installer...\n" "$VERSION"

if softwareupdate --fetch-full-installer --full-installer-version "$VERSION"; then
    echo "macOS $VERSION installer downloaded successfully."
    exit 0
else
    echo "Error: Failed to download macOS $VERSION installer." >&2
    exit 1
fi
