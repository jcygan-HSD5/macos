#!/bin/bash

# Define the application name and path
APP_NAME="ToshibaElevateSkyPrintManagement"
APP_PATH="/Applications/$APP_NAME.app"

# Check if the application exists
if [ -d "$APP_PATH" ]; then
    echo "Found $APP_NAME. Removing the application..."

    # Attempt to quit the application if it's running
    pkill -f "$APP_NAME" 2>/dev/null

    # Remove the application
    rm -rf "$APP_PATH"
    echo "$APP_NAME has been removed."
else
    echo "$APP_NAME not found. Skipping removal."
fi

# Remove related files for the "laptop" user
USER_HOME="/Users/laptop"
USER_LIB_PATH="$USER_HOME/Library"

echo "Removing related files for user: laptop..."
RELATED_FILES=(
    "$USER_LIB_PATH/Application Support/$APP_NAME"
    "$USER_LIB_PATH/Preferences/com.toshiba.$APP_NAME.plist"
    "$USER_LIB_PATH/Caches/com.toshiba.$APP_NAME"
)

for FILE in "${RELATED_FILES[@]}"; do
    if [ -e "$FILE" ]; then
        rm -rf "$FILE"
        echo "Removed $FILE"
    else
        echo "File $FILE not found. Skipping..."
    fi
done

echo "Uninstallation process complete."

exit 0
