#!/bin/bash
# Uninstall Atera Agent and Splashtop Streamer - for macOS (Intel and Apple Silicon)
# This script stops and removes all components of Atera RMM Agent and Splashtop Streamer.
# Safe to run multiple times. Requires root privileges (e.g., run via Jamf as root).

### 1. Detect system architecture
arch_name=$(uname -m)
if [ "$arch_name" = "arm64" ]; then
    echo "Architecture: Apple Silicon (arm64) detected."
elif [ "$arch_name" = "x86_64" ]; then
    echo "Architecture: Intel (x86_64) detected."
else
    echo "Architecture: $arch_name detected (unrecognized type). Proceeding..."
fi

### 2. Functions to assist with process termination and file removal
# Function to kill a process if running
kill_process() {
    local proc="$1"
    if pgrep -x "$proc" > /dev/null 2>&1; then
        echo "Found running process: $proc. Terminating..."
        killall "$proc" >/dev/null 2>&1 || true   # try graceful kill
        sleep 1
        # If still running, force kill
        if pgrep -x "$proc" > /dev/null 2>&1; then
            killall -9 "$proc" >/dev/null 2>&1 || true
        fi
        echo "Process $proc terminated."
    else
        echo "No running process found for $proc."
    fi
}

# Function to unload and remove launchd plists matching a pattern
unload_and_remove_plist() {
    local pattern="$1"
    shopt -s nullglob
    for plist in /Library/LaunchDaemons/$pattern.plist /Library/LaunchAgents/$pattern.plist; do
        if [ -f "$plist" ]; then
            # Unload the LaunchDaemon/Agent to stop any running service
            launchctl unload "$plist" 2>/dev/null || true
            rm -f "$plist"
            echo "Removed launchd item $plist"
        fi
    done
    shopt -u nullglob
}

### 3. Uninstall Atera Agent (if present)
ATERA_APP="/Applications/AteraAgent.app"
ATERA_LD="/Library/LaunchDaemons/com.atera.ateraagent.plist"
ATERA_SUPPORT="/Library/Application Support/com.atera"
if [ -d "$ATERA_APP" ] || [ -f "$ATERA_LD" ] || [ -d "$ATERA_SUPPORT"* ]; then
    echo "Atera Agent detected. Proceeding with uninstallation..."
    # Terminate Atera Agent process
    kill_process "AteraAgent"
    # Unload and remove Atera launch daemon (and any launch agents if present)
    unload_and_remove_plist "com.atera.ateraagent"
    unload_and_remove_plist "com.atera.*"   # catch any other Atera launchd items
    # Remove Atera application and support files
    if [ -d "$ATERA_APP" ]; then
        rm -rf "$ATERA_APP"
        echo "Deleted $ATERA_APP"
    fi
    # Remove Atera support directories and files
    shopt -s nullglob
    for item in "/Library/Application Support/com.atera"*; do
        rm -rf "$item"
        echo "Removed Atera support file/folder: $item"
    done
    shopt -u nullglob
    # Remove Atera preferences (if any)
    rm -f /Library/Preferences/com.atera* 2>/dev/null
    rm -f /Library/Preferences/*atera* 2>/dev/null
    rm -f /var/root/Library/Preferences/com.atera* 2>/dev/null
    rm -f /Users/*/Library/Preferences/com.atera* 2>/dev/null
    # Forget any Atera package receipts
    ATERA_PKGS=$(pkgutil --pkgs | grep -i "atera")
    if [ -n "$ATERA_PKGS" ]; then
        echo "$ATERA_PKGS" | while read -r pkg; do
            sudo pkgutil --forget "$pkg" && echo "Forgot package receipt: $pkg"
        done
    fi
    echo "Atera Agent uninstall completed."
else
    echo "Atera Agent not found. Skipping Atera removal."
fi

### 4. Uninstall Splashtop Streamer (if present)
SPLASHTOP_APP="/Applications/Splashtop Streamer.app"
# Other possible app names to check (older versions or business editions)
ALT_SPL_APP1="/Applications/SplashtopRemoteStreamer.app"
ALT_SPL_APP2="/Applications/Splashtop Streamer for Business.app"
ALT_SPL_APP3="/Applications/SplashtopRemote.app"
if [ -d "$SPLASHTOP_APP" ] || [ -d "$ALT_SPL_APP1" ] || [ -d "$ALT_SPL_APP2" ] || [ -d "$ALT_SPL_APP3" ] || ls /Library/LaunchDaemons/com.splashtop.streamer* >/dev/null 2>&1; then
    echo "Splashtop Streamer detected. Proceeding with uninstallation..."
    # Terminate Splashtop Streamer processes (if running)
    kill_process "Splashtop Streamer"
    kill_process "SRServiceAgent"
    kill_process "SRServiceDaemon"
    # Unload and remove Splashtop LaunchDaemons/LaunchAgents
    unload_and_remove_plist "com.splashtop.streamer"
    unload_and_remove_plist "com.splashtop.business.SRServiceAgent"
    unload_and_remove_plist "com.splashtop.business.SRServicePreLogin"
    unload_and_remove_plist "com.splashtop.s4b"
    # Remove Splashtop application(s)
    for app in "$SPLASHTOP_APP" "$ALT_SPL_APP1" "$ALT_SPL_APP2" "$ALT_SPL_APP3"; do
        if [ -d "$app" ]; then
            rm -rf "$app"
            echo "Deleted $app"
        fi
    done
    # Remove Splashtop support directories and files
    rm -rf "/Library/Application Support/Splashtop Streamer" 2>/dev/null && echo "Removed /Library/Application Support/Splashtop Streamer"
    rm -f "/Library/Application Support/com.splashtop.streamer"* 2>/dev/null && echo "Removed Splashtop Streamer support files in /Library/Application Support"
    rm -rf /Users/Shared/SplashtopRemote 2>/dev/null && echo "Removed /Users/Shared/SplashtopRemote"
    rm -rf /Users/Shared/SplashtopStreamer 2>/dev/null && echo "Removed /Users/Shared/SplashtopStreamer"
    # Remove Splashtop user-specific data in all user home directories
    for user_home in /Users/*; do
        if [ -d "$user_home" ] && [ "$user_home" != "/Users/Shared" ]; then
            rm -f "$user_home/Library/LaunchAgents/com.splashtop.streamer"* 2>/dev/null
            rm -rf "$user_home/Library/Application Support/Splashtop"*/ 2>/dev/null
            rm -f "$user_home/Library/Application Support/com.splashtop.streamer"* 2>/dev/null
            rm -f "$user_home/Library/Preferences/com.splashtop.splashtopStreamer"* 2>/dev/null
        fi
    done
    # Remove root user's Splashtop preferences if any
    rm -f /var/root/Library/Preferences/com.splashtop.splashtopStreamer* 2>/dev/null
    # Remove Splashtop kexts or frameworks if present (older versions)
    rm -rf /Library/Extensions/SRXDisplayCard.kext 2>/dev/null && echo "Removed /Library/Extensions/SRXDisplayCard.kext"
    rm -rf /Library/Extensions/SRXFrameBufferConnector.kext 2>/dev/null && echo "Removed /Library/Extensions/SRXFrameBufferConnector.kext"
    rm -rf /Library/Frameworks/SRFrameBufferConnection.framework 2>/dev/null && echo "Removed /Library/Frameworks/SRFrameBufferConnection.framework"
    # Forget any Splashtop package receipts
    SPLASH_PKGS=$(pkgutil --pkgs | grep -i "splashtop")
    if [ -n "$SPLASH_PKGS" ]; then
        echo "$SPLASH_PKGS" | while read -r pkg; do
            sudo pkgutil --forget "$pkg" && echo "Forgot package receipt: $pkg"
        done
    fi
    echo "Splashtop Streamer uninstall completed."
else
    echo "Splashtop Streamer not found. Skipping Splashtop removal."
fi

### 5. Final confirmation
echo "Uninstallation script completed. Please verify above logs for any errors."
