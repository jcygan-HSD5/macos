#!/bin/bash

# Define the application name and path
APP_NAME="ToshibaElevateSkyPrintManagement"
APP_PATH="/Applications/$APP_NAME.app"

# Attempt to quit the application if it's running
echo "Attempting to quit $APP_NAME..."
pkill -f "$APP_NAME" 2>/dev/null

# Identify and kill the specific 'nwjs' process associated with the application
echo "Searching for 'nwjs' processes related to $APP_NAME..."

# Get the PIDs of 'nwjs' processes that are children of the application
NWJS_PIDS=$(pgrep -f "$APP_PATH")

if [ -n "$NWJS_PIDS" ]; then
    echo "Found 'nwjs' processes: $NWJS_PIDS"
    echo "$NWJS_PIDS" | xargs kill -9
    echo "Terminated 'nwjs' processes related to $APP_NAME."
else
    echo "No 'nwjs' processes related to $APP_NAME found."
fi

# Remove the application
if [ -d "$APP_PATH" ]; then
    echo "Removing $APP_NAME application..."
    rm -rf "$APP_PATH"
    echo "$APP_NAME has been removed."
else
    echo "$APP_NAME not found in /Applications."
fi

# Remove related files for the "laptop" user
USER_HOME="/Users/laptop"
USER_LIB_PATH="$USER_HOME/Library"

echo "Removing related files for user: laptop..."

RELATED_FILES=(
    "$USER_LIB_PATH/Application Support/$APP_NAME"
    "$USER_LIB_PATH/Application Support/nwjs"
    "$USER_LIB_PATH/Preferences/com.toshiba.$APP_NAME.plist"
    "$USER_LIB_PATH/Caches/$APP_NAME"
    "$USER_LIB_PATH/Caches/nwjs"
    "$USER_LIB_PATH/LaunchAgents/com.toshiba.$APP_NAME.plist"
)

for FILE in "${RELATED_FILES[@]}"; do
    if [ -e "$FILE" ]; then
        rm -rf "$FILE"
        echo "Removed $FILE"
    else
        echo "File $FILE not found. Skipping..."
    fi
done

# Remove any LaunchAgents or LaunchDaemons
SYSTEM_LAUNCH_AGENTS="/Library/LaunchAgents"
SYSTEM_LAUNCH_DAEMONS="/Library/LaunchDaemons"

echo "Removing system-wide LaunchAgents and LaunchDaemons related to $APP_NAME..."

SYSTEM_FILES=(
    "$SYSTEM_LAUNCH_AGENTS/com.toshiba.$APP_NAME.plist"
    "$SYSTEM_LAUNCH_DAEMONS/com.toshiba.$APP_NAME.plist"
)

for FILE in "${SYSTEM_FILES[@]}"; do
    if [ -e "$FILE" ]; then
        rm -f "$FILE"
        echo "Removed $FILE"
    else
        echo "File $FILE not found. Skipping..."
    fi
done

echo "Uninstallation process complete."

exit 0
