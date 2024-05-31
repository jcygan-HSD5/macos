#!/bin/bash

 

# This script is the uninstall script for Druva InSync

 

###################### Start of Script ####################

 

set +x
 user=`laptop`
 echo "loggedInUser:" $user

 

echo " Stopping inSync Client."

 

killall inSync
 killall inSyncDecommission
 killall inSyncClient

 

echo " Removing System Files"

 

if [ -e /Library/Application\ Support/inSync ]; then
 echo "System Application Support found and removed"
 rm -rf /Library/Application\ Support/inSync
 else
 echo "System Application Support not found"
 fi

 

if [ -e /Library/LaunchDaemons/inSyncDecommission.plist ]; then
 echo "System Launch Daemon found and removed"
 /bin/launchctl unload /Library/LaunchDaemons/inSyncDecommission.plist
 rm -f /Library/LaunchDaemons/inSyncDecommission.plist
 else
 echo "System LaunchDaemon not found"
 fi

 

sleep 3

 

if [ -e /Library/LaunchAgents/inSyncAgent.plist ]; then
 echo "System Launch Agent found and removed"
 /bin/launchctl unload /Library/LaunchAgents/inSyncAgent.plist
 rm -f /Library/LaunchAgents/inSyncAgent.plist
 else
 echo "System Launch Agent not found"
 fi

 

sleep 5

 

echo " Removing InSync App"

 

if [ -e /Applications/Druva\ inSync.app ]; then
 echo "InSync App found and removed"
 rm -rf /Applications/Druva\ inSync.app
 else
 echo "InSync App not found"
 fi

 

echo "Removing Keychain entries"

 

/Applications/Druva\ inSync/inSync.app/Contents/MacOS/inSyncDecommission RemoveKeychainItems

 


 if [ -e /Applications/Druva\ inSync ]; then
 echo "Druva Folder App found and removed"
 rm -rf "/Applications/Druva inSync"
 else
 echo "Druva Folder App not found"
 fi

 

sleep 5

 

echo " Removing User Directories"

 

if [ -e /Users/$user/Library/Application\ Support/inSync ]; then
 echo "User Application Support found and removed"
 rm -rf /Users/$user/Library/Application\ Support/inSync
 else
 echo "User Application Support not found"
 fi

 

if [ -e /Users/$user/Library/Preferences/com.trolltech.plist ]; then
 echo "User Preferences found and removed"
 rm -rf /Users/$user/Library/Preferences/com.trolltech.plist
 else
 echo "User Preferences not found"
 fi

 

if [ -e /Users/$user/Library/Preferences/com.trolltech.plist.lockfile ]; then
 echo "User Preferences trolltech found and removed"
 rm -rf /Users/$user/Library/Preferences/com.trolltech.plist.lockfile
 else
 echo "User Preferences trolltech not found"
 fi

 

if [ -e /Users/$user/Library/LaunchAgents/com.druva.inSyncUpdate.plist ]; then
 echo "User Preferences inSyncUpdate found and removed"
 rm -rf /Users/$user/Library/LaunchAgents/com.druva.inSyncUpdate.plist
 else
 echo "User Preferences inSyncUpdate not found"
 fi

 

if [ -e /Users/$user/Library/LaunchAgents/com.druva.inSyncUpdateAgent.plist ]; then
 echo "User Launch Agent found and removed"
 rm -rf /Users/$user/Library/LaunchAgents/com.druva.inSyncUpdateAgent.plist
 else
 echo "User Launch Agent not found"
 fi

 

if [ -e /Users/$user/Library/Containers/com.druva.insync.FinderPlugin/** ]; then
 echo "User Containers found and removed"
 rm -rf /Users/$user/Library/Containers/com.druva.insync.FinderPlugin/**
 else
 echo "User Containers not found"
 fi

 

if [ -e /Users/$user/Library/Group\ Containers/com.druva.insync.sharedDefaults/** ]; then
 echo "User Group Containers found and removed"
 rm -rf /Users/$user/Library/Group\ Containers/com.druva.insync.sharedDefaults/**
 else
 echo "User Group Containers not found"
 fi

 

echo " Removing pkgutil for Druva"

 

pkgutil --forget com.druva.inSync.pkg

 

exit
