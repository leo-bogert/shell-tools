#!/bin/bash
if ! source "lib-bash-leo.sh" ; then
	echo 'lib-bash-leo.sh is missing in PATH!'
	exit 1
fi

SELF="$(readlink -f "$0")"

die "review before using!"

for_directories() {
	chmod 'u=rwx' "$1"
	chmod 'g=rx' "$1"
	chmod 'o=' "$1"
	chmod 'g+s' "$1"
	chmod '+t' "$1"
	chgrp 'guest' "$1"
}

for_files() {
	if [ "$SELF" -ef "$1" ] ; then
		echo "excluding self: $1"
		return
	fi

	chmod 'u=rw' "$1"
	chmod 'g=r' "$1"
	chmod 'o=' "$1"
	chgrp 'guest' "$1"
}

if [ $# -ne 1 ] ; then
	echo "Syntax: $(basename "$SELF") FILE_OR_DIRECTORY" >&2
	exit 1
fi

while IFS= read -r -d $'\0' file ; do
	if [ -f "$file" ] ; then
		for_files "$file"
	elif [ -d "$file" ] ; then
		for_directories "$file"
    else
		echo "Unknown file type: $file" >&2
	fi
done < <(find "$1" -mount \( -type f -o -type d \) -print0)
