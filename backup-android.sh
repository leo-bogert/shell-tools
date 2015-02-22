#!/bin/bash
if ! source "lib-bash-leo.sh" ; then
	echo 'lib-bash-leo.sh is missing in PATH!'
	exit 1
fi

stderr 'This is a script for pulling a full-disk-image backup off an Android device.'
stderr 'Please only use this if you have reviewed the source code to suit for your needs, it is not very generic!'
stderr ''

partition_dir='/dev/block/platform/omap/omap_hsmmc.0/by-name'
partitions=( boot cache dgs efs metadata misc param radio recovery sbl system userdata xloader )

stderr 'WARNING: Only run this when cellphone is in recovery mode - it will unmount all critical system partitions!'
ask_to_continue_or_die

for partition in "${partitions[@]}" ; do
	adb shell umount "$partition_dir/$partition"
done

# TODO: Replace this with a non-manual check
stderr ''
stderr "Please make sure that the following partitions are not mounted: ${partitions[*]}"
adb shell mount 2>&1
ask_to_continue_or_die
stderr ''

directory="backup-android-full-disk-image-$(date --rfc-3339=date)"
mkdir "$directory"
set_working_directory_or_die "$directory"

for partition in "${partitions[@]}" ; do
	stdout "Pulling disk image of $partition ..."
	if adb pull "$partition_dir/$partition" "$partition.img" ; then
		stdout "Generating checksum of $partition.img..."
		cksum "$partition.img" > "$partition.cksum"
	else
		stderr "ERROR: Pull failed for $partition!"
	fi
done

adb kill-server

stdout "Success!"
stdout ""
stdout "To restore a backup, do:"
stdout "    On computer: \$ adb forward tcp:RANDOM_PORT tcp:RANDOM_PORT"
stdout "    Then once for each of partitions {boot, cache, metadata, system, userdata}, do:"
stdout "        On android:  \$ nc -lp RANDOM_PORT > $partition_dir/PARTITION_NAME"
stdout "        On computer: \$ busybox nc localhost RANDOM_PORT < PARTITION_NAME.img"
