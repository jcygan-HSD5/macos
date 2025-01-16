#!/bin/sh

# Define the path to your log file
LOGFILE="/var/log/abb_uninstall.log"

# Send all stdout and stderr to both the terminal and the log file
exec > >(tee -a "$LOGFILE") 2>&1

echo "---------- Starting ABB Uninstall at $(date) ----------"

ServicePkgId="com.synology.activebackup-agent.pkg"
ServiceTool="/Applications/Synology Active Backup for Business Agent.app/Contents/MacOS/mac-tool"
RecoveryKextV2InstalledPath="/Applications/Synology Active Backup for Business Recovery.app/Contents/ActiveBackupKextV2.kext"
RecoveryKextV2UsedPath="/Library/Synology/ActiveBackupforBusinessRecovery/ActiveBackupKextV2.kext"

stop_service()
{
	launchctl unload "/Library/LaunchDaemons/com.synology.activebackupagent.plist"
	pkill -9 -x synology-active-backup-for-business-agent-ui 2> /dev/null
}

unload_kext()
{
	kextunload -b "com.synology.activebackupkext" 2> /dev/null
	kextcache --clear-staging

	if [[ ! -d "$RecoveryKextV2InstalledPath" ]] && [[ ! -d "$RecoveryKextV2UsedPath" ]]
	then
		kextunload -b "com.synology.activebackupkext-v2" 2> /dev/null
		kextcache --clear-staging
	fi
}

PLISTBUDDY="/usr/libexec/PlistBuddy -c"
remove_all_snapshots_of_volume() {
	snapshot_list="$(mktemp)"
	diskutil apfs listSnapshots -plist $1 > ${snapshot_list} 2>/dev/null
	if [ $? -ne 0 ]; then
		rm $snapshot_list
		return
	fi

	i=0
	while true ; do
		snapshot_name=$(${PLISTBUDDY} "Print :Snapshots:$i:SnapshotName" "${snapshot_list}" 2>/dev/null)
		if [ $? -ne 0 ]; then
			break
		fi
		[[ $snapshot_name = com.synology.activebackup.* ]] && diskutil apfs deleteSnapshot $1 -name $snapshot_name

		i=$(($i + 1))
	done

	rm $snapshot_list
}

remove_all_abb_snapshots() {
	info_list="$(mktemp)"
	diskutil apfs list -plist > ${info_list}

	container=0
	while true ; do
		volume=0
		while true ; do
			disk_id=$($PLISTBUDDY "Print :Containers:$container:Volumes:$volume:DeviceIdentifier" "${info_list}" 2>/dev/null)
			if [ $? -ne 0 ]; then
				break
			fi
			remove_all_snapshots_of_volume $disk_id
		
			volume=$(($volume + 1))
		done
		container=$(($container + 1))
		disk_id=$($PLISTBUDDY "Print :Containers:$container" "${info_list}" 2>/dev/null)
		if [ $? -ne 0 ]; then
			break
		fi
	done

	rm $info_list
}

remove_cache_volume()
{
	cache_volume_uuid=$(sqlite3 /Library/Synology/ActiveBackupforBusiness/data/system-db.sqlite 'SELECT value FROM system_table WHERE key="mac_cache_volume_uuid";')
	if [ $? -ne 0 ]; then
		return
	fi
	[[ ! -z "$cache_volume_uuid" ]] && diskutil apfs deleteVolume "${cache_volume_uuid}"
}

remove_hidden_loginwindow()
{
	list_idx=0
	while true ; do
		hidden_user_name=$($PLISTBUDDY "Print :HiddenUsersList:${list_idx}" /Library/Preferences/com.apple.loginwindow.plist 2>/dev/null)
		if [ $? -ne 0 ]; then
			break
		fi
		if [ $hidden_user_name = _synologyabbbackup ]; then
			out=$($PLISTBUDDY "Delete :HiddenUsersList:${list_idx} dict" /Library/Preferences/com.apple.loginwindow.plist 2>/dev/null)
		else
			list_idx=$(($list_idx + 1))
		fi
	done
}

remove_system_data()
{
	rm -rf "/Library/LaunchDaemons/com.synology.activebackupagent.plist"

	rm -rf "/Applications/Synology Active Backup for Business Agent.app"

	rm -rf "/Library/Synology/ActiveBackupforBusiness"
}

clear_fstab()
{
    volumes=(
        'ActiveBackupforBusiness_Reserved' 'apfs'
        'ActiveBackupforBusiness_volume' 'hfs'
        'Syno_abb_temp_volume' 'apfs'
    )

    unset EDITOR
    for ((i = 0; $i < ${#volumes[@]}; i+=2)); do
        volume=${volumes[$i]}
        type=${volumes[$i + 1]}
        delete_entry="LABEL=${volume} \\\\/Library\\\\/Synology\\\\/ActiveBackupforBusiness\\\\/${volume} ${type} noauto,nobrowse"

        echo -e ":g/${delete_entry}/d\n\033:wq" | vifs
    done
}

"$ServiceTool" RemoveHiddenUser
remove_hidden_loginwindow

stop_service
unload_kext
remove_all_abb_snapshots
remove_cache_volume

remove_system_data
clear_fstab

pkgutil --forget "$ServicePkgId" 2>/dev/null

exit 0
